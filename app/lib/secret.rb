class Secret
  include Singleton

  class << self
    attr_reader :path
    attr_reader :config

    def set!(environment)
      @path = File.expand_path("../environments/#{environment}.yml", __dir__)
      @config = YAML::load_file @path
    end
  end
end
