# Test Suite for distributions

require_relative '../lib/event_sim/prob_distribs'
require 'test/unit'

def mean n
  sum=0
  1.upto(n) do
    sum+=yield
  end

  sum/n
end

class UniformDistributionTest < Test::Unit::TestCase 

  def test_uniform

    uniform=uniform_d(10, 110)

    m=mean 10000 do 
      uniform.generate 
    end

    assert (m-60).abs<0.1

  end

end

class ExpDistributionTest < Test::Unit::TestCase 

  def test_exp

    uniform=exp_d(0.5)

    m=mean 10000 do 
      uniform.generate 
    end

    assert (m-2).abs<0.1

  end

end