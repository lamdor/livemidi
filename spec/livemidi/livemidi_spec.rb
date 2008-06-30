require File.join(File.dirname(__FILE__), *%w[.. spec_helper])
require "livemidi/livemidi"


describe LiveMidi do

  before :each do
    @livemidi = LiveMidi.new
    @livemidi.extend MessageCatcher
  end

  describe "#note_on" do

    it "should send a message | against 0x90 on the selected channel with the note and the default velocity of 64" do
      @livemidi.note_on(12, 60)
      @livemidi.should have(1).sent_messages
      @livemidi.sent_messages.should include([0x90 | 12, 60, 64])
    end

    it "should send the velocity if given" do
      @livemidi.note_on(12, 60, 100)
      @livemidi.should have(1).sent_messages
      @livemidi.sent_messages.should include([0x90 | 12, 60, 100])
    end
    
  end

  describe "#note_off" do
        
    it "should send a message | against 0x80 on the selected channel with the note and the default velocity of 64" do
      @livemidi.note_off(12, 60)
      @livemidi.should have(1).sent_messages
      @livemidi.sent_messages.should include([0x80 | 12, 60, 64])
    end

    it "should send the velocity if given" do
      @livemidi.note_off(12, 60, 100)
      @livemidi.should have(1).sent_messages
      @livemidi.sent_messages.should include([0x80 | 12, 60, 100])
    end

  end

  describe "#program_change" do

    it "should send a program change message on the correct channel with the passed preset" do
      @livemidi.program_change(1, 20)
      @livemidi.should have(1).sent_messages
      @livemidi.sent_messages.should include([0xC0 | 1, 20])
    end
    
  end
  
end
