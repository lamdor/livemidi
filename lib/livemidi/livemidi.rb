class LiveMidi
  ON = 0x90

  def note_on(channel, note, velocity = 64)
    message(ON | channel, note, velocity)
  end
  
end
