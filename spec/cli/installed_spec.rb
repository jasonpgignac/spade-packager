require "spec_helper"

describe "bpm installed" do
  before do
    goto_home
    set_host
    # TODO: Make this LibGems specific
    env["GEM_HOME"] = bpm_dir.to_s
    env["GEM_PATH"] = bpm_dir.to_s
    start_fake(FakeGemServer.new)
  end

  it "lists installed bpm packages" do
    bpm "package", "install", "rake"
    wait
    bpm "package", "installed"

    output = stdout.read
    output.should include("rake (0.8.7)")
    output.should_not include("0.8.6")
    output.should_not include("builder")
    output.should_not include("bundler")
    output.should_not include("highline")
  end

  it "lists all installed bpm packages from different versions" do
    bpm "package", "install", "rake"
    wait
    bpm "package", "install", "rake", "-v", "0.8.6"
    wait
    bpm "package", "installed"

    output = stdout.read
    output.should include("rake (0.8.7, 0.8.6)")
  end

  it "filters bpm packages when given an argument" do
    bpm "package", "install", "rake"
    wait
    bpm "package", "install", "builder"
    wait
    bpm "package", "installed", "builder"

    output = stdout.read
    output.should_not include("rake")
    output.should include("builder (3.0.0)")
  end

  it "says it couldn't find any if none found" do
    bpm "package", "installed", "rails", :track_stderr => true

    stderr.read.strip.should == 'No packages found matching "rails".'
    exit_status.should_not be_success
  end
end
