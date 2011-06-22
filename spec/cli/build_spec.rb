require "spec_helper"
require "libgems/format"

describe "bpm build when logged in" do
  let(:email) { "who@example.com" }

  before do
    goto_home
    write_creds(email, "deadbeef")
  end

  it "builds a bpm from a given package.json" do
    FileUtils.cp_r fixtures("core-test"), "."
    FileUtils.cp fixtures("package.json"), "core-test"
    cd "core-test"
    bpm "build"

    exit_status.should be_success
    output = stdout.read
    output.should include("Successfully built package: core-test-0.4.3.spd")

    package = LibGems::Format.from_file_by_path("core-test-0.4.3.spd")
    package.spec.name.should == "core-test"
    package.spec.version.should == LibGems::Version.new("0.4.3")
    package.spec.email.should == email
  end
end

describe "bpm build without logging in" do
  before do
    goto_home
  end

  it "builds a bpm from a given package.json" do
    FileUtils.cp_r fixtures("core-test"), "."
    FileUtils.cp fixtures("package.json"), "core-test"
    cd "core-test"
    bpm "build"

    exit_status.should be_success
    output = stdout.read

    package = LibGems::Format.from_file_by_path("core-test-0.4.3.spd")
    package.spec.name.should == "core-test"
    package.spec.version.should == LibGems::Version.new("0.4.3")
  end
  it "sets the email address if one is given" do
    FileUtils.cp_r fixtures("core-test"), "."
    FileUtils.cp fixtures("package.json"), "core-test"
    cd "core-test"
    bpm "build", "-e", "lucy@allen.com"

    exit_status.should be_success
    output = stdout.read

    package = LibGems::Format.from_file_by_path("core-test-0.4.3.spd")
    package.spec.name.should == "core-test"
    package.spec.version.should == LibGems::Version.new("0.4.3")
    package.spec.email.should == "lucy@allen.com"
  end
end

describe "bpm build with an invalid package.json" do
  before do
    goto_home
    write_api_key("deadbeef")
  end

  it "reports error messages" do
    FileUtils.touch "package.json"
    bpm "build", :track_stderr => true

    exit_status.should_not be_success
    output = stderr.read
    output.should include("BPM encountered the following problems building your package:")
    output.should include("There was a problem parsing package.json")
  end
end
