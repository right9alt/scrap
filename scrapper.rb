# require 'open-uri'
# require 'nokogiri'
# require 'json'

# showings = []

# urls_links = %w(
#   https://hh.ru/search/vacancy?text=python&salary=&ored_clusters=true&area=0
#   https://hh.ru/search/vacancy?text=hr&area=1
#   https://hh.ru/search/vacancy?text=c&salary=&ored_clusters=true&area=1
#   https://hh.ru/search/vacancy?text=call&area=1
#   https://hh.ru/vacancies/administrator?
#   https://hh.ru/vacancies/prepodavateli?
#   https://hh.ru/search/vacancy?text=courier
#   https://hh.ru/search/vacancy?text=бариста
# )
# urls_links.each do |url|
#   (0..39).each do |i|
#     url = "#{url}&page=#{i}"
#     html = URI::open(url)

#     doc = Nokogiri::HTML(html)
#     puts i
#     doc.css('.serp-item__title').each do |showing|
#       showings.push(vacancy_url: showing['href'])
#     end
#     rescue Errno::ETIMEDOUT => e
#       puts "Timeout error for URL: #{url}"
#       next # Пропустить текущую итерацию и перейти к следующей URL
#   end
#   sleep 1
# end

# File.open('vacancy_urls.json', 'w') do |file|
#   file.write(JSON.pretty_generate(showings))
# end

require 'open-uri'
require 'nokogiri'
require 'json'

showings = []

urls_links = %w(
  https://hh.ru/search/vacancy?text=%D0%B1%D0%B0%D1%80%D0%B8%D1%81%D1%82%D0%B0
  https://hh.ru/search/vacancy?text=python&salary=&ored_clusters=true&area=0
  https://hh.ru/search/vacancy?text=hr&area=1
  https://hh.ru/search/vacancy?text=c&salary=&ored_clusters=true&area=1
  https://hh.ru/search/vacancy?text=call&area=1
  https://hh.ru/vacancies/administrator?
  https://hh.ru/vacancies/prepodavateli?
  https://hh.ru/search/vacancy?text=courier
)
urls_links.each do |url|
  (0..39).each do |i|
    url = "#{url}&page=#{i}"
    begin
      html = URI::open(url)
      doc = Nokogiri::HTML(html)
      doc.css('.serp-item__title').each do |showing|
        showings.push(vacancy_url: showing['href'])
      end
    rescue Errno::ETIMEDOUT => e
      puts "Timeout error for URL: #{url}"
      next # Пропустить текущую итерацию и перейти к следующей URL
    rescue Errno::ECONNRESET => e
      puts "Connection reset error for URL: #{url}"
      next # Пропустить текущую итерацию и перейти к следующей URL
    end
  end
  puts 'one_more'
end

File.open('vacancy_urls.json', 'w') do |file|
  file.write(JSON.pretty_generate(showings))
end
