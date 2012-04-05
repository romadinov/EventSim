require_relative '../lib/event_sim/event_sim'
require 'test/unit'

class TestSimEngine < SimEngine
 	attr_accessor :fired_events

 	def fire(event)
 		@fired_events << event
 	end

end

class TestEvent < Event 
	attr_accessor :id
	def initialize(delay, id)
		@id=id;
		@delay=delay
	end

	def fire(simEngine, fire_time)
		puts "#{@id} fired at #{fire_time}"
	end

	def estimate_delay(simEngine)
		@delay
	end

	def ==(another_event)
		puts "1111"
		@id==another_event.id
	end
end

class TestPoisson < PoissonEvent
	def initialize(lambda, id)
		super(lambda)
		@id=id
	end

	def fire(simEngine, fire_time)
		puts "#{@id} fired at #{fire_time}"
	end

	def ==(another_event)
		@id==another_event.id
	end
end

class PoissonEventsTest < Test::Unit::TestCase

	def test_poisson_events

		sum=0

		event=PoissonEvent.new 0.5

		1.upto(100000) do |x|
			sum+=event.estimate_delay(nil)
		end 

		assert ((sum/100000-2).abs<0.1)

	end

end

class EventSimTest < Test::Unit::TestCase
 
  def test_simple
    	simEngine=SimEngine.new 0
    	simEngine << (e1=TestEvent.new(100.1, "1"))
    	simEngine << (e2=TestEvent.new(10.1, "2"))
    	simEngine << (e3=TestEvent.new(1000.1, "3"))

 		assert_equal simEngine.tick()[0], e2
 		assert_equal simEngine.tick()[0], e1
 		assert_equal simEngine.tick()[0], e3
  end

  def test_poisson 
  	   	simEngine=TestSimEngine.new 0
    	simEngine << (e1=TestPoisson.new(0.5, "1"))
    	simEngine << (e2=TestPoisson.new(0.5, "2"))
    	simEngine << (e3=TestPoisson.new(0.5, "3"))

    	while simEngine.tick do
    	end

    	assert_equal Hash.new(simEngine.fired_events), Hash.new([e1, e2, e3]) 
 	end	
 
end