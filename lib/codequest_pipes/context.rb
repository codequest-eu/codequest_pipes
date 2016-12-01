module Pipes
  # Context is an object used to pass data between Pipes. It behaves like an
  # OpenStruct except you can write a value only once - this way we prevent
  # context keys from being overwritten.
  class Context
    attr_reader :error

    # Override is an exception raised when an attempt is made to override an
    # existing Context property.
    class Override < ::StandardError; end

    # ExecutionTerminated is an exception raised when the `fail` method is
    # explicitly called on the Context. This terminates the flow of a pipe.
    class ExecutionTerminated < ::StandardError; end

    # Context constructor.
    #
    # @param values [Hash]
    def initialize(values = {})
      add(values)
      @error = nil
    end

    # Method `add` allows adding new properties (as a Hash) to the Context.
    #
    # @param values [Hash]
    def add(values)
      values.each do |key, val|
        k_sym = key.to_sym
        fail Override, "Property :#{key} already present" if respond_to?(k_sym)
        define_singleton_method(k_sym) { val }
      end
    end

    # Quietly fail the pipe, allowing the error to be saved and accessed from
    # the Context.
    #
    # @param error [Any] Error to be set.
    def halt(error = 'Execution stopped')
      @error = error
    end

    # Explicitly fail the pipe, allowing the error to be saved and accessed from
    # the Context.
    #
    # @param error [Any] Error to be set.
    #
    # @raise [ExecutionTerminated]
    def terminate(error)
      halt(error)
      fail ExecutionTerminated, error
    end

    # Check if the Context finished successfully.
    # This method smells of :reek:NilCheck
    #
    # @return [Boolean] Success status.
    def success?
      @error.nil?
    end

    # Check if the Context failed.
    #
    # @return [Boolean] Failure status.
    def failure?
      !success?
    end

    # Printable string representation of the context
    #
    # @return [String]
    def inspect
      keys = methods - Object.methods - Pipes::Context.instance_methods
      fields = keys.map { |key| "#{key}=#{public_send(key).inspect}" }
      fields << "@error=#{@error.inspect}"
      "#<Pipes::Context:0x007ffd5d675630 #{fields.join(', ')}>"
    end
  end # class Context
end # module Pipes
