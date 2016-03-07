package 'upstart'

file '/var/log/unicorn.stdout.log' do
  user 'ubuntu'
  action :touch
end

file '/var/log/unicorn.stderr.log' do
  user 'ubuntu'
  action :touch
end

execute 'install keyserver' do
  command 'su ubuntu -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"'
  not_if 'which rvm'
end

execute 'install rvm' do
  command 'su ubuntu -c "curl -sSL https://get.rvm.io | bash -s stable"'
  not_if 'su ubuntu -l -c "which rvm"'
end

execute 'install ruby version' do
  command 'su ubuntu -l -c "rvm install `cat /opt/code/.ruby-version`"'
end

execute 'install gemset' do
  command 'su ubuntu -l -c "rvm use `cat /opt/code/.ruby-version` && rvm gemset create `cat /opt/code/.ruby-gemset`"'
end

execute 'install gems' do
  command 'su ubuntu -l -c "cd /opt/code/ && bundle install"'
end


# Start Unicorn if it isn't already running
execute 'start unicorn' do
  command 'su ubuntu -l -c "cd /opt/code/app/ && bundle exec unicorn -c /opt/code/app/unicorn.conf.rb"'
  not_if '[ -f /tmp/app.pid ]'
end

# Restart Unicorn if it _is_ running
execute 'restart unicorn' do
  command 'su ubuntu -l -c "kill -s 1 `cat /tmp/app.pid`"' # Signal 1 is SIGHUP
  only_if '[ -f /tmp/app.pid ]'
end
