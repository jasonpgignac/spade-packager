module BPM

  BPM_DIR = '.bpm'

  # find the current path with a package.json or .packages or cur_path
  def self.discover_root(cur_path)
    ret = File.expand_path(cur_path)
    while ret != '/' && ret != '.'
      return ret if File.exists?(File.join(ret,'package.json')) || File.exists?(File.join(ret,'.bpm'))
      ret = File.dirname ret
    end

    return cur_path
  end

end
