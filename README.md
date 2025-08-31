# PostgreSQL Extension Hot-Reloading Pattern

## Setup

Run the install script `install.sh` from a machine that has a PostgreSQL server running on it.

## Demonstration

After installing this demo extension, run these commands using `psql`, pgAdmin, or an IPython notebook using a SQL kernel:

```plpgsql
create extension myext;    -- WARNING: PLEASE USE "select myext_reload()" TO LOAD EXTENSION
select myext_reload();     -- ✅ EXTENSION IS NOW (RE)LOADED

select * from myext_table; -- extension-owned table is empty

select myext_say('hello'); -- shows: 'change this text to ensure the function was reloaded'
select * from myext_table; -- shows newly said/added thing which is 'hello'
```

Now try to edit the message text in [myext--noop--1.0.pgsql](./myext--noop--1.0.pgsql):

```plpgsql
create or replace function myext_say(
    something text
) returns text language plpgsql as $say$
begin 
    insert into myext_table (label) values (something);
    -- CHANGE THIS MESSAGE
    return 'change this text to ensure the function was reloaded';
end $say$;
```

After changing the source code of the extension, reload the extension using the utility function, and test to see if the message has changed:

```plpgsql
-- reloads the extension without recreating it
select myext_reload();     -- ✅ EXTENSION IS NOW (RE)LOADED

select * from myext_table; -- 'hello' is still there!

select myext_say('world'); -- shows the updated message!
select * from myext_table; -- shows 'hello' & 'world'
```

## Explanation

This repo demonstrates a simple yet a useful pattern in which the bulk of the postgres extension's SQL code is moved from the main script to an upgrade script, instead.

Along with a special, dummy (called 'noop' and stands for no-op or _no operation_) version of the extension, we are able to reload the extension by switching back and forth between 'noop' and the version under development ('1.0' in this case):

```PLpgSQL
alter extension myext update to 'noop';
alter extension myext update to '1.0';
```

Since the update script from 'noop' to '1.0' contains all of the object definitions of the extension (the procedures, functions and triggers). Doing this little dance is sufficient to reload or to update the definitions to match what is in the source code of the extension.

For some types of extensions, losing data in extension-managed tabels during development can be counter-productive, which is what this pattern is intended to address.