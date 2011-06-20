require "spec_helper"

describe "bpm login" do
  let(:email)    { "email@example.com" }
  let(:password) { "secrets" }
  let(:api_key)  { "deadbeef" }
  let(:creds)    { bpm_dir("credentials") }

  before do
    goto_home

    fake = lambda { |env|
      [200, {"Content-Type" => "text/plain"}, [api_key]]
    }

    protected_fake = Rack::Auth::Basic.new(fake) do |user, pass|
      user == email && password == pass
    end

    LibGems.host = "http://localhost:9292"
    start_fake(protected_fake)
  end

  it "says email that user is logging in as" do
    bpm "package", "login"
    input email
    input password
    output = stdout.read
    output.should include("Enter your bpm credentials.")
    output.should include("Logging in as #{email}...")
  end

  it "makes a request out for the api key and stores it in BPM_DIR/credentials" do
    bpm "package", "login"
    input email
    input password

    stdout.read.should include("Logged in!")
    File.exist?(creds).should be_true
    YAML.load_file(creds)[:bpm_api_key].should == api_key
    YAML.load_file(creds)[:bpm_email].should == email
  end

  it "notifies user if bad creds given" do
    bpm "package", "login", :track_stderr => true
    input email
    input "badpassword"
    sleep 1
    kill!

    stdout.read.should include("Incorrect email or password.")
    File.exist?(creds).should be_false
  end

  it "allows the user to retry if bad creds given" do
    bpm "package", "login"
    input "bademail@example.com"
    input "badpassword"

    input email
    input password

    output = stdout.read.split("\n").select { |line| line.size > 0 }
    output[0].should include("Enter your bpm credentials.")
    output[3].should include("Logging in as bademail@example.com...")
    output[4].should include("Incorrect email or password.")
    output[5].should include("Enter your bpm credentials.")
    output[8].should include("Logging in as #{email}...")
    output[9].should include("Logged in!")

    File.exist?(creds).should be_true
    YAML.load_file(creds)[:bpm_api_key].should == api_key
    YAML.load_file(creds)[:bpm_email].should == email
  end
end
