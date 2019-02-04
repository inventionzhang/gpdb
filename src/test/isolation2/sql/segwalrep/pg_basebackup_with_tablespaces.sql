include: helpers/gp_management_utils_helpers.sql;

-- Ensure we have a clean slate to begin with
!\retcode rm -rf /tmp/some_isolation2_pg_basebackup;
!\retcode rm -rf /tmp/some_isolation2_pg_basebackup_tablespace;

-- Given a segment with a database that has a tablespace
!\retcode mkdir -p /tmp/some_isolation2_pg_basebackup_tablespace;

drop tablespace if exists some_isolation2_pg_basebackup_tablespace;
create tablespace some_isolation2_pg_basebackup_tablespace location '/tmp/some_isolation2_pg_basebackup_tablespace';

-- And a database using the tablespace
drop database if exists some_database_with_tablespace;
create database some_database_with_tablespace tablespace some_isolation2_pg_basebackup_tablespace;

-- When we create a full backup
select pg_basebackup(address, 100, port, 'some_replication_slot', '/tmp/some_isolation2_pg_basebackup', false) from gp_segment_configuration where content = 0 and role = 'p';

-- Then we should have a backup of the source segment files in the newly created target tablespace
select count_of_items_in_directory('/tmp/some_isolation2_pg_basebackup_tablespace/GPDB_*db100/');

-- When we create a full backup using force overwrite
select pg_basebackup(address, 200, port, 'some_replication_slot', '/tmp/some_isolation2_pg_basebackup', true) from gp_segment_configuration where content = 0 and role = 'p';

-- Then we should have a backup of the source segment files in the newly created target tablespace
select count_of_items_in_directory('/tmp/some_isolation2_pg_basebackup_tablespace/GPDB_*db200/');
