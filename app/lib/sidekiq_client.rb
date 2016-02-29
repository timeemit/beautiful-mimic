require 'sidekiq'

class SidekiqClient
  def self.connect!(env)
    redis = env['redis']
    url = "#{redis['ip']}:#{redis['port']}/#{redis['db']}"

    Sidekiq.configure_client do |config|
      config.redis = { url: "redis://#{url}" }
    end
  end
end
