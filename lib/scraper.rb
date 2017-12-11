require 'httparty'
require 'nokogiri'

class Scraper
  attr_reader :url, :number_of_articles, :directory, :summaries

  def initialize(url, number_of_articles, directory)
    @url = url
    @number_of_articles = number_of_articles
    @directory = directory
    @summaries = []
  end

  def scrape
    response = HTTParty.get(url)
    articles = Nokogiri::HTML(response).css('article')[(0...number_of_articles)]

    articles.each do |article|
      heading = article.css('.story-heading').text
      url = article.css('.story-heading a').first['href']
      summaries.push({
        heading: heading,
        url: url,
      })
    end

    summaries.each do |summary|
      page = Nokogiri::HTML(HTTParty.get(summary[:url]))
      summary_page = if page.at_css('p.g-body')
        page.css('p.g-body')
      else
        page.css('p.story-body-text')
      end

      if page.at_css('figure img')
        summary[:image] = page.css('figure img').first[:src]
        summary[:image_text] = page.css('figure img').first['data-mediaviewer-caption']
      end
      summary[:body] = summary_page.map(&:text)
      summary[:byline] = page.css('.byline-author').text
      summary[:date] = page.css('.story-meta-footer .dateline').text

      filename = summary[:heading].downcase.gsub(/\W/,' ').strip.gsub(/\s+/, '-')
      to_be_written = [
        "## #{summary[:heading]}",
        "",
        "##### #{summary[:byline]}, #{summary[:date]}",
        "#{summary[:url]}",
        "",
        (summary[:image] && summary[:image_text]) ? "![#{summary[:image_text]}](#{summary[:image]})" : nil,
        (summary[:image] && summary[:image_text]) ? "*#{summary[:image_text]}*" : nil,
        "",
        "#{summary[:body].join("\n\n")}"
      ]

      File.open("#{directory}#{filename}.md", 'w+') do |file|
        file.write(to_be_written.compact.join("\n"))
      end
    end
  end
end
