require File.join(File.dirname(__FILE__), *%w[.. spec_helper])


class LiveMidi
  module C
  end
end

describe "LiveMidi on Windows" do

  describe LiveMidi::C do
    it "should load winmm libraries, and link to the 'int midiOut*' methods" do
      LiveMidi::C.should_receive(:dlload).with("winmm")
      LiveMidi::C.should_receive(:extern).with("int midiOutOpen(HDMIDIOUT*, int, int, int, int)")
      LiveMidi::C.should_receive(:extern).with("int midiOutClose(int)")
      LiveMidi::C.should_receive(:extern).with("int midiOutShortMsg(int,int)")
      load 'livemidi/livemidi_windows.rb'
    end
  end

  before :each do
    @livemidi = LiveMidi.new
    @mock_device = mock("device")
  end

  describe "#open" do
    it "should call C.midiOutOpen with a newly allocated device pointer to an integer" do
      DL.stub!(:malloc).and_return(@mock_device)
      LiveMidi::C.should_receive(:midiOutOpen).with(@mock_device, -1, 0, 0, 0)
      @livemidi.open
    end
  end

  describe "#close" do
    it "should call C.midiOutClose with the device it was created with" do
      @livemidi.instance_variable_set(:@device, @mock_device)
      @mock_device.should_receive(:ptr).and_return("100")
      LiveMidi::C.should_receive(:midiOutClose).with(100)
      @livemidi.close
    end
  end
  
end
