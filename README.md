# PostgreSQL Extension Hot-Reloading Pattern

## Setup

Run the install script `install.sh` from a machine that has a PostgreSQL server running on it.

## Demonstration

After installing the demo extension, run these commands using `psql` or a similar tool:

```PLpgSQL
create extension myext;
select myext_reload();

select * from myext_table;

select myext_say('hello'); -- shows old message
select * from myext_table; -- shows 'hello'
```

Now try to edit the return text in [myext--noop--1.0.pgsql](./myext--noop--1.0.pgsql):

```PLpgSQL
create or replace function myext_say(
    something text
) returns text language plpgsql as $say$
begin 
    insert into myext_table (label) values (something);
    return 'change this text to ensure the function was reloaded';
end $say$;
```

And then run the following:

```PLpgSQL
-- reloads the extension without recreating it
select myext_reload();

select * from myext_table; -- 'hello' is still there

select myext_say('world'); -- shows updated message
select * from myext_table; -- shows 'hello' & 'world'
```

## Explanation

This repo demonstrates a useful pattern in which the bulk of a postgresql extension SQL code is moved from the main script to a upgrade script.

Using a dummy (called 'noop' and stands for no-op or _no operation_) version of the extension, we are able to reload the extension by switching back and forth between 'noop' and the actual version of the extension:

```PLpgSQL
alter extension myext update to 'noop';
alter extension myext update to '1.0';
```

This way, the update script from 'noop' to the real version of the extension will be called, allowing most of the definitions of the extension (i.e. procedures, functions and triggers) to be replaced.

The goal of this pattern is to avoid dropping and creating extensions, which leads to losing the data in extension-managed tables, which can be counterproductive during the development of certain extensions.