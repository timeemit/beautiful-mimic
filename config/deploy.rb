# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'beautiful-mimic'
set :repo_url, 'git@github.com:timeemit/beautiful-mimic.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/beautiful-mimic'

# RVM ruby version
set :rvm_ruby_version, '2.3.1'

# Use Gemfile in app
set :bundle_gemfile, -> { release_path.join('app', 'Gemfile') }      # default: nil


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :sidekiq do
  %w(start stop restart).each do |command|
    desc "#{command.capitalize} Sidekiq"
    task command do
      on roles :all do
        as(user: 'root') { execute :initctl, "#{command} workers" }
      end
    end
  end
end

namespace :deploy do
  after :published, :place_secrets do
    src = File.expand_path('../app/environments/production.yml', __dir__)
    dest = '/opt/beautiful-mimic/current/app/environments/production.yml'
    on roles(:all) do
      execute :mkdir, '/opt/beautiful-mimic/current/app/environments'
      upload! src, dest
    end
  end

  after :finished, :'sidekiq:restart'
end

namespace :train_model do
  desc 'Tail nohup'
  task 'tail' do
    on roles :all do
      as(user: 'root') { execute :tail, '-2 /home/bm/nohup.out' }
    end
  end

  desc 'Follow nohup'
  task 'follow' do
    on roles :all do
      as(user: 'root') { execute :tail, '-f /home/bm/nohup.out' }
    end
  end
end
