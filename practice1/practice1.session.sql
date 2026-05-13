SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    backend_start,
    query_start,
    query
FROM pg_stat_activity;


SELECT
    pid,
    usename,
    now() - query_start AS duration,
    state,
    query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SHOW shared_preload_libraries;

SELECT query, calls, total_exec_time, rows, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

SELECT
    pid,
    usename,
    now() - query_start AS running_time,
    query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 minutes';

SELECT
    blocked.pid     AS blocked_pid,
    blocked.query   AS blocked_query,
    blocking.pid    AS blocking_pid,
    blocking.query  AS blocking_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks ON blocked.pid = blocked_locks.pid
JOIN pg_locks blocking_locks ON blocked_locks.locktype = blocking_locks.locktype
   AND blocked_locks.database IS NOT DISTINCT FROM blocking_locks.database
   AND blocked_locks.relation IS NOT DISTINCT FROM blocking_locks.relation
   AND blocked_locks.pid != blocking_locks.pid
JOIN pg_stat_activity blocking ON blocking.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- 1. Create the role with login capabilities
CREATE ROLE monitor_user WITH LOGIN PASSWORD 'secure_password';

-- 2. Grant connection and schema usage permissions
GRANT CONNECT ON DATABASE postgres TO monitor_user;
GRANT USAGE ON SCHEMA public TO monitor_user;

-- 3. Grant SELECT access to existing and future tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO monitor_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO monitor_user;
