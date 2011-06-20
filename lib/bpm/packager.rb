require 'bpm/base'
require 'libgems'
require 'libgems_ext'

module BPM
  
  module Packager
    autoload :CLI,                  'bpm/packager/cli'
    autoload :Credentials,          'bpm/packager/credentials'
    autoload :Local,                'bpm/packager/local'
    autoload :Package,              'bpm/packager/package'
    autoload :Remote,               'bpm/packager/remote'
    autoload :Repository,           'bpm/packager/repository'
    autoload :Version,              'bpm/packager/version'
  end
end

