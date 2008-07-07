require 'livemidi/util/hookable'

class LiveMidi
  ON = 0x90
  OFF = 0x80
  PROGRAM_CHANGE = 0xC0

  include Hookable

  def initialize
    run_hooks :initialize
  end

  def note_on(channel, note, velocity = 64)
    message(ON | channel, note, velocity)
  end
  
  def note_off(channel, note, velocity = 64)
    message(OFF | channel, note, velocity)
  end

  def program_change(channel, preset)
    message(PROGRAM_CHANGE | channel, preset)
  end
  
end

class LiveMidi
  class UnsupportedPlatformException < Exception
  end
end

case RUBY_PLATFORM
  when /windows/
  load "livemidi/livemidi_windows.rb"
  when /linux/
  load "livemidi/livemidi_linux.rb"
  when /darwin/
  load "livemidi/livemidi_darwin.rb"
  else
  raise LiveMidi::UnsupportedPlatformException
end
