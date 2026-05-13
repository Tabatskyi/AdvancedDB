CREATE TABLE IF NOT EXISTS lock_test(id int);

BEGIN;
LOCK TABLE lock_test IN ACCESS EXCLUSIVE MODE;
SELECT pg_sleep(60); -- This forces the tab to hold the lock for 1 full minute
COMMIT;