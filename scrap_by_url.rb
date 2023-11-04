require 'open-uri'
require 'nokogiri'
require 'json'

# Загрузите JSON-файл
json_file = File.read('vacancy_urls.json')

# Разберите JSON
data = JSON.parse(json_file)

# Создайте массив для хранения данных о вакансиях
vacancies = []

# Пройдите по каждому элементу и выполните действия
data.each_with_index do |url, index|
  p index
  vacancy_data = {}
  begin
    html = URI.open(url["vacancy_url"])
  rescue OpenURI::HTTPError => e
    # Если возникла ошибка 403 Forbidden, просто продолжайте цикл без обработки этой вакансии
    puts "Error loading URL: #{url['vacancy_url']}, skipping..."
    next
  end

  doc = Nokogiri::HTML(html)
  
  vacancy_data['url'] = url["vacancy_url"]

  vacancy_data['Title'] = doc.css('.vacancy-title').text
  vacancy_data['Salary'] = doc.css('div[data-qa="vacancy-salary"]').any? ? doc.css('div[data-qa="vacancy-salary"]').text : 'Зарплата не указана'
  vacancy_data['overview'] = doc.css('.vacancy-description-list-item').map(&:text).join("\n")

  if doc.css('.vacancy-branded-user-content')
    paragraphs = doc.css('.vacancy-branded-user-content').css('p, li, span').map(&:text).join(' ')
    vacancy_data['description'] = paragraphs
  else
    paragraphs = doc.css('div[data-qa="vacancy-description"] p, div[data-qa="vacancy-description"] li, div[data-qa="vacancy-description"] span').map(&:text).join(' ')
    vacancy_data['description'] = paragraphs
  end

  tag_list = doc.at('div.bloko-tag-list')
  if tag_list
    skills = tag_list.css('div.bloko-tag').map { |tag_div|
      tag_div.css('span.bloko-tag__section_text').text
    }
    vacancy_data['skills'] = skills
  else
    vacancy_data['skills'] = nil
  end

  recommendation_div = doc.at_css('[data-qa="employer-review-big-widget-recommendation"]')
  recommendation_percentage = recommendation_div.at_css('h1[data-qa="bloko-header-1"]').text if recommendation_div

  dream_job_div = doc.at_css('[data-qa="employer-review-big-widget-dream-job-rating"]')
  dream_job_rating = dream_job_div.at_css('span[data-qa="bloko-header-1"]').text if dream_job_div

  unless dream_job_rating
    vacancy_data['dreamJob'] = nil
  else
    vacancy_data['dreamJob'] = dream_job_rating
  end

  unless recommendation_percentage
    vacancy_data['recomendationPercent'] = nil
  else
    vacancy_data['recomendationPercent'] = recommendation_percentage
  end

  # Добавьте данные о вакансии в массив
  vacancies << vacancy_data
end

# Запишите массив в JSON-файл
File.open('vacancy_data.json', 'w') { |file| file.write(JSON.pretty_generate(vacancies)) }
  