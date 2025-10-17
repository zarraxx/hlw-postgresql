#!/bin/bash

# set -e: Exit immediately if a command exits with a non-zero status.
# set -x: Print commands and their arguments as they are executed. (Uncomment for debugging)
set -e
# set -x

# --- Configuration ---
# The custom image you built
IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/zarra/postgresql:16-full"
# Name for the server container
SERVER_CONTAINER_NAME="postgres-server"
# Name for the client container
CLIENT_CONTAINER_NAME="postgres-client-tester"
# Podman network name
NETWORK_NAME="pg-test-network"
# Database credentials
DB_USER="postgres"
DB_PASSWORD="mysecretpassword"
DB_NAME="testdb"

# --- Main Logic ---

echo "--- Step 1: Cleaning up previous run (if any) ---"
podman stop "$SERVER_CONTAINER_NAME" &> /dev/null || true
podman rm -v "$SERVER_CONTAINER_NAME" &> /dev/null || true
podman network rm "$NETWORK_NAME" &> /dev/null || true
echo "Cleanup complete."

echo -e "\n--- Step 2: Creating Podman network ---"
podman network create "$NETWORK_NAME"
echo "Network '$NETWORK_NAME' created."

echo -e "\n--- Step 3: Starting PostgreSQL server container ---"
podman run -d \
  --name "$SERVER_CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  -e POSTGRES_DB="$DB_NAME" \
  "$IMAGE_NAME"
echo "Server container '$SERVER_CONTAINER_NAME' started."

echo -e "\n--- Step 4: Waiting for database to be ready ---"
# Loop until pg_isready returns 0 (success)
until podman exec "$SERVER_CONTAINER_NAME" pg_isready -U "$DB_USER" -d "$DB_NAME" -q; do
  echo "PostgreSQL is unavailable - sleeping for 2 seconds..."
  sleep 2
done
echo "Database is ready to accept connections."

echo -e "\n--- Step 5: Running client tests ---"
# Use a temporary client container to run a series of SQL commands via a HERE document
podman run --rm \
  --name "$CLIENT_CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  -e PGPASSWORD="$DB_PASSWORD" \
  "$IMAGE_NAME" \
  psql -h "$SERVER_CONTAINER_NAME" -U "$DB_USER" -d "$DB_NAME" -a <<-EOF

-- Make the script exit on any error
\set ON_ERROR_STOP on

-----------------------------------------
-- TEST 0: ENABLE ALL EXTENSIONS
-----------------------------------------
\echo '==> Enabling extensions...'
CREATE EXTENSION IF NOT EXISTS vector;
-- AGE requires special setup
-- LOAD 'age';
SET search_path = ag_catalog, "\$user", public;
CREATE EXTENSION IF NOT EXISTS age;
CREATE EXTENSION IF NOT EXISTS pgroonga;
CREATE EXTENSION IF NOT EXISTS plpython3u;

\echo '==> Verifying extensions are installed:'
SELECT name FROM pg_extension WHERE name IN ('vector', 'age', 'pgroonga', 'plpython3u');
\echo 'All extensions enabled successfully.'

-----------------------------------------
-- TEST 1: PGVECTOR
-----------------------------------------
\echo '==> Testing pgvector...'
CREATE TABLE items (id serial PRIMARY KEY, embedding vector(3));
INSERT INTO items (embedding) VALUES ('[1,2,3]'), ('[4,5,6]'), ('[1,1,1]');
-- Find the vector closest to [1,1,1] using cosine distance
SELECT id, embedding FROM items ORDER BY embedding <=> '[1,1,1]' LIMIT 1;
\echo 'pgvector test successful.'

-----------------------------------------
-- TEST 2: APACHE AGE
-----------------------------------------
\echo '==> Testing Apache AGE...'
SELECT create_graph('my_graph');
-- Create a node using Cypher
SELECT * FROM cypher('my_graph', \$\$
    CREATE (p:Person {name: 'Alice', age: 30})
\$\$) AS (v agtype);
-- Query the node
SELECT * FROM cypher('my_graph', \$\$
    MATCH (p:Person) WHERE p.name = 'Alice' RETURN p.age
\$\$) AS (age agtype);
\echo 'Apache AGE test successful.'

-----------------------------------------
-- TEST 3: PGROONGA
-----------------------------------------
\echo '==> Testing PGroonga...'
CREATE TABLE documents (id serial PRIMARY KEY, content text);
CREATE INDEX pgrn_index ON documents USING pgroonga (content);
INSERT INTO documents (content) VALUES ('Hello world, this is Groonga!'), ('PostgreSQL is powerful.');
-- Search for documents containing "Groonga"
SELECT content FROM documents WHERE content &@~ 'Groonga';
\echo 'PGroonga test successful.'

-----------------------------------------
-- TEST 4: PL/PYTHON
-----------------------------------------
\echo '==> Testing PL/Python...'
CREATE OR REPLACE FUNCTION py_add(a integer, b integer)
RETURNS integer
AS \$\$
  return a + b
\$\$ LANGUAGE plpython3u;
-- Check the result of the function
SELECT py_add(5, 10) = 15;
\echo 'PL/Python test successful.'

EOF

# The exit code of the psql command will be checked by `set -e`
echo "All tests passed successfully!"

# --- Final Cleanup ---
# This block will run regardless of the script's success
cleanup() {
  echo -e "\n--- Final Step: Cleaning up server and network ---"
  podman stop "$SERVER_CONTAINER_NAME"
  podman rm -v "$SERVER_CONTAINER_NAME"
  podman network rm "$NETWORK_NAME"
  echo "Environment cleaned up."
}
trap cleanup EXIT
