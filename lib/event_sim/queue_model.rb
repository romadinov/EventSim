# Building blocks for queueing models

require_relative 'event_sim'
require_relative 'simple_queues'
require_relative 'prob_distribs'

class QueueNetworkNode
   
  def initialize (next_node)
    @next_node=next_node
    if next_node then
      next_node._set_prev_node self
    end
  end

  def _set_prev_node node
    @prev_node=node
  end
  
  def prev_node
    @prev_node
  end
  
  def next_node
    @next_node
  end
  
  def set_departure_probe(&probe)
    @departure_probe=probe
  end
  
  def set_arrival_probe(&probe)
    @arrival_probe=probe
  end
  
  def arrival(simEngine, event)
    if @arrival_probe
      @arrival_probe.call(self, simEngine, event)
    end
  end
  
  def departure(simEngine, event)
    if @departure_probe
      @departure_probe.call(self, simEngine, event)
    end
  end  

  def activate(simEngine, event)    
    if @next_node then
      @next_node.activate simEngine, event
    end
  end
  
end 

class QueueNodeEvent < Event
  
  def initialize(next_node)
    super()
    @next_node=next_node
  end
  
  def fire(simEngine, fire_time)
    super(simEngine, fire_time)
#    puts "Activate #{self.id}"
    if @next_node then
      @next_node.activate(simEngine, @event)
    end
  end
  
end

class RequestSourceEvent < QueueNodeEvent
  
  def initialize(simEngine, next_node, event_generator)
    super (next_node)
    @event_generator=event_generator
    @event=@event_generator.call(simEngine)    
  end
  
  def id
    @event.id
  end
  
  def estimate_delay(simEngine)
    @event.estimate_delay(simEngine)
  end
  
  def fire(simEngine, fire_time)
    @event.fire(simEngine, fire_time)   
    super(simEngine, fire_time)
    
    @event=@event_generator.call(simEngine) 
    simEngine << self
  end
  
end
  

class RequestSource < QueueNetworkNode 
  
  def initialize(next_node, &event_generator)
    super (next_node)
    @event_generator=event_generator
  end

  def activate(simEngine)
    event=RequestSourceEvent.new(simEngine, @next_node, @event_generator)
    simEngine << event
  end
  
end

class ModelQueue < QueueNetworkNode
  
  def initialize(next_node)
    super(next_node)
    @size=0
    @queue=FIFOQueue.new
  end
  
  def activate(simEngine, event)
    if @next_node.busy? then
      @size+=1
      @queue << event  
      
      arrival(simEngine, event)    
    else
      arrival(simEngine, event)
      departure(simEngine, event)
      super(simEngine, event)
    end
  end
  
  def size 
    @size
  end
  
  def empty?
    @queue.empty?
  end
  
  def pull_event(simEngine)
    @size-=1
    event=@queue.get_next
    
    departure(simEngine, event)
    event
  end
  
end

class ModelDeviceEvent < QueueNodeEvent 
  
  def initialize(next_node, device, event, orig_event)
    super(next_node)
    @device=device
    @event=event
    @orig_event=orig_event
  end
  
  def id
    @event.id
  end
  
  def estimate_delay(simEngine)
    @event.estimate_delay simEngine
  end
  
  def fire(simEngine, time)
    @event.fire simEngine, time
#    ap @event
#    puts simEngine.time
    @device.departure(simEngine, @orig_event)
    @device.pull_event simEngine
    super simEngine, time
  end
    
end

class ModelDevice < QueueNetworkNode
  
  def initialize(next_node, &event_processor)
    super(next_node)
    @busy=false
    @event_processor=event_processor
  end
  
  def busy?
    @busy
  end
  
  def activate(simEngine, event)
    @busy=true
    arrival(simEngine, event)
    wait_event=@event_processor.call(simEngine, event)
    simEngine << ModelDeviceEvent.new(@next_node, self, wait_event, event)
    super(simEngine, event)
  end
  
  def pull_event(simEngine)
    if @prev_node.empty? then
      @busy=false
    else 
      self.activate simEngine, @prev_node.pull_event(simEngine)
    end
  end
  
end

class TestEvent < ProbEvent
  
  attr_accessor :id, :cause_event
  
  def initialize(id, prob_d, cause_event)
    super (prob_d)
    @id=id
    @cause_event=cause_event
  end
  
  def fire(simEngine, fire_time)
    super(simEngine, fire_time)
#   puts "#{@id} is fired at #{fire_time}"
  end
end

class TimedMeanCalculator
  
  def initialize
    @sum=0
    @time=0
  end
  
  def add_measure (x, t)
    @sum+=x
    @time=t
  end
  
  def mean 
    if @time==0
      0
    else
      @sum/@time
    end
  end
      
end

class CountedMeanCalculator
  
  def initialize
    @sum=0
    @n=0
  end
  
  def <<  (x)
    @sum+=x
    @n+=1
  end
  
  def mean 
    if @n==0
      0
    else
      @sum/@n
    end
  end
      
end

waiting_time=CountedMeanCalculator.new
queue_size=TimedMeanCalculator.new

simEngine=SimEngine.new(0)

cnt=0

queue=ModelQueue.new (device=ModelDevice.new(nil) { |simEngine, event|  TestEvent.new(event.id+" processed", exp_d(0.5), event)})
queue.set_arrival_probe do |queue, simEngine, event|
# puts "Probe #{simEngine.time} #{queue.size}"
  queue_size.add_measure queue.size, simEngine.time
end

device.set_departure_probe do |queue, simEngine, event|
#  ap event
  wt=simEngine.time-event.fire_time
#  puts wt
  waiting_time << wt
end

requestSource=RequestSource.new(queue) do |simEngine|
  cnt+=1
  TestEvent.new("test event#{cnt}", exp_d(0.25), nil)
end

requestSource.activate simEngine

1.upto(10000) do
  simEngine.tick
end

puts "Rho: #{0.25/0.5}"
puts "Queue Size: #{queue_size.mean}"
puts "Response Time: #{waiting_time.mean}"