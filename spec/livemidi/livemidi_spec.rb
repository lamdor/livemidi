require File.join(File.dirname(__FILE__), *%w[.. spec_helper])
require "livemidi/livemidi"

describe LiveMidi do

  before :each do
    @livemidi = LiveMidi.new
  end

  describe "#note_on" do

    it "should send a message | against 0x90 on the selected channel with the note and the default velocity of 64" do
      @livemidi.should_receive(:message).with(0x90 | 12, 60, 64)
      @livemidi.note_on(12, 60)
    end

    it "should send the velocity if given" do
      @livemidi.should_receive(:message).with(0x90 | 12, 60, 100)
      @livemidi.note_on(12, 60, 100)
    end
    
  end
  
end
