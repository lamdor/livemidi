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

  add_hook_for :initialize, :open
  def open
    client_name = CF.cFStringCreateWithCString(nil, "RubyMIDI", 0)
    @client = DL::PtrData.new(nil)
    C.mIDIClientCreate(client_name, nil, nil, @client.ref)
    
    output_name = CF.cFStringCreateWithCString(nil, "Output", 0)
    @outport = DL::PtrData.new(nil)
    C.mIDIOutputPortCreate(@client, output_name, @outport.ref)

    num_dest = C.mIDIGetNumberOfDestinations
    raise NoNumberOfDestinations unless num_dest > 0
    @destination = C.mIDIGetDestination(0)
  end

  def close
    C.mIDIClientDispose(@client)
  end

  def message(*args)
    format = "C" * args.size
    bytes = args.pack(format).to_ptr

    packet_list = DL.malloc(256)
    packet_list_ptr = C.mIDIPacketListInit(packet_list)

    C.mIDIPacketListAdd(packet_list, 256, packet_list_ptr, 0, 0, args.size, bytes)
    C.mIDISend(@outport, @destination, packet_list)
  end
  
end
