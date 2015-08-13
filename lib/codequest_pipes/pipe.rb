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
          other.send(:execute, *ctx, method) if other.respond_to?(method)
        end
        new_pipe
      end

      private

      def execute(ctx, method)  # rubocop:disable Metrics/CyclomaticComplexity
        # Allow passing Hash to a pipe.
        ctx = Pipes::Context.new(ctx) if ctx.is_a?(Hash)
        ctx.on_start(self, method) if respond_to?(method)
        begin
          public_send(method, ctx)
          ctx.on_success(self, method) if respond_to?(method)
        rescue StandardError => e
          raise unless respond_to?(method) && ctx.on_error(self, method, e)
        end
        ctx  # ...in case one wanted to read directly from a Pipe.
      end
    end  # module ClassMethods
  end  # module Pipe
end  # module Pipes
