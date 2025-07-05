class Business < ApplicationRecord
  include Embeddable

  set_embeddable :embeddable_prompt
  set_embedding_models :informer_gte

  has_many :products, dependent: :destroy

  validates_presence_of :business_type, :description, :title
  validates :website_url, url: true, allow_blank: true

  after_create_commit :process_embedding

  def process_embedding
    ScrapeBusinessWebsiteJob.perform_later(id) if website_url?
    embed unless website_url?
  end

  def embeddable_prompt
    return description unless intelligent_scraped_summary?

    @prompt ||= <<~XML
      <description>#{description}</description>
      <scraped-data>#{intelligent_scraped_summary}</scraped-data>
    XML

    @prompt ||= @prompt.squeeze(" ").squeeze("\n")
  end
end
