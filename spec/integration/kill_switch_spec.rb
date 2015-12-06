require_relative 'environment/environment'
require_relative '../../src/bootstrap/kill_switch'
require_relative '../../src/bootstrap/kick_start'

require_relative '../../src/bootstrap/pid'

module Tbag
  describe KillSwitch do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:pid) { Pid.new Environment.pid_file }

    let(:test_task) { 'test_task.rb' }

    subject {
      described_class.new(
        :pid => pid
      )
    }

    context 'when the task service is not running' do
      context 'when another process is using our cached pid' do
        it 'should not kill anything' do
          pid.stub(:valid?).and_return(false)
          expect { subject.kill }.to raise_error SystemExit
        end
      end

      it 'should not kill anything' do
        pid.stub(:exists?).and_return(false)
        expect { subject.kill }.to raise_error SystemExit
      end
    end

    context 'when the task service is running' do
      let(:tasks_directory) {
        directory = Environment.tasks_directory
        IO.write(File.join(directory.path, test_task),
          %Q(
            daily {
              run  "echo 'this one is instant and runs once a day'"
              from "#{directory.path}"
            }
          )
        )
        directory
      }

      let(:kick_start) {
        KickStart.new(
          :tasks_directory => tasks_directory,
          :logs_directory  => Environment.logs_directory,
          :pid             => pid
        )
      }

      it 'should kill the task service' do
        kick_start.kick_start

        sleep 10

        pid.stub(:valid?).and_return(true)

        subject.kill

        expect(Pid.new(Environment.pid_file).exists?).to be(false)
      end
    end
  end
end