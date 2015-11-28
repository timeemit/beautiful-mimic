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
# Install neural-style

git '/opt/compute/lib/neural-style' do
  repository 'https://github.com/jcjohnson/neural-style.git'
end

execute 'install neural-style' do
  command 'sh models/download_models.sh'
  user 'root'
  cwd '/opt/compute/lib/neural-style'
  not_if '[ -f moedles/VGG_ILSVRC_19_layers.caffemodel ]'
end

# STEP 4
# Install CUDA

remote_file '/opt/compute/lib/cuda' do 
  source 'http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/rpmdeb/cuda-repo-ubuntu1404-7-0-local_7.0-28_amd64.deb'
end

dpkg_package 'cuda' do
  source '/opt/compute/lib/cuda'
end

package 'cuda' do
  action 'update' # ?  May need to just run an execute module to run `apt-get update`
end

# STEP 5
# Install CUDA backend for Lua

execute 'install cutorch' do
  command '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks install cutorch'
  user 'root'
  not_if '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks show cutorch'
end

execute 'install cunn' do
  command '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks install cunn'
  user 'root'
  not_if '. /opt/compute/lib/torch/install/bin/torch-activate && luarocks show cunn'
end
