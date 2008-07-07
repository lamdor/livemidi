class LiveMidi
  ON = 0x90
  OFF = 0x80
  PROGRAM_CHANGE = 0xC0

  @@hooks =  { }
  def self.add_hook_for(step, method_name)
    @@hooks[step] ||= []
    @@hooks[step] << method_name
  end

  def run_hooks(step)
    if @@hooks[step]
      @@hooks[step].each { |method_name| self.send(method_name.to_sym) }
    end
  end

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
