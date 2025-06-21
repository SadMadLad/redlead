class OpenStructSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(open_struct)
    super(
      **open_struct.to_h
    )
  end

  def deserialize(hash)
    OpenStruct.new(hash)
  end

  private
    def klass
      OpenStruct
    end
end
