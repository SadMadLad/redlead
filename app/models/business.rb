class Business < ApplicationRecord
  include Embeddable

  set_embeddable :embeddable_prompt
  set_embedding_models :nomic

  validates_presence_of :description, :title

  validates :website_url, url: true, allow_blank: true

  after_create_commit :process_embedding

  def process_embedding
    if website_url?
      ScrapeWebsiteJob.perform_later(id)
    else
      embed
    end
  end

  def embeddable_prompt
    return description unless intelligent_scraped_summary?

    @prompt ||= <<~XML
      <description>#{description}</description>
      <scraped-data>#{intelligent_scraped_summary}</scraped-data>
    XML

    @prompt ||= @prompt.squish
  end
end
