require 'libgems'

module LibGems
  def self.default_sources
    %w[https://sproutcutter.heroku.com/]
  end

  def self.host
    @host ||= "https://sproutcutter.heroku.com"
  end

  def self.default_dir
    File.join LibGems.user_home, Spade::SPADE_DIR
  end

  def self.user_dir
    File.join LibGems.user_home, Spade::SPADE_DIR
  end

  def self.config_file
    File.join LibGems.user_home, '.spaderc'
  end

  def self.path
    @gem_path ||= nil

    unless @gem_path then
      paths = [ENV['SPADE_PATH'] || LibGems.configuration.path || default_path]
      set_paths paths.compact.join(File::PATH_SEPARATOR)
    end

    @gem_path
  end

  def self.dir
    set_home(ENV['SPADE_HOME'] || LibGems.configuration.home || default_dir) unless @gem_home
    @gem_home
  end
end
