class ApplicationService
  class << self
    def call(params = {})
      new(params).call
    end

    def required_params(*params)
      @@required_params ||= params.map(&:to_sym)
    end
  end

  def initialize(params = {})
    raise ArgumentError, "params must be a Hash" unless params.is_a?(Hash)

    params = params.with_indifferent_access
    missing_params = self.class.required_params - params.keys.map(&:to_sym)

    raise ArgumentError, "missing arguments: #{missing_params.join(', ')}" if missing_params.present?

    params.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def call
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
