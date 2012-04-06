# Simple queues: FIFO and LIFO

require "awesome_print"

class QueueNode 
  
  attr_accessor :data, :next_node, :prev_node
  
  def initialize(data, prev_node, next_node) 
    @prev_node=prev_node
    @next_node=next_node
    @data=data
  end
  
end

class LinkedList 
  
  def initialize
    @first_node=nil
    @last_node=nil
  end
  
  def empty?
    @last_node==nil
  end
  
  def append(data)
    node=QueueNode.new(data, @last_node, nil)
    
    if @last_node!=nil then
      @last_node.next_node=node
    end
    
    @last_node=node
    
    if @first_node == nil then
      @first_node=@last_node
    end
  end
  
  def prepend(data)
    node=QueueNode.new(data, nil, @first_node)
    
    if @first_node!=nil then
      @first_node.prev_node=node
    end
    
    @first_node=node
    
    if @last_node == nil then
      @last_node=@first_node
    end
    
  end
  
  def first_node
    @first_node
  end
  
  def last_node  
    @last_node
  end
    
  def delete_first
    node=@first_node
    
    if node!=nil then
      @first_node=node.next_node
      
      if @first_node!=nil then
        @first_node.prev_node=nil
      end     
    end
    
    if node==@last_node then
      # One element list
      @last_node=nil
    end
    
    node
    
  end
  
  def delete_last 
    node=@last_node
    
    if node!=nil then
      @last_node=node.prev_node
      
      if @last_node!=nil then
        @last_node.next_node=nil
      end   
    end
    
    if node==@first_node then
      # One element list
      @first_node=nil
    end
    
    node
    
  end
  
  def debug_print 
    node=@first_node
    
    while node!=nil do 
      puts "Node #{node.data}"
      
      print "Prev: "
      if node.prev_node!=nil then
        puts node.prev_node.data
      else
        puts "Nil"
      end
      
      print "Next: "
      if node.next_node!=nil then
        puts node.next_node.data
      else
        puts "Nil"
      end

      node=node.next_node
    end
    
  end
  
end 

class FIFOQueue 
  
  def initialize 
    @queue=LinkedList.new
  end
  
  def << (data)
    @queue.append(data)
  end
  
  def empty?
    @queue.empty?
  end
  
  def pick_next
    @queue.first_node.data
  end
  
  def get_next
    @queue.delete_first.data
  end
  
  def debug_print
    @queue.debug_print
  end
  
end