Настройка этого дела на примере выгрузки банковых транзакций:
Залить csv внутрь контейнера.
создать, бд (data) таблицу(схему)
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


# подключиться по ссх
ssh data_test@95.163.180.30
# пароль
H89SCU1s6q2ybcdnKsdohg==
# посомтреть статус контейнера
docker ps 
# зайти в контейнер
docker exec -it data-platform-all-in-one bash
# csv будет лежать тут
 ~/airflow/dags/
 Banking_Transactions_USA_2023_2024.csv
#  порты открытые наружу
http://95.163.180.30:8092 cloudbeaver
http://95.163.180.30:8091 airflow (admin\admin)
http://95.163.180.30:8090 superset (admin\admin)

сурс еще обрабатывается заранее
сурс csv(датасэт) (субд (кафка)) ->  ETL() -> dag (airflow) superset {витрина данных} 
через суперсет написать свой компьют(дащборд)
* - разобраться всю цепочку. (до вторника)

cloudbeaver инсрукция
superset


#cloudbeaver
подключение к вэбу через 
http://95.163.180.30:8092
справа вверху нажать кнопку шестерёнки (settings) выбрать login
логин\пароль (такие логин\пароль исходя из требований самого CB)
cbadmin\Admin123
# если что-то пошло не так (для админа)
после авторизации можно начинать подключение к бд Postgresql (или монго), нажав кнопку плюс и выбрав Find Local Database
оставить всё как есть (localhost) и нажать кнопку лупа
будет предложено два драйвера для подключения постгре и монго, выбираем первый 
в поле Database указать data
в поле username и password указать "postgres" 
далее справа вверху нажать кнопку test для проверки подключения, если все хорошо откроется попап окно connection is established и тогда можно нажимать кнопку register после чего профиль подключения к субд сохранится для этой учётной записи
# если всё хорошо
после авторизации слева увидите PostgreSQL@localhost - это профиль для подключения к субд, просто дважды нажмите на него и введите логин\пароль postgres\postgres
далее слева разверните цепочку PostgreSQL@localhost -> Databases -> data -> Schemas -> raw_data -> Tables -> bank_transactions_staging