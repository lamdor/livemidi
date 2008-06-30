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
  
end
