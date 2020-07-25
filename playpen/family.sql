.echo on
.headers on

-- Name: James Silcott
-- File: family.sql
-- Date: July 2, 2020

drop table if exists family;

create table family (
		id integer primary key,
		name text,
		sex integer,
		role text,
		age integer
);

insert into family values (1,"James",1,"Parent",42);
insert into family values (2,"Zoey",0,"Parent",43);
insert into family values (3,"Tristan",1,"Child",8);
insert into family values (4,"Vivian",0,"Child",5);
insert into family values (5,"Teddy",0,"Pet",1);


select * from family;
select * from family where sex = 1;
select * from family where role like "Parent";
select * from family where role like "Pet";
select name from family;
select avg(age) from family;
select sum(age) from family;


