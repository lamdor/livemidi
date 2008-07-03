require 'dl/import'

class NoNumberOfDestinations < Exception
end

class LiveMidi
  module C
    extend DL::Importable

    dlload "/System/Library/Frameworks/CoreMidi.framework/Versions/Current/CoreMIDI"

    extern "int MIDIClientCreate(void *, void *, void *, void *)"
    extern "int MIDIClientDispose(void *)"
    extern "int MIDIGetNumberOfDestinations()"
    extern "void * MIDIGetDestination(int)"
    extern "int MIDIOutputPortCreate(void *, void *, void *)"
    extern "void * MIDIPacketListInit(void *)"
    extern "void * MIDIPacketListAdd(void *, int, void *, int, int, int, void *)"
    extern "int MIDISend(void *, void *, void *)"
  end

  module CF
    extend DL::Importable
    dlload "/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation"
    
    extern "void * CFStringCreateWithCString(void *, char *, int)"
  end


  def open
    client_name = CF.cFStringCreateWithCString(nil, "RubyMIDI", 0)
    @client = DL::PtrData.new(nil)
    C.mIDIClientCreate(client_name, nil, nil, @client.ref)
    
    output_name = CF.cFStringCreateWithCString(nil, "Output", 0)
    @output = DL::PtrData.new(nil)
    C.mIDIOutputPortCreate(@client, output_name, @output.ref)

    num_dest =LiveMidi::C.mIDIGetNumberOfDestinations
    raise NoNumberOfDestinations unless num_dest > 0
    @destination = LiveMidi::C.mIDIGetDestination(0)
  end
end
