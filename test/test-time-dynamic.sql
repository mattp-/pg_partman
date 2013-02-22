-- ########## TIME DYNAMIC TESTS ##########

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true

BEGIN;
SELECT set_config('search_path','partman, tap',false);

SELECT plan(61);
CREATE SCHEMA partman_test;
CREATE ROLE partman_basic;
CREATE ROLE partman_revoke;
CREATE ROLE partman_owner;

CREATE TABLE partman_test.time_dynamic_table (col1 int primary key, col2 text, col3 timestamptz NOT NULL DEFAULT now());
INSERT INTO partman_test.time_dynamic_table (col1, col3) VALUES (generate_series(1,10), CURRENT_TIMESTAMP);
GRANT SELECT,INSERT,UPDATE ON partman_test.time_dynamic_table TO partman_basic;
GRANT ALL ON partman_test.time_dynamic_table TO partman_revoke;

SELECT create_parent('partman_test.time_dynamic_table', 'col3', 'time-dynamic', 'daily');
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD')||' exists');
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD')||' exists');
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT hasnt_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 
    'Check partman_revoke privileges of time_dynamic_table_'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 
    'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 
    'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 
    'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 
    'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));

SELECT create_prev_time_partition('partman_test.time_dynamic_table');
SELECT is_empty('SELECT * FROM ONLY partman_test.time_dynamic_table', 'Check that parent table has had data moved to partition');
SELECT results_eq('SELECT count(*)::int FROM partman_test.time_dynamic_table', ARRAY[10], 'Check count from parent table');
SELECT results_eq('SELECT count(*)::int FROM partman_test.time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 
    ARRAY[10], 'Check count from time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON partman_test.time_dynamic_table FROM partman_revoke;
INSERT INTO partman_test.time_dynamic_table (col1, col3) VALUES (generate_series(11,20), CURRENT_TIMESTAMP + '1 day'::interval);
INSERT INTO partman_test.time_dynamic_table (col1, col3) VALUES (generate_series(21,25), CURRENT_TIMESTAMP + '2 days'::interval);

SELECT is_empty('SELECT * FROM ONLY partman_test.time_dynamic_table', 'Check that parent table has had no data inserted to it');
SELECT results_eq('SELECT count(*)::int FROM partman_test.time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 
    ARRAY[10], 'Check count from time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT results_eq('SELECT count(*)::int FROM partman_test.time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 
    ARRAY[5], 'Check count from time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));

UPDATE part_config SET premake = 5 WHERE parent_table = 'partman_test.time_dynamic_table';
SELECT run_maintenance();
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT hasnt_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT'], 'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'));

GRANT DELETE ON partman_test.time_dynamic_table TO partman_basic;
REVOKE ALL ON partman_test.time_dynamic_table FROM partman_revoke;
ALTER TABLE partman_test.time_dynamic_table OWNER TO partman_owner;

UPDATE part_config SET premake = 6 WHERE parent_table = 'partman_test.time_dynamic_table';
SELECT run_maintenance();
SELECT has_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT hasnt_table('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'7 days'::interval, 'YYYY_MM_DD'), 
    'Check time_dynamic_table_'||to_char(CURRENT_TIMESTAMP+'7 days'::interval, 'YYYY_MM_DD')||' exists');
SELECT col_is_pk('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), ARRAY['col1'], 
    'Check for primary key in time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), 'partman_revoke', 
    ARRAY['SELECT'], 'Check partman_revoke privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'));
-- Currently unable to test that all privileges have been revoked. Sent in request to pgtap developer.
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'));

INSERT INTO partman_test.time_dynamic_table (col1, col3) VALUES (generate_series(200,210), CURRENT_TIMESTAMP + '20 days'::interval);
SELECT results_eq('SELECT count(*)::int FROM ONLY partman_test.time_dynamic_table', ARRAY[11], 'Check that data outside trigger scope goes to parent');

SELECT reapply_privileges('partman_test.time_dynamic_table');
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_privs_are('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 'partman_basic', 
    ARRAY['SELECT','INSERT','UPDATE', 'DELETE'], 
    'Check partman_basic privileges of time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'1 day'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'2 days'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'3 days'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'4 days'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'5 days'::interval, 'YYYY_MM_DD'));
SELECT table_owner_is ('partman_test', 'time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'), 'partman_owner', 
    'Check that ownership change worked for time_dynamic_table_p'||to_char(CURRENT_TIMESTAMP+'6 days'::interval, 'YYYY_MM_DD'));



SELECT * FROM finish();
ROLLBACK;