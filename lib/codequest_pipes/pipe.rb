module Pipes
  # Pipe is a mix-in which turns a class into a Pipes building block (Pipe).
  # A Pipe can only have class methods since it can't be instantiated.
  module Pipe
    def self.included(base)
      base.extend(ClassMethods)
    end

    # The initializer here is overridden so that you can not instantiate classes
    # that mix in Pipe.
    def initialize
      fail InstanceError, 'Pipes are not supposed to be instantiated'
    end

    # ClassMethods provides the most important feature of the whole libary -
    # the Unix-like `pipe` operator.
    module ClassMethods
      def |(other)
        this_pipe = self
        new_pipe = Class.new
        new_pipe.include(Pipe)
        new_pipe.define_singleton_method(:method_missing) do |method, *ctx, &_|
          this_pipe.send(:execute, *ctx, method)
          other.send(:execute, *ctx, method)
        end
        new_pipe
      end

      private

      def execute(ctx, method)
        ctx.on_start(self, method) if respond_to?(method)
        public_send(method, ctx)
        ctx.on_success(self, method) if respond_to?(method)
      end
    end  # module ClassMethods
  end  # module Pipe
end  # module Pipes
