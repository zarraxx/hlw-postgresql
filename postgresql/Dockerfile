FROM postgresql:18-bookworm

# Switch to the root user to perform installations
USER root

# 1. Update and install prerequisite packages.
#    - lsb-release: needed to identify the Debian version name (e.g., "bookworm").
#    - curl, gnupg, ca-certificates: required to add new APT repositories securely.
RUN apt-get update && apt-get install -y --no-install-recommends \
    lsb-release \
    curl wget \
    gnupg \
    net-tools \
    iputils-ping \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN DEBIAN_FRONTEND=noninteractive curl -fsSLo /tmp/groonga-source.deb https://packages.groonga.org/debian/groonga-apt-source-latest-$(lsb_release -cs).deb && \
    apt-get update && \
    apt-get install -y /tmp/groonga-source.deb && \
    rm /tmp/groonga-source.deb


#RUN  wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && \
#    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb && \
#    rm percona-release_latest.$(lsb_release -sc)_all.deb

# 4. Install all PostgreSQL extensions from the newly added repositories.
#    We run apt-get update again to fetch the package lists from the new sources.
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-18-pgvector \
    postgresql-18-age \
    postgresql-18-pgdg-pgroonga pgxnclient \
    postgresql-plpython3-18 postgresql-18-pljs postgresql-18-pllua \
    postgresql-18-cron postgresql-18-http postgresql-18-ip4r postgresql-18-orafce postgresql-18-pgaudit  \
    postgresql-18-pgrouting postgresql-18-postgis-3 postgresql-18-pgmp postgresql-18-partman postgresql-18-wal2json \
    postgresql-18-mysql-fdw postgresql-18-oracle-fdw postgresql-18-tds-fdw \
    # Clean up APT cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

    
COPY 01-configure-age.sh /docker-entrypoint-initdb.d/ 

CMD ["postgres", "-c", "shared_preload_libraries=age"]
