class ClassServiceJob < ApplicationJob
  def perform(service_name, ...)
    service_name.to_s.camelize.constantize
  end
end
