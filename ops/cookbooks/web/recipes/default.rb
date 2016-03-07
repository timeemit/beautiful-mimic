package 'nginx'

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'restart nginx' do
  command 'nginx -s reload'
  user 'root'
end
