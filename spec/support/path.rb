module SpecHelpers
  def reset!
    FileUtils.rm_rf   tmp
    [ home, local ].each do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def cd(path, &blk)
    Dir.chdir(path, &blk)
  end

  def cwd(*args)
    Pathname.new(Dir.pwd).join(*args)
  end

  def rm(path)
    FileUtils.rm path
  end

  def rm_r(path)
    FileUtils.rm_r path
  end

  def rm_rf(path)
    FileUtils.rm_rf(path)
  end

  def root
    @root ||= Pathname.new(File.expand_path("../../..", __FILE__))
  end

  def fixtures(*path)
    root.join('spec/fixtures', *path)
  end

  def tmp(*path)
    root.join("tmp", *path)
  end

  def home(*path)
    tmp.join("home", *path)
  end

  def local(*path)
    tmp.join("local", *path)
  end

  def spade_dir(*path)
    home(Spade::SPADE_DIR, *path)
  end

  def goto_home
    cd(home)
    env["HOME"] = home.to_s
    LibGems.clear_paths
  end

  module_function :root, :tmp, :home, :local, :goto_home
end

