FROM postgresql:16-bookworm

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
    postgresql-16-pgvector \
    postgresql-16-age \
    postgresql-16-pgdg-pgroonga pgxnclient \
    postgresql-plpython3-16 postgresql-16-pljs postgresql-16-pllua \
    postgresql-16-cron postgresql-16-http postgresql-16-ip4r postgresql-16-orafce postgresql-16-pgaudit  \
    postgresql-16-pgrouting postgresql-16-postgis-3 postgresql-16-pgmp postgresql-16-partman postgresql-16-wal2json \
    postgresql-16-mysql-fdw postgresql-16-oracle-fdw postgresql-16-tds-fdw \
    # Clean up APT cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

    
COPY 01-configure-age.sh /docker-entrypoint-initdb.d/ 

CMD ["postgres", "-c", "shared_preload_libraries=age"]
