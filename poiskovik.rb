require 'elasticsearch'
require 'json'

# Устанавливаем клиент Elasticsearch
client = Elasticsearch::Client.new log: true

# Указываем имя индекса
index = 'vacancy_index_3'

data = JSON.parse(File.read('dictionary.json'))
synonyms = []

data['wordlist'].last(10).each do |item|
  next unless item['synonyms']
  name_value = item['name']
  synonyms_values = item['synonyms'].join(', ') if item['synonyms']

  synonyms << "#{name_value}, #{synonyms_values}"
end



# Проверяем существование индекса
unless client.indices.exists(index: index)
  settings = {
    analysis: {
      filter: {
        my_synonym_filter: {
          type: "synonym",
          synonyms: [
            "курьер, кура, доставщик",
            "программист, разработчик, прогер",
            "препод, преподаватель, учитель, репетитор",
            "бариста, кофейщик",
            "python, питон",
            "разработчик, девелопер",
            "hr, кадровик, рекрутер",
            "язык программирования, C, C++, C#",
            "колл-центр, колл центр, call center, колл-центрщик",
            "администратор, админ, админка",
            "преподаватель, учитель, лектор",
            "курьер, доставщик",
          ]
        },
        ru_stop: {
          type: "stop",
          stopwords: "_russian_"
        },
        ru_stemmer: {
          type: "stemmer",
          language: "russian"
        }
      },
      analyzer: {
        my_synonyms: {
          tokenizer: "standard",
          filter: [
            "lowercase",
            "my_synonym_filter",
            "ru_stop",
            "ru_stemmer"
          ]
        }
      }
    }
  }
  

  # Определите мультифилд для каждого поля
  mapping = {
    properties: {
      url: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      title: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      salary: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      overview: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      description: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      skills: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      dream_job: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      },
      recommendation_percent: { 
        type: "text",
        index: true,
        search_analyzer: "my_synonyms",
        analyzer: "my_synonyms",
        term_vector: "with_positions_offsets_payloads"
      }
    }
  }

  # Создаем индекс с указанными настройками и маппингом
  client.indices.create(index: index, body: { settings: settings, mappings: mapping })
  
  # Загружаем данные из JSON
  data = JSON.parse(File.read('vacancy_data.json'))

  # Индексируем данные
  data.each do |item|
    document = {
      url: item['url'],
      title: item['Title'],
      salary: item['Salary'],
      overview: item['overview'],
      description: item['description'],
      skills: item['skills'],
      dream_job: item['dreamJob'],
      recommendation_percent: item['recomendationPercent']
    }

    client.index(index: index, body: document)
  end
end
# print 'НАСТРОЙКИ ПОИСКА:'

# print 'Искать в названии вакансии? (yes/no): '
# search_title = gets.chomp.downcase == 'yes'

# print 'Искать в описании вакансии? (yes/no): '
# search_description = gets.chomp.downcase == 'yes'

# print 'Сколько записей вывести (10, 20, все): '
# records_count = gets.chomp

#  # Определяем поля для поиска в зависимости от флагов
#  search_fields = []
#  search_fields << 'title' if search_title
#  search_fields << 'description' if search_description

 # В зависимости от количества записей, задаем размер вывода
#  size = if records_count == 'all'
#           nil
#         else
#           records_count.to_i
#         end

size = 10

# Основной цикл для выполнения поисковых запросов
loop do
  print 'Введите запрос (или "exit" для выхода): '
  query = gets.chomp

  break if query.downcase == 'exit'

  # Выполняем поиск в индексе по всем полям
  response = client.search(index: index, body: {
    query: {
      multi_match: {
        query: query,
        fields: ['title'],
        fuzziness: "AUTO",  # Apply fuzziness for these specific fields
        analyzer: 'my_synonyms' # Use the custom "my_synonyms" analyzer
      }
    },
    size: size
  })
  

  # Выводим результаты поиска
  response['hits']['hits'].first(10).each do |hit|
    puts "Ссылка на вакансию: #{hit['_source']['url']}"
    puts ''
    puts "Название: #{hit['_source']['title']}"
    puts hit['_source']['Salary'] ? "Зарплата: #{hit['_source']['Salary']}" : 'Зарплата: не указана :(('
    if hit['_source']['title']
      if hit['_source']['description'].length <= 200
        puts hit['_source']['description']
      else
        puts hit['_source']['description'][0...200] + '...'
      end
    else
      puts 'Описание: не указано =('
    end
    # Вывод других полей, если это необходимо
    puts '---------------------------------------------------------------------'
    puts '------------------МЕСТО ДЛЯ ВАШЕЙ РЕКЛАМЫ----------------------------'
    puts '---------------------------------------------------------------------'

  end
end
