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

  describe "platform loading" do

    def should_have_loaded(some_file)
      $LOADED_FEATURES.should include(some_file)
    end

    before :each do
      class Object
        ORIGINAL_RUBY_PLATFORM = RUBY_PLATFORM
        remove_const "RUBY_PLATFORM"

        alias :old_load :load

        def load(file)
          $LOADED_FEATURES << file
        end
      end
    end

    after :each do
      class Object
        RUBY_PLATFORM = ORIGINAL_RUBY_PLATFORM

        undef_method :load
        alias :load :old_load
      end
    end
    
    it "should load livemidi_windows if the PLATFORM is a variant of windows" do
      RUBY_PLATFORM = "windows"
      old_load "livemidi/livemidi.rb"
      should_have_loaded "livemidi/livemidi_windows.rb"
    end
    
    it "should load livemidi_linux if the PLATFORM is a variant of linux" do
      RUBY_PLATFORM = "linux"
      old_load "livemidi/livemidi.rb"
      should_have_loaded "livemidi/livemidi_linux.rb"
    end
    
    it "should load livemidi_darwin if the PLATFORM is a variant of darwin/OSX" do
      RUBY_PLATFORM = "darwin"
      old_load "livemidi/livemidi.rb"
      should_have_loaded "livemidi/livemidi_darwin.rb"
    end

    it "should through an UnsupportedPlatformException if it doesn't understand the platform" do
      RUBY_PLATFORM = "unsupprted"
      lambda { old_load "livemidi/livemidi.rb" }.should raise_error(LiveMidi::UnsupportedPlatformException)
    end
      
  end

  describe "hooks for initialize" do

    it "should add a hook" do
      class LiveMidi
        add_hook_for :initialize, :open

        attr_reader :open_called
        def open
          @open_called = true
        end
      end

      livemidi = LiveMidi.new
      livemidi.open_called.should be_true
    end
    
  end
  
end
