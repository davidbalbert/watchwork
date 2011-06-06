module Watchwork
  VERSION = "0.0.1"

  class NoHandlerDefined < StandardError; end

  extend self

  @@jobs = []

  def handler(&handler)
    @@handler = handler
  end

  def get_handler
    raise NoHandlerDefined unless (defined?(@@handler) and @@handler)
    @@handler
  end

  def every(interval, job, &block)
    job = Job.new(interval, job, block || get_handler)
    @@jobs << job
    #job
  end

  def run
    loop do
      tick
      sleep 1
    end
  end

  def tick(t=Time.now)
    jobs_to_run = @@jobs.select do |job|
      job.should_run?(t)
    end

    jobs_to_run.each do |job|
      job.run
    end

    jobs_to_run
  end

  class Job
    attr_accessor :interval, :job, :handler
    def initialize(interval, job, handler)
      @interval = interval
      @job = job
      @handler = handler
      @last = nil
    end

    def should_run?(t)
      @last.nil? || (t - @last > @interval)
    end

    def run
      @last = Time.now
      @handler.call(@job)
    end
  end

end

class Numeric
  def seconds; self; end
  alias :second :seconds

  def minutes; self * 60; end
  alias :minute :minutes

  def hours; self * 3600; end
  alias :hour :hours

  def days; self * 86400; end
  alias :day :days
end
