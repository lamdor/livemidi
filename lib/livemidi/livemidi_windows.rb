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
    C.midiOutClose(@device.ptr.to_i)
  end
end
