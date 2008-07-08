$:.unshift File.join(File.dirname(__FILE__), "/../lib")
require 'livemidi/livemidi'
require 'livemidi/timer'

class Metronome
  def initialize(bpm)
    @midi = LiveMidi.new
    @midi.program_change(0, 115)
    @interval = 60.0 / bpm
    @timer = Timer.new(@interval / 10)

    now = Time.now.to_f
    register_next_bang(now)
  end

  def register_next_bang(time)
    @timer.at(time) do
      now = Time.now.to_f
      register_next_bang(now + @interval)
      bang
    end
  end

  def bang
    @midi.note_on(0,84, 100)
    sleep 0.1
    @midi.note_off(0,84, 100)
  end
end
