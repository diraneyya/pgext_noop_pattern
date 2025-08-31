-- Unfortunately, we cannot automatically update from 'noop' to '1.0'
-- alter extension myext update to '1.0'; <<-- nested ALTER EXTENSION is not supported

create or replace function myext_reload ()
returns text language sql as $reload$
    alter extension myext update to 'noop';
    alter extension myext update to '1.0';
    select 'EXTENSION IS NOW (RE)LOADED';
$reload$;

do $$
begin 
    raise warning 'PLEASE USE "select myext_reload()" TO LOAD EXTENSION';
end $$;