execute 'add mongo key' do
  command 'sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927'
end

execute 'create mongodb sources list' do
  command 'echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list'
  not_if 'cat /etc/apt/sources.list.d/mongodb-org-3.2.list'
end

execute 'update cache' do
  command 'sudo apt-get update'
end

package 'mongodb-org-server' do
  version '3.2.0'
end

package 'mongodb-org-shell' do
  version '3.2.0'
end

package 'mongodb-org-mongos' do
  version '3.2.0'
end

package 'mongodb-org-tools' do
  version '3.2.0'
end

package 'mongodb-org' do
  version '3.2.0'
end

template '/etc/init.d/disable-transparent-hugepages' do
  source 'disable-transparent-hugepages'
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'run script to disable transparent hugepages' do
  command '/etc/init.d/disable-transparent-hugepages'
  user 'root'
end

execute 'use init.d to disable transparent hugepages on restart' do
  command 'update-rc.d disable-transparent-hugepages defaults'
  user 'root'
end

