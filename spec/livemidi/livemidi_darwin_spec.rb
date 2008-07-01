require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

class LiveMidi
  module C
  end

  module CF
  end
end


describe LiveMidi do

  def expect_c_extern(method)
    LiveMidi::C.should_receive(:extern).with(method)
  end

  it "should link to libraries" do
    LiveMidi::C.should_receive(:dlload).with("/System/Library/Frameworks/CoreMidi.framework/Versions/Current/CoreMIDI")

    expect_c_extern "int MIDIClientCreate(void *, void *, void *, void *)"
    expect_c_extern "int MIDIClientDispose(void *)"
    expect_c_extern "int MIDIGetNumberOfDestinations()"
    expect_c_extern "void * MIDIGetDestination(int)"
    expect_c_extern "int MIDIOutputPortCreate(void *, void *, void *)"
    expect_c_extern "void * MIDIPacketListInit(void *)"
    expect_c_extern "void * MIDIPacketListAdd(void *, int, void *, int, int, int, void *)"
    expect_c_extern "int MIDISend(void *, void *, void *)"

    LiveMidi::CF.should_receive(:dlload).with("/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation")

    LiveMidi::CF.should_receive(:extern).with("void * CFStringCreateWithCString(void *, char *, int)")
    
    load "livemidi/livemidi_darwin.rb"
  end

end
