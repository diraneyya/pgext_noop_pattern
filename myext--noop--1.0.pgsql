-- The actual implementation of the demo extension

------------------------------------------------------------------------------
-- CREATE IF NOT EXISTS STATEMENTS
------------------------------------------------------------------------------
-- The creation of these objects will be skipped during a hot-reload

create table if not exists myext_table (
    id smallserial,
    label text
);

------------------------------------------------------------------------------
-- CREATE OR REPLACE STATEMENTS
------------------------------------------------------------------------------
-- These objects will be updated instantly when reloading using the pattern

create or replace function myext_say(
    something text
) returns text language plpgsql as $say$
begin 
    insert into myext_table (label) values (something);
    return 'change this text to ensure the function was reloaded';
end $say$;
