class Product < ApplicationRecord
  include Embeddable

  set_embeddable :prompt
  set_embedding_models :informer_gte

  belongs_to :business

  validates_presence_of :title, :description

  after_create_commit :process_embedding

  def process_embedding
    self.embed(async: true)
  end

  def prompt
    return @prompt if @prompt

    @prompt = <<~XML
      <product-title>#{title}</product-title>
      <description>#{description}</description>
    XML

    @prompt = @prompt.squish
  end
end
