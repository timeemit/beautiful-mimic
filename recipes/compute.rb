# STEP 1
# Install torch

package 'git'

directory '/opt/compute'
directory '/opt/compute/lib'

remote_file '/opt/compute/lib/install-deps' do 
  source 'https://raw.githubusercontent.com/torch/ezinstall/master/install-deps'
end

execute 'install torch dependencies' do
  command 'cat /opt/compute/lib/install-deps | bash'
  not_if 'which th'
end

git '/opt/compute/lib/torch' do
  repository 'https://github.com/torch/distro.git'
  enable_submodules true
end

execute 'install torch' do
  command './install.sh -b'
  user 'root'
  cwd '/opt/compute/lib/torch'
  not_if 'which th'
end

# STEP 2
# Install loadcaffe

package 'libprotobuf-dev' 
package 'protobuf-compiler'

execute 'install loadcaffe' do
  command '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks install loadcaffe'
  user 'root'
  not_if '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks show loadcaffe'
end

# STEP 3
#
