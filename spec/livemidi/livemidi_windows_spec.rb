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
    @mock_device.stub!(:ptr).and_return("100")
    @livemidi.instance_variable_set(:@device, @mock_device)
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
      LiveMidi::C.should_receive(:midiOutClose).with(100)
      @livemidi.close
    end
  end

  describe "#message" do
    it "should call C.midiOutShortMsg with the device and the integer passed in" do
      LiveMidi::C.should_receive(:midiOutShortMsg).with(100, 2)
      @livemidi.message(2)
    end

    it "should byte push the second over the first message" do
      LiveMidi::C.should_receive(:midiOutShortMsg).with(100, 2 + (3 << 8))
      @livemidi.message(2,3)
    end

    it "should open if hasn't created a device yet" do
      @livemidi.instance_variable_set(:@device, nil)

      DL.stub!(:malloc).and_return(@mock_device)
      LiveMidi::C.should_receive(:midiOutOpen).with(@mock_device, -1, 0, 0, 0)

      LiveMidi::C.should_receive(:midiOutShortMsg).with(100, 2)
      @livemidi.message(2)
    end

    it "should byte push the thirde over the first and second messages" do
      LiveMidi::C.should_receive(:midiOutShortMsg).with(100, 2 + (3 << 8)+  (4 << 16))
      @livemidi.message(2,3, 4)
    end

  end
  
end
