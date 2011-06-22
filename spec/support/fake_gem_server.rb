class FakeGemServer
  include SpecHelpers

  def index(name, version)
    [name, LibGems::Version.new(version), "ruby"]
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /latest_specs/
      latest_index = [
        index("builder",   "3.0.0"),
        index("highline",  "1.6.1"),
        index("rake",      "0.8.7"),
        index("core-test", "0.4.9"),
        index("ivory",     "0.0.1"),
        index("optparse",  "1.0.1")
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(latest_index)]
    elsif request.path =~ /prerelease_specs/
      prerelease_index = [
        index("bundler",  "1.1.pre")
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(prerelease_index)]
    elsif request.path =~ /specs/
      big_index = [
        index("builder",   "3.0.0"),
        index("highline",  "1.6.1"),
        index("rake",      "0.8.7"),
        index("rake",      "0.8.6"),
        index("core-test", "0.4.9"),
        index("ivory",     "0.0.1"),
        index("optparse",  "1.0.1")
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(big_index)]
    elsif request.path =~ /\/quick\/Marshal\.4\.8\/(.*)\.gemspec\.rz$/

      spec  = LibGems::Format.from_file_by_path(gem_or_spade($1).to_s).spec
      value = LibGems.deflate(Marshal.dump(spec))

      [200, {"Content-Type" => "application/octet-stream"}, value]
    elsif request.path =~ /\/gems\/(.*)\.gem$/
      [200, {"Content-Type" => "application/octet-stream"}, File.read(gem_or_spade($1))]
    else
      [200, {"Content-Type" => "text/plain"}, "fake gem server"]
    end
  end

  def compress(index)
    compressed = StringIO.new
    gzip = Zlib::GzipWriter.new(compressed)
    gzip.write(Marshal.dump(index))
    gzip.close
    compressed.string
  end

  private

    def gem_or_spade(name)
      fixture = fixtures("#{name}.gem")
      fixture = fixtures("#{name}.spd") unless File.exist?(fixture)
      fixture
    end

end

