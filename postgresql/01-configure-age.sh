    
#!/bin/bash
set -e
# Use ALTER SYSTEM to permanently set the configuration parameter
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    ALTER SYSTEM SET shared_preload_libraries = 'age';
EOSQL

  
