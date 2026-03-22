# Подготовка и деплой проекта
Склонировать репозиторий https://github.com/devenum/data-platform.git
```
git clone https://github.com/devenum/data-platform.git
cd ./data-platform
```
Далее выполнить билд и запуск контейнера в среде Docker
```
docker compose build data-platform
docker compose up -d
```
В докер запустится контейнер с именем data-platform-all-in-one

После старта необходимо подождать 4 минуты для инициализации окружений сервисов, после чего стоит подключиться в контейнер с помощью команды
```
docker exec -it data-platform-all-in-one bash
```
и проделать некоторые манипуляции:
   1. запустить скрипт инициализации административной учётной записи для superset (требование ИБ сервиса требует ручного ввода пароля) с помощью команды
   ```
   sh /superset.init.script.sh
   ```
   в процессе миграций в бд superset postgresql скрипт запросит ввода пароля для учётной записи admin для простоты работы в дальнейшем рекомендую ввести пароль admin.
   
   2. подготовить для импорта в postgresql файл с данными командой
   ```
   cp /root/airflow/dags/
   ```