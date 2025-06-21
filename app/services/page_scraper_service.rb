class PageScraperService < ApplicationService
  required_params :website_url

  def call
    response = Faraday.get @website_url

    parse_page(response.body)
  end

  private
    def parse_page(page)
      parsed_html = nokogiri_html(page)
      parsed_html = remove_useless_tags(parsed_html)
      parsed_html = to_text(parsed_html)

      parsed_html
    end

    def remove_useless_tags(parsed_html)
      %w[svg img script].each { |tag| parsed_html.css(tag).remove }

      parsed_html
    end

    def nokogiri_html(page)
      Nokogiri::HTML(page)
    end

    def to_text(html)
      space_tags = %w[p li div ul ol table tr td th h1 h2 h3 h4 h5 h6 br span]

      text_parts = []

      html.traverse do |node|
        if node.text?
          trimmed = node.text.strip
          text_parts << trimmed unless trimmed.empty?
        elsif node.element? && node.name.in?(space_tags)
          text_parts << " "
        end
      end

      text_parts.join.strip.squish
    end
end
