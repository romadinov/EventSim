# Probability distributions
# Assuming Ruby 1.9.3

class UniformDistribution 

	def initialize(a,b) 
		@a=a
		@b=b
	end

	def generate 
		rand(@a..@b)
	end

end

def uniform_d(a,b)
	UniformDistribution.new(a,b)
end

class ExpDistribution

	def initialize(lambda)
		@lambda=lambda
	end

	def generate 
		-1.0/@lambda*Math.log(rand())
	end

end

def exp_d(lambda)
	return ExpDistribution.new(lambda)
end