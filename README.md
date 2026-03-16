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

# посомтреть статус контейнера
docker ps 
# зайти в контейнер
docker exec -it data-platform-all-in-one bash
# csv будет лежать тут
 ~/airflow/dags/
 Banking_Transactions_USA_2023_2024.csv
