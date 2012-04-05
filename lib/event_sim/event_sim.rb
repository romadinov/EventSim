require "priority_queue"
require "awesome_print"

class Event
	def initialize()
	end

	def fire(simEngine, fire_time) 
		# Do nothing
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
		time_to_fire=@time+event.estimate_delay(self)
		@events.push event, time_to_fire
	end

	def <<(event)
		self.add_event(event)
	end

	def tick()
		if !@events.empty? then
			node=@events.delete_min
			event=node[0]
			event.fire(self, node[1])
			time=node[1]
			node
		end
	end

end