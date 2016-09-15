require 'sidekiq'

class SidekiqClient
  def self.connect!(env)
    redis = env['redis']
    url = "#{redis['ip']}:#{redis['port']}"

    if env['redis']['password']
      url = "x:#{env['redis']['password']}@#{url}"
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: "redis://#{url}" }
    end
  end
end
