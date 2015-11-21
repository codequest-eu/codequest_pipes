module Pipes
  # Pipe is a mix-in which turns a class into a Pipes building block (Pipe).
  # A Pipe can only have class methods since it can't be instantiated.
  module Pipe
    def self.included(base)
      base.extend(ClassMethods)
    end

    # ClassMethods provides the most important feature of the whole libary -
    # the Unix-like `pipe` operator.
    module ClassMethods
      def |(other)
        this = self
        Class.new do
          include Pipe
          _combine(this, other)
        end
      end

      def require_ctx(*args)
        _required_context_elements.push(*args)
      end

      def _combine(first, second)
        define_singleton_method(:call) do |ctx|
          first._safely_call(ctx)
          second._safely_call(ctx)
        end
      end

      def _safely_call(ctx)
        _validate_ctx(ctx)
        call(ctx)
      end

      def _required_context_elements
        @required_context_elements ||= []
      end

      def _validate_ctx(ctx)
        _required_context_elements.each do |element|
          next if ctx.respond_to?(element)
          fail MissingContext, "context does not respond to '#{element}'"
        end
      end
    end # module ClassMethods
  end # module Pipe
end # module Pipes
