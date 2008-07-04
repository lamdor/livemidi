require File.join(File.dirname(__FILE__), *%w[.. spec_helper])
require 'dl/import'

class LiveMidi
  module C
  end

  module CF
  end
end


describe LiveMidi do

  describe "dl loading" do
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

  describe "#open" do

    before :each do
      @mock_client = mock("client")
      @mock_output = mock("output")
      
      DL::PtrData.should_receive(:new).with(nil).exactly(2).and_return(@mock_client, @mock_output)
      
      LiveMidi::CF.should_receive(:cFStringCreateWithCString).with(nil, "RubyMIDI", 0).and_return("Client Name")
      LiveMidi::CF.should_receive(:cFStringCreateWithCString).with(nil, "Output", 0).and_return("Output name")

      mock_client_ref = mock("client ref")
      @mock_client.stub!(:ref).and_return(mock_client_ref)
      LiveMidi::C.should_receive(:mIDIClientCreate).with("Client Name", nil, nil, mock_client_ref)

      mock_output_ref = mock("output ref")
      @mock_output.should_receive(:ref).and_return(mock_output_ref)
      LiveMidi::C.should_receive(:mIDIOutputPortCreate).with(@mock_client, "Output name", mock_output_ref)

      @mock_destination = mock("destination")

      @live_midi = LiveMidi.new
    end

    it "should set a client with a name of \"RubyMIDI\"" do
      LiveMidi::C.should_receive(:mIDIGetNumberOfDestinations).once.and_return(1)
      LiveMidi::C.should_receive(:mIDIGetDestination).once.with(0).and_return(@mock_destination)

      @live_midi.open

      @live_midi.instance_variable_get(:@client).should eql(@mock_client)
    end

    it "should set a outport with a name of 'Output'" do
      LiveMidi::C.should_receive(:mIDIGetNumberOfDestinations).once.and_return(1)
      LiveMidi::C.should_receive(:mIDIGetDestination).once.with(0).and_return(@mock_destination)

      @live_midi.open

      @live_midi.instance_variable_get(:@outport).should eql(@mock_output)
    end

    it "should get a destination" do
      LiveMidi::C.should_receive(:mIDIGetNumberOfDestinations).once.and_return(1)
      LiveMidi::C.should_receive(:mIDIGetDestination).once.with(0).and_return(@mock_destination)
      @live_midi.open

      @live_midi.instance_variable_get(:@destination).should eql(@mock_destination)
    end

    it "should raise a NoMIDIDestionaions if it doesn't get any destinations" do
      LiveMidi::C.should_receive(:mIDIGetNumberOfDestinations).and_return(0)
      LiveMidi::C.should_not_receive(:mIDIGetDestination)

      lambda { @live_midi.open }.should raise_error(NoNumberOfDestinations)
    end
    
  end

  describe "#close" do
    
    it "should dispose of the client" do
      mock_client = mock("Client")
      
      live_midi = LiveMidi.new
      live_midi.instance_variable_set(:@client, mock_client)

      LiveMidi::C.should_receive(:mIDIClientDispose).with(mock_client)
      
      live_midi.close
    end
    
  end

  describe "#message" do

    before :each do
      @args = [144, 64]
      @args.should
      
      @live_midi = LiveMidi.new
      
      @mock_packet_list_ptr = mock("Packet List Pointer")
      @mock_packet_list = mock("Packet List")

      LiveMidi::C.stub!(:mIDIPacketListInit).and_return(@mock_packet_list_ptr)
      DL.stub!(:malloc).and_return(@mock_packet_list)
      LiveMidi::C.stub!(:mIDIPacketListAdd).and_return(@mock_packet_list_ptr)
      LiveMidi::C.stub!(:mIDISend)
    end

    it "should init a MIDI packet list of size 256" do
      DL.should_receive(:malloc).with(256).and_return(@mock_packet_list)
      LiveMidi::C.should_receive(:mIDIPacketListInit).with(@mock_packet_list).and_return(@mock_packet_list_ptr)

     @live_midi.message(*@args)
    end

    it "should add the unpacked arguments to the MIDI packet list" do
      bytes = @args.pack("CC").to_ptr
      LiveMidi::C.should_receive(:mIDIPacketListAdd).with(@mock_packet_list, 256, @mock_packet_list_ptr, 0, 0, 2, anything()).and_return(@mock_packet_list_ptr)
      @live_midi.message(*@args)
    end

    it "should send the packet list to the outport and destination" do
      mock_outport = mock("Outport")
      mock_destination = mock("Destination")
      @live_midi.instance_variable_set(:@outport, mock_outport)
      @live_midi.instance_variable_set(:@destination, mock_destination)
      
      LiveMidi::C.should_receive(:mIDISend).with(mock_outport, mock_destination, @mock_packet_list)
      @live_midi.message(*@args)
    end
    
  end

end
