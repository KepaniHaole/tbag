# tbag - a lightweight, asynchronous, and continuous system task execution service

![alt text](https://travis-ci.org/KepaniHaole/tbag.svg?branch=master "should be passing")

taskbag (`tbag`) is a framework designed to make system automation as simple as it can possibly be.
Syntactically, a `tbag` task is just standard Ruby, but it inherits a few special semantics
that make writing automations very straightforward and maintainable.

## Installation / Bootstrapping

Assuming you've cloned this repository and are inside the source root:

  ```
  bundle install
  sudo rake bootstrap
  ```

## Usage

### A. Scheduling tasks

1. Start `tbag`:

  `sudo tbag start`

2. Write a chunk of Ruby code, and put it in a `.rb` file in `/etc/tbag/tasks`. Tasks are written like:

  ```ruby
  # echo.rb
  every_2_minutes {
    run 'echo foobar'
    from '/'
  }

  # or...
  # not_a_good_idea.rb
  %w(repo1 repo2 repo3) do |repo|
    every_27_minutes :this_is_not_a_good_idea do
      run  "git fetch"
      from "/home/git/#{repo}"
    end
  end

  # or...
  # define a task chain
  # build_my_java_project_and_its_tests.rb
  build_command = 'mvn clean install'
  source_root = '/my/java/project/'
  test_root = '/my/java/test_project/'
  continuously {
    run build_command
    from source_root

    followed_by {
      run build_command
      from test_root
    }
  }
  ```

  <strong>`tbag` uses an "inference engine" that will try and figure out the interval you
  want to run your task at. Common intervals include:</strong>

  |interval         |description       |
  |-----------------|------------------|
  |continuously     | run all the time |
  |daily            | run once a day   |
  |hourly           | run once an hour |
  |every_5_minutes  | ...              |
  |every_52_seconds | ...              |


3. Observe the status report to see the outcome of your tasks, and the next time they'll run:

  `sudo tbag status`

4. Observe the system log file to see what's happening behind the scenes:

  `sudo tbag syslog`

5. Stop `tbag`:

  `sudo tbag stop`

### B. Directory structure

By default, the OOB file system structure that `tbag` uses is this:

  ```
  /etc/tbag
  /etc/tbag/tasks         <--- put task definitions here
  /etc/tbag/logs
  /etc/tbag/logs/system   <--- view system log here
  /etc/tbag/logs/task     <--- view task logs here
  /etc/tbag/trash         <--- any invalid tasks / garbage gets sent here automatically
  ```

### C. Staying up to date

  ```
  sudo tbag update
  sudo tbag start
  ```

## Supported platforms

Support should be available natively on most *nix and *nix-like systems.

Windows support is on the TODO list.