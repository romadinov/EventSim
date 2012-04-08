require "priority_queue"
require "awesome_print"

class Event
  
  attr_accessor :fire_time
  
	def initialize()
	end

	def fire(simEngine, fire_time) 
		@fire_time=fire_time
	end

	def estimate_delay(simEngine) 
		0
	end

end

class ProbEvent < Event 

	def initialize(prob)
		@prob=prob
	end

	def estimate_delay(simEngine)
		@prob.generate
	end
end

class SimEngine 

	def initialize(start_time)
		@events=PriorityQueue.new
		@time=start_time
	end

	def add_event(event)
#	  puts @time
	  delay=event.estimate_delay(self)
		time_to_fire=@time+delay
#    puts "Add event #{time_to_fire} #{event.id} #{delay}"
		@events.push event, time_to_fire
	end

	def <<(event)
		self.add_event(event)
	end
	
	def time
	  @time
  end

	def tick()
#	  puts @time
		if !@events.empty? then
			node=@events.delete_min
			event=node[0]
#			puts "Fire!"
      @time=node[1]
#      event.fire_time=@time
			event.fire(self, node[1])
			node
		end
	end

end