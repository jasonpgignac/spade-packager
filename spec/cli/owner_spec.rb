require "spec_helper"

describe "bpm owner" do
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

    it "registers new owners if package is owned" do
      bpm "package", "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("Owner added successfully.")
    end

    it "removes owners if package is owned" do
      bpm "package", "owner", "remove", "rake", "geddy@example.com"

      stdout.read.should include("Owner removed successfully.")
    end

    it "lists owners for a gem" do
      bpm "package", "owner", "list", "rake"

      stdout.read.should == <<EOF
Owners for package: rake
- geddy@example.com
- lerxst@example.com
EOF
    end
  end

  context "with wrong api key" do
    before do
      write_api_key("beefbeef")
    end

    it "shows rejection message for add if wrong api key is supplied" do
      bpm "package", "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end

    it "shows rejection message for remove if wrong api key is supplied" do
      bpm "package", "owner", "remove", "rake", "geddy@example.com"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end

    it "shows rejection message for list if wrong api key is supplied" do
      bpm "package", "owner", "list", "rake"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end
  end
end

describe "bpm owner with wrong arguments" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
  end

  it "asks for login first if api key does not exist" do
    bpm "package", "owner", "add", "rake", "geddy@example.com", :track_stderr => true

    stderr.read.should include("Please login first with `bpm login`")
  end

  it "asks for login first if api key does not exist" do
    bpm "package", "owner", "remove", "rake", "geddy@example.com", :track_stderr => true

    stderr.read.should include("Please login first with `bpm login`")
  end

  it "asks for login first if api key does not exist" do
    bpm "package", "owner", "list", "rake", :track_stderr => true

    stderr.read.should include("Please login first with `bpm login`")
  end

  it "requires a package name for add" do
    bpm "package", "owner", "add", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for remove" do
    bpm "package", "owner", "remove", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for list" do
    bpm "package", "owner", "list", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for list with default command" do
    bpm "package", "owner", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end
end
