Gem::Specification.new do |s|
  s.name        = 'nyt-scraper'
  s.version     = '0.0.1'
  s.licenses    = ['MIT']
  s.summary     = "Scrapes the NYT for articles!"
  s.description = "Scrapes the NYT for articles and pulls them down locally in MD format"
  s.authors     = 'Us'
  s.files       = ["lib/scraper.rb"]
  s.executables << "scrape-nyt"

  s.add_runtime_dependency 'httparty', '~> 0.15'
  s.add_runtime_dependency 'nokogiri', '~> 1.8'
end
