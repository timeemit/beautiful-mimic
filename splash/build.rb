require 'yaml'
require 'uglifier'
require 'sass'
require 'aws-sdk'

require_relative '../app/lib/aws_authenticator' # Cross directory dependency. Ew.

# ARG Parse
ENVIRONMENTS = ['development', 'production']
ENVIRONMENT = ARGV[0]
raise "Choose one of #{ENVIRONMENTS}" unless ENVIRONMENTS.include? ENVIRONMENT

# AWS
ENV_HASHMAP = YAML.load_file(File.expand_path("environments/#{ENVIRONMENT}.yml", "#{__dir__}/../app"))
AwsAuthenticator.authenticate!(ENV_HASHMAP)
S3 = Aws::S3::Client.new
BUCKET = "#{ENVIRONMENT == 'production' ? 'www' : ENVIRONMENT}.beautifulmimic.com"

# HTML
HTML_KEY = 'index.html'
HTML_OUTPUT = "#{__dir__}/index.html"

# JS
JS_DIR = File.expand_path('assets/javascripts', __dir__)
JS_KEY = 'javascript.js'
JS_OUTPUT = "#{__dir__}/#{JS_KEY}"
JS_DEPENDENCIES = %w(
  jquery.min.js
)

# CSS
CSS_DIR = File.expand_path('assets/stylesheets', __dir__)
CSS_KEY = "stylesheet.css"
CSS_OUTPUT = "#{__dir__}/#{CSS_KEY}"
CSS_DEPENDENCIES = %w(
  pure.min.css
  grids-responseive.min.css
  app.css
)

# CSS
IMAGE_FILES = Dir["#{__dir__}/assets/images/*"]

# Collect dependencies
js_source = JS_DEPENDENCIES.inject('') do |source, dep|
  source << IO.read("#{JS_DIR}/#{dep}")
end

css_source = CSS_DEPENDENCIES.inject('') do |source, dep|
  source << IO.read("#{CSS_DIR}/#{dep}")
end

# Write minified output
IO.write(JS_OUTPUT, Uglifier.compile(js_source))
IO.write(CSS_OUTPUT, Sass::Engine.new(css_source, style: :compressed, syntax: :scss).render)

# Upload to S3
S3_OPTS = {bucket: BUCKET, acl: 'public-read'}

S3.put_object(key: HTML_KEY, body: File.open(HTML_OUTPUT), **S3_OPTS)
S3.put_object(key: JS_KEY, body: File.open(JS_OUTPUT), **S3_OPTS)
S3.put_object(key: CSS_KEY, body: File.open(CSS_OUTPUT), **S3_OPTS)

# Recursively upload images
def upload_image(image_file, key)
  if File.directory?(image_file)
    Dir["#{image_file}/*"].each do |new_image_file|
      upload_image(new_image_file, "#{key}/#{File.basename(new_image_file)}")
    end
  else
    S3.put_object(key: key, body: File.open(image_file), **S3_OPTS)
  end
end

IMAGE_FILES.each do |image_file|
  upload_image(image_file, "images/#{File.basename(image_file)}")
end

# Cleanup
[JS_OUTPUT, CSS_OUTPUT].each do |filename|
  File.delete filename
end
