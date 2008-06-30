class LiveMidi
  ON = 0x90
  OFF = 0x80

  def note_on(channel, note, velocity = 64)
    message(ON | channel, note, velocity)
  end
  
  def note_off(channel, note, velocity = 64)
    message(OFF | channel, note, velocity)
  end

  def program_change(channel, preset)
    message(0xC0 | channel, preset)
  end
  
end
