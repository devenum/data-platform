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

