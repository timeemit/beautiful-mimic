# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# RVM
# https://github.com/capistrano/rvm
require 'capistrano/rvm'

# Bundler
# https://github.com/capistrano/bundler
require 'capistrano/bundler'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
