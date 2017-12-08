#!/usr/bin/env ruby
require 'httparty'
require 'nokogiri'

response = HTTParty.get('https://www.nytimes.com/')

num_articles = ARGV[0].to_i

return if num_articles > 100 || num_articles < 1
articles = Nokogiri::HTML(response).css('article')[(0...num_articles)]

summaries = []

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

  File.open("#{filename}.md", 'w+') { |file| file.write(to_be_written.compact.join("\n")) }
end
