class Timer
  
  def initialize(resolution)
    @resolution = resolution
    @queue = []

    Thread.new do
      loop do
        dispatch
        sleep @resolution
      end
    end
  end

  def at(time, &block)
    @queue << [ time.to_f, block ]
  end

  private
  def dispatch
    now = Time.now.to_f
    jobs_to_run, @queue = @queue.partition { |time, job| time <= now}
    jobs_to_run.each { |time, job| job.call }
  end
  
end
