module Piperator
  # Builder is used to provide DSL-based Pipeline building. Using Builder,
  # Pipelines can be built without pipe chaining, which might be easier if
  # some steps need to be included only on specific conditions.
  #
  # @see Piperator.build
  class Builder
    # Expose a chained method in Pipeline in DSL
    #
    # @param method_name Name of method in Pipeline
    # @see Pipeline
    #
    # @!macro [attach] dsl_method
    #   @method $1
    #   Call Pipeline#$1 given arguments and use the return value as builder state.
    #
    #   @see Pipeline.$1
    def self.dsl_method(method_name)
      define_method(method_name) do |*arguments|
        @pipeline = @pipeline.send(method_name, *arguments)
      end
    end

    dsl_method :pipe
    dsl_method :wrap

    def initialize(saved_binding, pipeline = Pipeline.new)
      @pipeline = pipeline
      @saved_binding = saved_binding
    end

    # Return build pipeline
    #
    # @return [Pipeline]
    def to_pipeline
      @pipeline
    end

    private

    def method_missing(method_name, *arguments, &block)
      if @saved_binding.receiver.respond_to?(method_name, true)
        @saved_binding.receiver.send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @saved_binding.receiver.respond_to?(method_name, include_private) || super
    end
  end
end
