FROM python:3.11-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV SPARK_HOME=/opt/spark
ENV KAFKA_HOME=/opt/kafka
ENV AIRFLOW_HOME=/opt/airflow
ENV TZ="Europe/Moscow"

# System deps

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    curl wget gnupg ca-certificates \
    supervisor \
    redis-server \
    postgresql \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# MongoDB repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg && \
    curl -fsSL -k https://pgp.mongodb.com/server-6.0.asc | \
    gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg && \
    chmod 644 /usr/share/keyrings/mongodb-server-6.0.gpg && \
    echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" \
    > /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends mongodb-org && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/db

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4 \
    && echo "deb [trusted=yes] http://packages.clickhouse.com/deb stable main" > /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && apt-get install -y clickhouse-server clickhouse-client \
    && apt-get clean

# Установка Apache Kafka
ENV KAFKA_VERSION=3.5.1
ENV SCALA_VERSION=2.13
RUN wget --no-check-certificate https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt/ \
    && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
    && rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$KAFKA_HOME/bin:$PATH

# Установка Apache Spark
ENV SPARK_VERSION=3.4.1
ENV HADOOP_VERSION=3
RUN wget --no-check-certificate https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Python stack
RUN pip3 install --upgrade pip && pip3 install --ignore-installed \
    markupsafe==2.1.3 \
    jinja2==3.1.2 \
    click==8.1.7 \
    werkzeug==2.2.3 \
    flask==2.2.5 \
    sqlalchemy==1.4.51 \
    sqlalchemy-utils==0.38.3 \
    flask-appbuilder==4.3.11 \
    numpy==1.24.3 \
    pandas==2.0.3 \
    pyarrow==12.0.1 \
    pendulum==2.1.2

# Устанавливаем Airflow (он найдет уже установленные зависимости)
RUN pip3 install apache-airflow==2.6.3

RUN apt -y install build-essential python3-dev

# Устанавливаем Superset (он найдет уже установленные зависимости)
RUN pip3 install --ignore-installed apache-superset==3.0.2

# Создаём структуру под postgresql
RUN mkdir /postgresql && chown postgres:postgres -R /postgresql
RUN apt install -y procps libpq-dev
RUN pip install flask-session==0.5.0 \
    connexion[flask]==2.14.2 \
    marshmallow==3.26.1 \
    psycopg2==2.9.10

# Установка DBeaver (CloudBeaver) через официальный образ
RUN useradd dbeaver
COPY --from=dbeaver/cloudbeaver:23.3 /opt/cloudbeaver /opt/cloudbeaver
RUN chown dbeaver:dbeaver -R /opt/cloudbeaver

# Установка SSH сервера
RUN apt-get update && apt-get install -y \
    openssh-server git \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя devuser и настройка SSH
RUN useradd -m -s /bin/bash devuser \
    && echo 'devuser:LrLXXaKVg2Eic3LQ' | chpasswd \
    && mkdir -p /home/devuser/.ssh \
    && chmod 700 /home/devuser/.ssh \
    && chown -R devuser:devuser /home/devuser/.ssh \
    && mkdir -p /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Создание директории и инициализация Git-репозитория
RUN mkdir -p /repository \
    && cd /repository \
    && git init \
    && git config --global --add safe.directory /repository \
    && chown devuser:devuser -R /repository

# Init script
COPY init.sh superset_config.py superset.init.sh /
RUN chmod +x /init.sh /superset.init.sh

# Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5432 27017 6379 8123 8080 8088 7077 9092 2181 22

CMD ["/usr/bin/supervisord"]