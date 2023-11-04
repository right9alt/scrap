# Проект Скрапинга Вакансий

Этот проект включает в себя скрипты для сбора данных о вакансиях, их парсинга и поиска с использованием Elasticsearch. Ниже приведено описание каждого файла в проекте:

## `scrapper.rb`
- Этот файл предназначен для первичного сбора ссылок на вакансии.
- Собранные ссылки сохраняются в файл `vacancy_urls.json`.
- В нем более 5300 ссылок на вакансии.
- Популярные категории включают в себя вакансии, не требующие специфических навыков, такие как курьеры или операторы call-центров.

## `scrap_by_url.rb`
- Этот файл используется для парсинга данных о вакансиях с использованием собранных ссылок.
- Данные вакансий собираются и сохраняются в файл `vacancy_data.json`.
- Вакансии могут быть представлены в разных форматах, таких как обычный текст или сверстанная вакансия работодателем.
- Парсер способен извлекать следующие поля: "url", "Title", "Salary", "overview", "description", "skills", "dreamJob", "recomendationPercent".
- Некоторые поля могут оставаться пустыми, так как не все работодатели предоставляют полную информацию.

## `poiskovik.rb`
- Этот файл отвечает за поиск вакансий с использованием Elasticsearch.
- В процессе поиска применяются синонимы для запросов, опечаточная коррекция и маппинг по всем полям вакансий.

## `danilin-serp-version-1.xlsx`
- Этот файл содержит статистику по запросам и результатам поиска вакансий.
- Некоторые документы могут иметь одинаковые названия вакансий, но разные ссылки (проверено по идентификаторам).
