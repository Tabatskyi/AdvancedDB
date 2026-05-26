-- 1. Confirm total row count
SELECT count(*) FROM ecom_sales;

-- 2. Check table health in system views
SELECT relname, n_live_tup 
FROM pg_stat_user_tables 
WHERE relname = 'ecom_sales';

-- 3. Monitor active sessions (run while loading to see the COPY process)
SELECT pid, usename, state, query 
FROM pg_stat_activity 
WHERE state = 'active';
