require "spec_helper"

describe "bpm unyank" do
  let(:api_key) { "deadbeef" }
  let(:creds)   { bpm_dir("credentials") }

  before do
    goto_home
    set_host
    start_fake(FakeGemcutter.new(api_key))
  end

  context "with a good api key" do
    before do
      write_api_key(api_key)
    end

    it "unyanks a gem when sent with the right api key" do
      bpm "package", "yank", "core-test", "--undo", "-v", "1.4.3"

      stdout.read.should include("Successfully unyanked gem: core-test (1.4.3)")
    end

    it "must unyank a valid gem" do
      bpm "package", "yank", "blahblah", "--undo", "-v", "0.0.1"

      stdout.read.should include("This gem could not be found")
    end

    it "does not unyank and indexed gem" do
      bpm "package", "yank", "core-test", "--undo", "-v", "2.4.3"

      stdout.read.should include("The version 2.4.3 is already indexed.")
    end
  end

  it "shows rejection message if wrong api key is supplied" do
    write_api_key("beefbeef")

    bpm "package", "yank", "core-test", "--undo", "-v", "1.4.3"

    stdout.read.should include("One cannot simply walk into Mordor!")
  end
end

describe "bpm unyank with invalid api key" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    write_api_key("beefbeef")
  end

  it "must require a version" do
    bpm "package", "yank", "core-test", "--undo"

    stdout.read.should include("Version required")
  end
end

describe "bpm unyank without api key" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
  end

  it "asks for login first if api key does not exist" do
    bpm "package", "yank", "core-test", "-v", "1.4.3", "--undo"

    stdout.read.should include("Please login first with `bpm login`")
  end
end
