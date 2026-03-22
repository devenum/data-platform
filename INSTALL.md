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
В докер запустится контейнер с именем data-platform-all-in-one.

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
   cp /root/airflow/dags/Banking_Transactions_USA_2023_2024.csv /tmp/
   ```
после проделанных процедур - контейнер готов для работы. Дольнейшая работа начинается с подготовки базы данныз postgresql через cloudbeaver.
Инструкция подключения к CloudBeaver (CB)

#cloudbeaver
подключение к вэбу через 
http://[ip-адрес вашего мастерхоста]*:8092
* [ip-адрес вашего мастерхоста] - адрес той машины где собран и запущен контейнер (но не адрес loop 127.0.0.1 а именно ваш физический ip-адрес (в linux ip -br a, в win ipconfig /all))
справа вверху нажать кнопку шестерёнки (settings) выбрать login
логин\пароль (такие логин\пароль исходя из требований самого CB)
cbadmin\Admin123
после авторизации можно начинать подключение к бд Postgresql (или монго), нажав кнопку плюс и выбрав Find Local Database
оставить всё как есть (localhost) и нажать кнопку лупа
будет предложено два драйвера для подключения постгре и монго, выбираем первый 
в поле Database указать data
в поле username и password указать "postgres" 
далее справа вверху нажать кнопку test для проверки подключения, если все хорошо откроется попап окно connection is established и тогда можно нажимать кнопку register после чего профиль подключения к субд сохранится для этой учётной записи
нажимаете на панеле управления кнопку SQL (Open SQL-editor for PostgreSQL@localhost) и вставьте текст ниже
```
CREATE SCHEMA IF NOT EXISTS raw_data;

CREATE TABLE raw_data.bank_transactions_staging (
    transaction_id VARCHAR(50),
    account_number VARCHAR(50),
    transaction_date VARCHAR(30), -- Пока как строка, потом преобразуем
    transaction_amount DECIMAL(15,2),
    merchant_name TEXT,
    transaction_type VARCHAR(20),
    category VARCHAR(50),
    city VARCHAR(50),
    latitude DECIMAL(15, 8),
    longitude DECIMAL(15, 8),
    country VARCHAR(10),
    payment_method VARCHAR(30),
    customer_age INT,
    customer_gender VARCHAR(10),
    customer_occupation TEXT,
    customer_income DECIMAL(15,2),
    account_balance DECIMAL(15,2),
    transaction_status VARCHAR(20),
    fraud_flag VARCHAR(5),
    discount_applied VARCHAR(8), -- Здесь True/False, пока как текст
    loyalty_points_earned INT,
    transaction_description TEXT
);

COPY bank_transactions_staging FROM '/tmp/Banking_Transactions_USA_2023_2024.csv' DELIMITER ',' CSV HEADER;

UPDATE raw_data.bank_transactions_staging
SET
    latitude = CASE "city"
        WHEN 'San Antonio' THEN 29.42412
        WHEN 'Dallas' THEN 32.77666
        WHEN 'Los Angeles' THEN 34.05223
        WHEN 'Chicago' THEN 41.87811
        WHEN 'New York' THEN 40.71278
        WHEN 'Houston' THEN 29.76043
        WHEN 'Philadelphia' THEN 39.95258
        WHEN 'San Jose' THEN 37.33821
        WHEN 'San Diego' THEN 32.71574
        WHEN 'Phoenix' THEN 33.44838
    END,
    longitude = CASE "city"
        WHEN 'San Antonio' THEN -98.49363
        WHEN 'Dallas' THEN -96.79699
        WHEN 'Los Angeles' THEN -118.24368
        WHEN 'Chicago' THEN -87.62980
        WHEN 'New York' THEN -74.00594
        WHEN 'Houston' THEN -95.36980
        WHEN 'Philadelphia' THEN -75.16522
        WHEN 'San Jose' THEN -121.88633
        WHEN 'San Diego' THEN -117.16109
        WHEN 'Phoenix' THEN -112.07404
    END
WHERE "city" IN (
    'San Antonio',
    'Dallas',
    'Los Angeles',
    'Chicago',
    'New York',
    'Houston',
    'Philadelphia',
    'San Jose',
    'San Diego',
    'Phoenix'
);
```
это полноценных 4 sql команды разделённых ";" CB позволяет запускать каждую поочереди, для этого просто нажмите хоткей Alt + X.
В результате создастся структура в Scheme raw_data с таблицей bank_transactions_staging которая будет заполненная из файла, а так же дополненны столбцы  latitude longitude соответствующими данными.
Далее откройте вэб-страницу superset
http://[ip-адрес вашего мастерхоста]:8090 
логин\пароль - те самые которые мы инициировали скриптом superset.init.script.sh
(admin\admin)
В главном меню откройте вкладку Dasboards и нажмите кнопку "Import dasboard" (справа в виде скобочки и стрелочки вниз), выберите архив из папки dashboard_preset и нажмите кнопку import. 


