require_relative 'environment/mock_log'
require_relative 'environment/environment'
require_relative '../../src/tbag/file_watcher'
require_relative '../../src/tbag/task'

module Tbag
  describe FileWatcher do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:dynamically_added_task) { 'dynamically_added_task' }

    # start with no tasks
    subject { described_class.new(:tasks => tasks, :system_log => MockLog.new, :tasks_directory => Environment.tasks_directory) }

    context 'when a task is dynamically added to the file system' do
      let(:tasks) { [] }

      it 'should detect it' do
        # make sure we consistently pick up nothing
        100.times { expect(subject.watch_for_new_files).to eq([]) }

        # write a task to disk
        IO.write(File.join(Environment.tasks_directory.path, dynamically_added_task),
          %Q(
            yearly {
              run  "echo 'happy new year'"
              from '/'
            }
          )
        )

        new_tasks = subject.watch_for_new_files

        expect(new_tasks.length).to eq(1)
        expect(new_tasks[0]).to eq(dynamically_added_task)
      end
    end

    context 'when a task is dynamically updated on the file system' do
      # in memory representation of our task
      # (not accurate but that's fine, all that has to be consistent is the name)
      let(:tasks) {
        file_name = File.join Environment.tasks_directory.path, dynamically_added_task
        # write the task to disk
        IO.write(file_name,
          %Q(
            yearly {
              run  "echo 'happy new year'"
              from '/'
            }
          )
        )

        # give a second to let the disk change go all the way through
        sleep 1

        [
          Task.new(
            :file_name => dynamically_added_task,
            :file_modification_time => File.mtime(file_name).to_i,
            :task_name => "#{dynamically_added_task}_1"
          )
        ]
      }

      it 'should detect it' do
        # make sure we consistently pick up nothing
        100.times { expect(subject.watch_for_updated_files).to eq([]) }

        # update that task on disk
        IO.write(File.join(Environment.tasks_directory.path, dynamically_added_task),
          %Q(
            monthly {
              run  "echo 'uhh...happy new year?'"
              from '/'
            }
          )
        )

        # give a second to let the disk change go all the way through
        sleep 1

        updated_tasks = subject.watch_for_updated_files

        expect(updated_tasks.length).to eq(1)
        expect(updated_tasks[0]).to eq(dynamically_added_task)
      end
    end
  end
end