require 'dl/import'

class LiveMidi
  module C
    extend DL::Importable
    dlload 'winmm'
    
    extern "int midiOutOpen(HDMIDIOUT*, int, int, int, int)"
    extern "int midiOutClose(int)"
    extern "int midiOutShortMsg(int,int)"
  end

  def open
    @device = DL.malloc(DL.sizeof('I'))
    C.midiOutOpen(@device, -1, 0, 0, 0)
  end

  def close
    C.midiOutClose(device_pointer)
  end

  def message(*to_send)
    message = 0
    to_send.each_with_index do |send, index| 
      message += (send << (8 * index))
    end
    C.midiOutShortMsg(device_pointer, message)
  end

  def device_pointer
    @device.ptr.to_i
  end
end
