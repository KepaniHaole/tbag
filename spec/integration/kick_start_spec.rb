require_relative 'environment/environment'

require_relative '../../src/bootstrap/kick_start'
require_relative '../../src/bootstrap/kill_switch'

module Tbag
  describe KickStart do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:test_task) { 'test_task.rb' }

    let(:pid) { Pid.new Environment.pid_file }

    let(:kill_switch) {
      KillSwitch.new(
        :pid => pid
      )
    }

    subject {
      described_class.new(
        :tasks_directory => tasks_directory,
        :logs_directory  => Environment.logs_directory,
        :pid             => pid
      )
    }

    context 'when kick started with syntactically correct tasks' do
      # 7 tasks, 12 total runs
      let(:tasks_directory) {
        directory = Environment.tasks_directory
        IO.write(File.join(directory.path, test_task),
          %Q(
            # 5 tasks
            # each one runs once in a 10 second period
            5.times {
              monthly {
                run  "echo 'this one is instant'"
                from "#{directory.path}"
              }
            }

            # 1 task
            # runs twice in a 10 second period
            every_4_seconds {
              run  "echo 'this one taks a few seconds'"
              from "#{directory.path}"
            }
          )
        )
        IO.write(File.join(directory.path, "foo_#{test_task}"),
          %Q(
            # 1 task
            # runs 5 times in a 10 second period
            every_2_seconds {
              run  "echo 'this one taks a few seconds'"
              from "#{directory.path}"
            }
          )
        )
        directory
      }

      it 'should have both tasks and log files after the service runs for 10 seconds' do
        subject.kick_start

        sleep 10

        # ensure we have a system log
        expect(Dir.glob(File.join(Environment.system_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(1)

        # count task files (should be 2)
        expect(Dir.glob(File.join(tasks_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(2)

        # count log directories (should be 7 total)
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.directory?(file) }.count).to eq(7)

        # count actual log files
        # 7 taskdb files (7 tasks, 1 for each task)
        # 36 log files (12 runs, each run writes 3 log files -- stdout + stderr + rc)
        # should be 43 total, but obviously with sleep() nothing is certain
        # make sure we have at least 40 files
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to be >= 40

        pid.stub(:valid?).and_return(true)
        kill_switch.kill
      end
    end

    [
      # bad interval
      %Q(
        every_444_foobar_white_lizards {
          run  "echo 'trololoololl'"
          from "/"
        }
      ),
      # unmatching do / brackets
      %Q(
        continuously do
          run  "echo 'trololoololl'"
          from "/"
        }
      ),
      '' # empty string isn't legit either, blow up
    ].each do |string|
      context 'when kick started with a task that has an error' do
        let(:tasks_directory) {
          directory = Environment.tasks_directory
          IO.write(File.join(directory.path, test_task), string)
          directory
        }

        it 'should produce a system exit and 0 log files' do
          expect { subject.kick_start }.to raise_error SystemExit

          # ensure we have a system log, and it has stuff in it
          expect(Dir.glob(File.join(Environment.system_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(1)

          # count task files (should be 1)
          expect(Dir.glob(File.join(tasks_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(1)

          # count log files (should be 0 total because nothing ran)
          expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(0)
        end
      end
    end

    context 'when double kick started' do
      let(:tasks_directory) {
        directory = Environment.tasks_directory
        IO.write(File.join(directory.path, test_task),
          %Q(
            monthly {
              run  "echo 'weeeeeee'"
              from "#{directory.path}"
            }
          )
        )
        directory
      }

      it 'should fail' do
        # this one's ok
        subject.kick_start

        pid.stub(:valid?).and_return(true)

        # this one isn't -- the first process should still be running
        expect { subject.kick_start }.to raise_error SystemExit

        kill_switch.kill
      end
    end

    context 'when new tasks are dynamically added' do
      let(:tasks_directory) {
        directory = Environment.tasks_directory
        IO.write(File.join(directory.path, test_task),
          %Q(
            monthly {
              run  "echo 'i am the initial task on disk.'"
              from "#{directory.path}"

              followed_by {
                run "echo i am a really complicated subtask"
                from "#{directory.path}"
              }
            }
          )
        )
        directory
      }

      it 'should pick them up and execute them' do
        subject.kick_start

        sleep 5

        # make sure the initial task (and it's subtask) ran
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(8)

        # add a new task
        IO.write(File.join(tasks_directory.path, "new_task.rb"),
          %Q(
            monthly {
              run  "echo 'i am the new task to disk that was just written'"
              from "#{tasks_directory.path}"
            }
          )
        )

        sleep 5

        # make sure the new task ran (.taskdb + 3 log files)
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(12)

        pid.stub(:valid?).and_return(true)
        kill_switch.kill
      end
    end

    context 'when existing tasks are dynamically modified' do
      let(:tasks_directory) {
        directory = Environment.tasks_directory
        IO.write(File.join(directory.path, test_task),
          %Q(
            monthly {
              run  "echo 'i am the initial task on disk.'"
              from "#{directory.path}"
            }
          )
        )
        directory
      }

      it 'should pick them up and execute them' do
        subject.kick_start

        sleep 5

        # make sure the initial task ran
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(4)

        # edit the task file we started with
        IO.write(File.join(tasks_directory.path, test_task),
          %Q(
            monthly {
              run  "echo 'i am the same task but with new content'"
              from "#{tasks_directory.path}"
            }
          )
        )

        sleep 5

        # make sure it ran a second time (7 files instead of 8 since there's only one .taskdb)
        expect(Dir.glob(File.join(Environment.task_logs_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(7)

        pid.stub(:valid?).and_return(true)
        kill_switch.kill
      end
    end
  end
end