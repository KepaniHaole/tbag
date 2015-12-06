require_relative '../../src/tbag/task_parser'
require_relative '../../src/bootstrap/directory'

module Tbag
  describe TaskParser do
    context 'when given a single empty task definition' do
      subject do
        File.should_receive(:mtime).and_return(Time.now)
        described_class.new(
          :raw_task_data => [{
            :file_name => 'test1.rb',
            :task_data =>
              <<-TASK
                every_2_seconds { from "not_important" }
              TASK
          }],
          :tasks_directory => Directory.new(:path => 'tasks'),
          :task_logs_directory => Directory.new(:path => 'not_important', :subdirectories => %w(task))
        ).tasks
      end

      it 'should parse it' do
        expect(subject.length).to eq(1)
      end
    end

    context 'when given a single task definition wrapped in an iterator' do
      subject do
        File.should_receive(:mtime).and_return(Time.now)
        described_class.new(
          :raw_task_data => [{
            :file_name => 'test2.rb',
            :task_data =>
              <<-TASK
                50.times do
                  every_10_days { from "not_important" }
                end
              TASK
          }],
          :tasks_directory => Directory.new(:path => 'tasks'),
          :task_logs_directory => Directory.new(:path => 'not_important', :subdirectories => %w(task))
        ).tasks
      end

      it 'should parse all of them' do
        expect(subject.length).to eq(50)
      end
    end

    [
      1234,
      "'nuke_system'",
      ':foobar'
    ].each do |task_name|
      context 'when given a single task definition with a custom name' do
        subject {
        File.should_receive(:mtime).and_return(Time.now)
          described_class.new(
            :raw_task_data => [{
              :file_name => 'test2.rb',
              :task_data =>
                <<-TASK
                  every_year #{task_name} do
                    run "rm -rf *"
                    from '/'
                  end
                TASK
            }],
            :tasks_directory => Directory.new(:path => 'tasks'),
            :task_logs_directory => Directory.new(:path => 'not_important', :subdirectories => %w(task))
          ).tasks
        }

        it 'should parse all of them' do
          expect(subject.length).to eq(1)
          expect(task_name.to_s).to include(subject[0].name)
        end
      end
    end

    context 'when given task definitions that violate task semantics' do
      [
        # nested tasks
        %q(
          every_100_days {
            run 'a'
            from 'x'
            every_10_seconds {
              run 'b'
              from 'y'
            }
          }
        ),
        # no block given
        %q(
          every_1_days
        ),
        # shell command outside of task
        %q(
          run 'this is not good'
        ),
        # execution directory outside of task
        %q(
          from 'this is not good'
        ),
        # log directory outside of task
        %q(
          log 'this is not good'
        ),
        # sub task outside of task
        %q(
          followed_by {
          }
        ),
        # multiple runs
        %q(
          every_40_hours {
            run "first"
            run "second"
          }
        ),
        # multiple froms
        %q(
          every_14_seconds {
            from 'a'
            from 'b'
          }
        ),
        # multiple logs
        %q(
          every_1_seconds {
            log 'a'
            log 'b'
          }
        ),
      ].each do |task_data|
        it 'should raise an exception' do
          expect {
            described_class.new(
              :raw_task_data => [{ :file_name => 'not_important.rb', :task_data => task_data }],
              :tasks_directory => Directory.new(:path => 'tasks'),
              :task_logs_directory => Directory.new(:path => 'not_important', :subdirectories => %w(task))
            )
          }.to raise_exception
        end
      end
    end
  end
end