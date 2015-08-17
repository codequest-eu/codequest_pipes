module Pipes
  # Closure provides a quick and dirty way of turning a block into an example of
  # Pipes::Pipe.
  class Closure
    def self.define(name, &block)
      new_pipe = Class.new
      new_pipe.include(Pipe)
      new_pipe.define_singleton_method(name, block)
      new_pipe
    end
  end  # class Closure
end  # module Pipes
