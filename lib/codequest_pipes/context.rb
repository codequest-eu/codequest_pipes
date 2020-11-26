require 'ice_nine'

require 'codequest_pipes/context/error_collector'

module Pipes
  # Context is an object used to pass data between Pipes. It behaves like an
  # OpenStruct except you can write a value only once - this way we prevent
  # context keys from being overwritten.
  class Context
    # Override is an exception raised when an attempt is made to override an
    # existing Context property.
    class Override < ::StandardError; end

    # ExecutionTerminated is an exception raised when the `fail` method is
    # explicitly called on the Context. This terminates the flow of a pipe.
    class ExecutionTerminated < ::StandardError; end

    # Context constructor.
    #
    # @param values [Hash]
    def initialize(values = {}, mutable_values = {})
      @error_collector = ErrorCollector.new
      @mutable_values = Set.new
      add(values, mutable_values)
    end

    # Method `add` allows adding new properties (as a Hash) to the Context.
    #
    # @param values [Hash]
    def add(values, mutable_values = {})
      values.each do |key, val|
        add_value(key.to_sym, IceNine.deep_freeze(val))
      end

      mutable_values.each do |key, val|
        add_value(key.to_sym, val)
        @mutable_values << key
      end
    end

    # Quietly fail the pipe. The error will be passed to the error_collector
    # and stored in the :base errors collection.
    #
    ## @param error [String]
    def halt(error = 'Execution stopped')
      add_errors(base: error)
    end

    # Explicitly fail the pipe.
    #
    # @raise [ExecutionTerminated]
    def terminate(error)
      halt(error)
      fail ExecutionTerminated
    end

    # Check if the Context finished successfully.
    # This method smells of :reek:NilCheck
    #
    # @return [Boolean] Success status.
    def success?
      errors.empty?
    end

    # Check if the Context failed.
    #
    # @return [Boolean] Failure status.
    def failure?
      !success?
    end

    # Printable string representation of the context
    # object_id_hex explained: http://stackoverflow.com/a/2818916/3526316
    #
    # @return [String]
    def inspect
      keys = methods - Object.methods - Pipes::Context.instance_methods
      fields = keys.map { |key| "#{key}=#{public_send(key).inspect}" }
      fields << "@errors=#{@errors.inspect}"
      object_id_hex = '%x' % (object_id << 1)
      "#<Pipes::Context:0x00#{object_id_hex} #{fields.join(', ')}>"
    end

    # Return errors from ErrorCollector object.
    #
    # @return [Hash]
    def errors
      error_collector.errors
    end

    # This method is added to maintain backwards compatibility - previous
    # versions implemented a single @error instance variable of String for error
    # storage.
    #
    # @return [String]
    def error
      errors[:base]&.first
    end

    # Add errors to ErrorCollector object.
    # It doesn't fail the pipe as opposed to `halt` and `terminate` methods.
    #
    # @param collectable_errors [Hash]
    def add_errors(collectable_errors)
      error_collector.add(collectable_errors)
    end

    private

    attr_reader :error_collector, :mutable_values

    def add_value(key, value)
      if respond_to?(key) && !mutable_values.include?(key)
        fail Override, "Property :#{key} already exists and is non-mutable"
      end
      define_singleton_method(key) { value }
    end
  end # class Context
end # module Pipes
