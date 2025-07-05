class ScrapeBusinessWebsiteJob < ApplicationJob
  def perform(business_id)
    business = Business.find(business_id)
    scraped_data = PageScraperService.call(website_url: business.website_url)

    prompt = <<~XML
      <order>
        Summarize this corpus of text. Focus on services provided. Be as extensible as possible.
      </order>
      <text>
        <description>#{business.description}</description>
        <scraped-data>#{scraped_data}</scraped-data>
      </text>
    XML

    prompt = prompt.squish

    services_summary = ApplicationAgent.quick_complete(:google, :gemini_20_flash, prompt)
    business.update(intelligent_scraped_summary: services_summary)

    business.embed
  end
end
