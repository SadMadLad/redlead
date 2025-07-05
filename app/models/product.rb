class Product < ApplicationRecord
  include Embeddable

  set_embeddable :prompt
  set_embedding_models :informer_gte

  belongs_to :business

  validates_presence_of :title, :description

  after_create_commit :embed_product

  def embed_product
    embed
  end

  def prompt
    return @prompt if @prompt

    @prompt = <<~XML
      <product-title>#{title}</product-title>
      <description>#{description}</description>
    XML

    @prompt = @prompt.squeeze(" ").squeeze("\n").strip
  end
end
