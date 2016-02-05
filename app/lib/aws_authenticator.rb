require 'aws-sdk'

class AwsAuthenticator 
  def self.authenticate!(env)
    aws_key = Aws::Credentials.new(
      env['AWS']['access_key_id'],
      env['AWS']['secret_access_key']
    )

    Aws.config.update({
      region: env['AWS']['region'],
      credentials: aws_key
    })
  end
end
