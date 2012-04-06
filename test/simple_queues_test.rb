# Unit test for FIFOQueue and (eventually) LIFO Queue

require "test/unit"
require "awesome_print"

require_relative "../lib/event_sim/simple_queues"

class LinkedListTest < Test::Unit::TestCase
  def test_empty_linked_list
    ll=LinkedList.new
    assert(ll.empty?, "Empty linked list is not empty")
  end
  
  def test_append_one
    ll=LinkedList.new
    ll.append "1"
    assert(!ll.empty?, "1 element linked list is empty")
    assert(ll.first_node!=nil, "First node is nil")
    assert(ll.last_node!=nil, "Last node is nil")
    assert_equal(ll.first_node.data, "1")
    assert_equal(ll.last_node.data, "1")
  end
  
  def test_append_3
    ll = LinkedList.new
    ll.append "1"
    ll.append "2"
    ll.append "3"
    assert(!ll.empty?, "1 element linked list is empty")
    assert_equal(ll.first_node.data, "1")
    assert_equal(ll.last_node.data, "3")
  end

  def test_prepend_one
    ll = LinkedList.new
    ll.prepend "1"
    assert(!ll.empty?, "1 element linked list is empty")
    assert(ll.first_node!=nil, "First node is nil")
    assert(ll.last_node!=nil, "Last node is nil")
    assert_equal(ll.first_node.data, "1")
    assert_equal(ll.last_node.data, "1")
  end

  def test_append_3
    ll = LinkedList.new
    ll.prepend "1"
    ll.prepend "2"
    ll.prepend "3"
    assert(!ll.empty?, "1 element linked list is empty")
    assert_equal(ll.first_node.data, "3")
    assert_equal(ll.last_node.data, "1")
  end

  def test_append_delete_first
    ll = LinkedList.new
    ll.append "1"
    assert_equal(ll.delete_first.data, "1")
    assert(ll.empty?, "List is not empty")
    assert_equal(ll.first_node, nil)
    assert_equal(ll.last_node, nil)
  end

  def test_append_remove_last
    ll = LinkedList.new
    ll.append "1"
    assert_equal(ll.delete_last.data, "1")
    assert(ll.empty?, "List is not empty")
    assert_equal(ll.first_node, nil)
    assert_equal(ll.last_node, nil)
  end
  
  def test_prepend_delete_first
    ll = LinkedList.new
    ll.prepend "1"
    assert_equal(ll.delete_first.data, "1")
    assert(ll.empty?, "List is not empty")
    assert_equal(ll.first_node, nil)
    assert_equal(ll.last_node, nil)
  end

  def test_append_delete_last
    ll = LinkedList.new
    ll.prepend "1"
    assert_equal(ll.delete_last.data, "1")
    assert(ll.empty?, "List is not empty")
    assert_equal(ll.first_node, nil)
    assert_equal(ll.last_node, nil)
  end
  
  def test_append_prepend_append_delete_last_delete_first
    ll = LinkedList.new
    ll.append "1"
    ll.prepend "2"
    ll.append "3"
    
    assert_equal("3", ll.delete_last.data)
    assert_equal("2", ll.delete_first.data)
    assert_equal("1", ll.delete_last.data)
    assert(ll.empty?, "List is not empty")
  end
  
end

class FIFOQueueTest < Test::Unit::TestCase
  def test_fifo
    queue=FIFOQueue.new
    assert(queue.empty?, "Initial queue is not empty")
    queue << "1"
    queue << "2"
    assert(!queue.empty?, "Filled queue is not empty")
    assert_equal("1", queue.pick_next)
    assert_equal("1", queue.get_next)
    queue << "3" 
    assert_equal("2", queue.get_next)
    assert_equal("3", queue.get_next)
    assert(queue.empty?, "Empty queue is not empty")
  end
end
