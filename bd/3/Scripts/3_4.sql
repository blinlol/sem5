-- Запрос к одной таблице, содержащий фильтрацию по нескольким полям.
-- Получить план выполнения запроса без использования индексов.
--Gather  (cost=1000.00..1218833.29 rows=537815 width=45)
--  Workers Planned: 1
--  ->  Parallel Seq Scan on participation p  (cost=0.00..1164051.79 rows=316362 width=45)
--        Filter: ((registration_date > '2023-08-01 00:00:00'::timestamp without time zone) AND (mark = 5))
set max_parallel_workers_per_gather =1;

explain 
select *
from participation p
where registration_date > '01.08.2023'::timestamp and mark = 5
;

-- Получить статистику выполнения запроса без использования индексов.
--Gather  (cost=1000.00..1218833.29 rows=537815 width=45) (actual time=0.397..12649.451 rows=520062 loops=1)
--  Workers Planned: 1
--  Workers Launched: 1
--  ->  Parallel Seq Scan on participation p  (cost=0.00..1164051.79 rows=316362 width=45) (actual time=0.023..12204.956 rows=260031 loops=2)
--        Filter: ((registration_date > '2023-08-01 00:00:00'::timestamp without time zone) AND (mark = 5))
--        Rows Removed by Filter: 30160268
--Planning Time: 0.087 ms
--Execution Time: 12669.523 ms
explain analyze 
select *
from participation p
where registration_date > '01.08.2023'::timestamp and mark = 5
;

-- Создать нужные индексы, позволяющие ускорить запрос.
drop index participation_regdate_index ;
create index participation_regdate_index on participation using btree (registration_date);

-- Получить план выполнения запроса с использованием индексов и сравнить с первоначальным планом.
-- Index Scan using participation_regdate_index on participation p  (cost=0.56..252029.63 rows=537815 width=45)
--   Index Cond: (registration_date > '2023-08-01 00:00:00'::timestamp without time zone)
--   Filter: (mark = 5)
explain
select *
from participation p
where registration_date > '01.08.2023'::timestamp and mark = 5
;

-- Получить статистику выполнения запроса с использованием индексов и сравнить с первоначальной статистикой.
--Index Scan using participation_regdate_index on participation p  (cost=0.56..252029.63 rows=537815 width=45) (actual time=0.185..8249.822 rows=520062 loops=1)
--  Index Cond: (registration_date > '2023-08-01 00:00:00'::timestamp without time zone)
--  Filter: (mark = 5)
--  Rows Removed by Filter: 4701208
--Planning Time: 0.123 ms
--Execution Time: 8287.330 ms
explain analyze
select *
from participation p
where registration_date > '01.08.2023'::timestamp and mark = 5
;

-- Оценить эффективность выполнения оптимизированного запроса
--ускорение на 35 процентов
--cost уменьшился на 78 процентов





-- Запрос к нескольким связанным таблицам, содержащий фильтрацию по нескольким полям
-- Получить план выполнения запроса без использования индексов.
--Gather  (cost=1000.42..66546.35 rows=116 width=4)
--  Workers Planned: 1
--  ->  Nested Loop  (cost=0.42..65534.75 rows=68 width=4)
--        ->  Parallel Seq Scan on event_description ed  (cost=0.00..64112.12 rows=591 width=4)
--              Filter: (to_tsvector(description) @@ to_tsquery('data | programmer & code'::text))
--        ->  Index Scan using events_pkey on events e  (cost=0.42..2.41 rows=1 width=4)
--              Index Cond: (id = ed.event_id)
--              Filter: (start_date > '2023-08-01 00:00:00'::timestamp without time zone)
explain 
select e.id
from events e join event_description ed on e.id = ed.event_id  
where e.start_date > '01.08.2023'::timestamp and 
      to_tsvector(ed.description) @@ to_tsquery('data | programmer & code')  
;

-- Получить статистику выполнения запроса без использования индексов.
--Gather  (cost=1000.42..66546.35 rows=116 width=4) (actual time=48.973..4574.312 rows=411 loops=1)
--  Workers Planned: 1
--  Workers Launched: 1
--  ->  Nested Loop  (cost=0.42..65534.75 rows=68 width=4) (actual time=52.475..4518.334 rows=206 loops=2)
--        ->  Parallel Seq Scan on event_description ed  (cost=0.00..64112.12 rows=591 width=4) (actual time=3.662..4494.024 rows=1696 loops=2)
--              Filter: (to_tsvector(description) @@ to_tsquery('data | programmer & code'::text))
--              Rows Removed by Filter: 98304
--        ->  Index Scan using events_pkey on events e  (cost=0.42..2.41 rows=1 width=4) (actual time=0.012..0.012 rows=0 loops=3393)
--              Index Cond: (id = ed.event_id)
--              Filter: (start_date > '2023-08-01 00:00:00'::timestamp without time zone)
--              Rows Removed by Filter: 1
--Planning Time: 0.257 ms
--Execution Time: 4574.450 ms
explain analyze
select e.id
from events e join event_description ed on e.id = ed.event_id  
where e.start_date > '01.08.2023'::timestamp and 
      to_tsvector(ed.description) @@ to_tsquery('data | programmer & code')  
;

-- Создать нужные индексы, позволяющие ускорить запрос.
drop index event_description_index;
create index event_description_index on event_description using GIN (to_tsvector('english', description));

-- Получить план выполнения запроса с использованием индексов и сравнить с первоначальным планом.
--Nested Loop  (cost=23.46..4076.31 rows=116 width=4)
--  ->  Bitmap Heap Scan on event_description ed  (cost=23.04..1657.11 rows=1005 width=4)
--        Recheck Cond: (to_tsvector('english'::regconfig, description) @@ to_tsquery('data | programmer & code'::text))
--        ->  Bitmap Index Scan on event_description_index  (cost=0.00..22.79 rows=1005 width=0)
--              Index Cond: (to_tsvector('english'::regconfig, description) @@ to_tsquery('data | programmer & code'::text))
--  ->  Index Scan using events_pkey on events e  (cost=0.42..2.41 rows=1 width=4)
--        Index Cond: (id = ed.event_id)
--        Filter: (start_date > '2023-08-01 00:00:00'::timestamp without time zone)
explain
select e.id
from events e join event_description ed on e.id = ed.event_id  
where e.start_date > '01.08.2023'::timestamp and 
      to_tsvector('english', ed.description) @@ to_tsquery('data | programmer & code')  
;


-- Получить статистику выполнения запроса с использованием индексов и сравнить с первоначальной статистикой.
--Nested Loop  (cost=23.46..4076.31 rows=116 width=4) (actual time=1.890..17.955 rows=411 loops=1)
--  ->  Bitmap Heap Scan on event_description ed  (cost=23.04..1657.11 rows=1005 width=4) (actual time=1.807..5.286 rows=3393 loops=1)
--        Recheck Cond: (to_tsvector('english'::regconfig, description) @@ to_tsquery('data | programmer & code'::text))
--        Heap Blocks: exact=2278
--        ->  Bitmap Index Scan on event_description_index  (cost=0.00..22.79 rows=1005 width=0) (actual time=1.235..1.236 rows=3393 loops=1)
--              Index Cond: (to_tsvector('english'::regconfig, description) @@ to_tsquery('data | programmer & code'::text))
--  ->  Index Scan using events_pkey on events e  (cost=0.42..2.41 rows=1 width=4) (actual time=0.003..0.003 rows=0 loops=3393)
--        Index Cond: (id = ed.event_id)
--        Filter: (start_date > '2023-08-01 00:00:00'::timestamp without time zone)
--        Rows Removed by Filter: 1
--Planning Time: 0.417 ms
--Execution Time: 18.077 ms
explain analyze
select e.id
from events e join event_description ed on e.id = ed.event_id  
where e.start_date > '01.08.2023'::timestamp and 
      to_tsvector('english', ed.description) @@ to_tsquery('data | programmer & code')  
;


-- Оценить эффективность выполнения оптимизированного запроса
-- более чем в 100 раз быстрее





-- без индекса 700мс, с ним 122мс
explain analyze
select *
from persons p 
where personal_data ->> 'first_name' = 'Peter'
;

drop index persons_firstname_index;
create index persons_firstname_index on persons using btree ((personal_data ->> 'first_name'));

select count(*) from persons;






-- секционирование

create table participation_partition (like participation) partition by range (registration_date);
alter table participation_partition add foreign key (person_id) references persons(id);
alter table participation_partition add foreign key (event_id) references events(id);

create table participation_7_12_2021 partition of participation_partition
for values from ('2021-07-01') to ('2022-01-01');

create table participation_1_6_2022 partition of participation_partition
for values from ('2022-01-01') to ('2022-07-01');

create table participation_7_12_2022 partition of participation_partition
for values from ('2022-07-01') to ('2023-01-01');

create table participation_1_6_2023 partition of participation_partition
for values from ('2023-01-01') to ('2023-07-01');

create table participation_7_12_2023 partition of participation_partition
for values from ('2023-07-01') to ('2024-01-01');

create index on participation_partition (registration_date);


select max(registration_date) from participation_partition pp;

-- не выполнились

select max(registration_date) from participation_partition  p;

begin;


insert into participation_partition (person_id, event_id, roles, registration_date, mark)
select person_id, event_id, roles, registration_date, mark from participation p 
where  registration_date >= '01.12.2021' and 
       registration_date < '01.01.2022';

create or replace procedure f() as $$
declare 
    low timestamp;
    high timestamp;
begin
	low := '01.01.2023';
    high := '01.05.2023';
	raise notice '% - %', low, high;
	insert into participation_partition (person_id, event_id, roles, registration_date, mark)
    select person_id, event_id, roles, registration_date, mark from participation p 
    where  registration_date >= low and 
           registration_date < high;
          
    low := '01.05.2023';
    high := '01.09.2023';
	raise notice '% - %', low, high;
	insert into participation_partition (person_id, event_id, roles, registration_date, mark)
    select person_id, event_id, roles, registration_date, mark from participation p 
    where  registration_date >= low and 
           registration_date < high;
    
	low := '01.09.2023';
    high := '01.01.2024';
	raise notice '% - %', low, high;
	insert into participation_partition (person_id, event_id, roles, registration_date, mark)
    select person_id, event_id, roles, registration_date, mark from participation p 
    where  registration_date >= low and 
           registration_date < high;
          
end
$$ language plpgsql

call f();
      
      
explain analyze
select * from participation_partition pp where registration_date > '09.09.2023';

begin;
drop partition 
      
      
      
      
      
      





































