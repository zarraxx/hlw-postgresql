
# 1. 在 FROM 之前定义 ARG，以便在 FROM 镜像名中使用
ARG PG_MAJOR_VERSION=16

FROM docker.io/postgres:${PG_MAJOR_VERSION}-bookworm

# 2. 在 FROM 之后必须重新声明一下该 ARG，才能在 RUN 脚本中使用
ARG PG_MAJOR_VERSION

USER root

# 1. 安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    lsb-release \
    curl wget telnet \
    gnupg \
    net-tools \
    iputils-ping \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 Groonga 源
RUN DEBIAN_FRONTEND=noninteractive curl -fsSLo /tmp/groonga-source.deb https://packages.groonga.org/debian/groonga-apt-source-latest-$(lsb_release -cs).deb && \
    apt-get update && \
    apt-get install -y /tmp/groonga-source.deb && \
    rm /tmp/groonga-source.deb

# 3. 安装扩展 - 使用 ${PG_VERSION} 变量替代具体的数字
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-${PG_MAJOR_VERSION}-pgvector \
    postgresql-${PG_MAJOR_VERSION}-age \
    postgresql-${PG_MAJOR_VERSION}-pgdg-pgroonga pgxnclient \
    postgresql-plpython3-${PG_MAJOR_VERSION} \
    postgresql-${PG_MAJOR_VERSION}-pljs \
    postgresql-${PG_MAJOR_VERSION}-pllua \
    postgresql-${PG_MAJOR_VERSION}-cron \
    postgresql-${PG_MAJOR_VERSION}-http \
    postgresql-${PG_MAJOR_VERSION}-ip4r \
    postgresql-${PG_MAJOR_VERSION}-orafce \
    postgresql-${PG_MAJOR_VERSION}-pgaudit  \
    postgresql-${PG_MAJOR_VERSION}-pgrouting \
    postgresql-${PG_MAJOR_VERSION}-postgis-3 \
    postgresql-${PG_MAJOR_VERSION}-pgmp \
    postgresql-${PG_MAJOR_VERSION}-partman \
    postgresql-${PG_MAJOR_VERSION}-wal2json \
    postgresql-${PG_MAJOR_VERSION}-mysql-fdw \
    postgresql-${PG_MAJOR_VERSION}-oracle-fdw \
    postgresql-${PG_MAJOR_VERSION}-tds-fdw \
    && rm -rf /var/lib/apt/lists/*

#COPY 01-configure-age.sh /docker-entrypoint-initdb.d/
USER postgres

CMD ["postgres", \
     "-c", "shared_preload_libraries=age,pgaudit,pg_partman_bgw,pg_stat_statements"]

