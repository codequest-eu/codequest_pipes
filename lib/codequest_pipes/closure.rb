module Pipes
  # Closure provides a quick and dirty way of turning a block into an example of
  # Pipes::Pipe.
  class Closure
    def self.define(&block)
      Class.new(Pipe) { define_method(:call, block) }
    end
  end # class Closure
end # module Pipes
