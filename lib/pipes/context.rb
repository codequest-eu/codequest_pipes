module Pipes
  # Context is an object used to pass data between Pipes. It behaves like an
  # OpenStruct except you can write a value only once - this way we prevent
  # context keys from being overwritten.
  class Context
    # Override is an exception raised when an attempt is made to override an
    # existing Context property.
    class Override < ::StandardError; end

    def initialize(values = {})
      add(values)
    end

    # Method `add` allows adding new properties (as a Hash) to the Context.
    def add(values)
      values.each do |k, v|
        fail Override, "Property :#{k} already present" if respond_to?(k.to_sym)
        define_singleton_method(k.to_sym) { v }
      end
    end

    # Method `on_start` is called before a Pipe is started. By default this does
    # nothing so if you want to provide a custom callback you should subclass
    # Context and provide a custom implementation.
    def on_start(_klass, _method); end

    # Method `on_success` is called after a Pipe successfully completes. By
    # default this does nothing so if you want to provide a custom callback you
    # should subclass Context and provide a custom implementation.
    def on_success(_klass, _method); end
  end  # class Context
end  # module Pipes
