- транзакция
Postgres: 
Транзакции — это фундаментальное понятие во всех СУБД. Суть транзакции в том, что она объединяет последовательность действий в одну операцию «всё или ничего». Промежуточные состояния внутри последовательности не видны другим транзакциям, и если что-то помешает успешно завершить транзакцию, ни один из результатов этих действий не сохранится в базе данных.
Все изменения записаны в память до завершения транзакции
Изменения, производимые открытой транзакцией, невидимы для других транзакций, пока она не будет завершена, а затем они становятся видны все сразу.
begin savepoint rollback to  commit	

Нарушение сериализации возможно на repeatable read и serializable. Это ситуация когда транзакция не может зафиксировать изменения, потому что строки которые она использует изменены к моменту завершения транзакции.

журнализация транзакций - функция СУБД, которая сохраняет информацию, необходимую для восстановления базы данных в предыдущее согласованное состояние в случае логических или физических отказов. В простейшем случае журнализация изменений заключается в последовательной записи во внешнюю память всех изменений, выполняемых в базе данных.

Durability - In database systems, durability is the ACID property that guarantees that the effects of transactions that have been committed will survive permanently, even in case of failures, including incidents and catastrophic events.

Типы триггеров: построчные/операторные, до/после/вместо
Срабатывают с операторами delete insert update

wiki: 
!!! (неполное определение, потому что не сказано про сохранение в бд - durability)
Транзакция — группа последовательных операций с базой данных, которая представляет собой логическую единицу работы с данными. Транзакция может быть выполнена либо целиком и успешно, соблюдая целостность данных и независимо от параллельно идущих других транзакций, либо не выполнена вообще, и тогда она не должна произвести никакого эффекта. 


- грязное чтение
Postgres:
Транзакция читает данные, записанные параллельной незавершённой транзакцией.
wiki:
Чтение данных, добавленных или изменённых транзакцией, которая впоследствии не подтвердится (откатится).

I:
1. begin transaction isolation level read uncommitted read write;
2. update scientists set country = USA where id = 1;
4. rollback; 
II:
3. select * from scientists;


- неповторяемое чтение
Postgres:
Транзакция повторно читает те же данные, что и раньше, и обнаруживает, что они были изменены другой транзакцией (которая завершилась после первого чтения).
wiki:
Ситуация, когда при повторном чтении в рамках одной транзакции ранее прочитанные данные оказываются изменёнными.

I:
1. begin;
2. select * from scientists where id = 1;
6. select * from scientists where id = 1;
7. commit;

II:
3. begin;
4. update scientists set country = USA where id = 1;
5. commit;


- фантомное чтение
Postgres:
Транзакция повторно выполняет запрос, возвращающий набор строк для некоторого условия, и обнаруживает, что набор строк, удовлетворяющих условию, изменился из-за транзакции, завершившейся за это время.
wiki:
Ситуация, когда при повторном чтении в рамках одной транзакции одна и та же выборка дает разные множества строк.

I:
1. begin;
2. select count(reports_count) from participation where reports_count > 0;
6. select count(reports_count) from participation where reports_count > 0;
7. commit;

II:
3. begin;
4. insert into participation(scientist_id, conference_id, reports_count) values (11, 10, 10);
5. commit;


- аномалия сериализации
Postgres
Результат успешной фиксации группы транзакций оказывается несогласованным при всевозможных вариантах исполнения этих транзакций по очереди.


- read uncommited
wiki
Если несколько параллельных транзакций пытаются изменять одну и ту же строку таблицы, то в окончательном варианте строка будет иметь значение, определённое всем набором успешно выполненных транзакций. При этом возможно считывание не только логически несогласованных данных, но и данных, изменения которых ещё не зафиксированы.


- read commited
Postgres
каждый запрос в транзакции видит снимок базы на момент выполнения запроса
wiki
Большинство промышленных СУБД, в частности, Microsoft SQL Server, PostgreSQL и Oracle Database, по умолчанию используют именно этот уровень. На этом уровне обеспечивается защита от чернового, «грязного» чтения, тем не менее, в процессе работы одной транзакции другая может быть успешно завершена и сделанные ею изменения зафиксированы. В итоге первая транзакция будет работать с другим набором данных.


- repeatable read
Postgres
Все запросы транзакции видят снимок базы, до начала выполнения транзакции. Возможны сбои сериализации
wiki
Уровень, при котором читающая транзакция «не видит» изменения данных, которые были ею ранее прочитаны. При этом никакая другая транзакция не может изменять данные, читаемые текущей транзакцией, пока та не окончена.


- serializable
Postgres
Параллельные запросы выполняются так, как будто они выполняются последовательно и независимо от порядка
wiki
Самый высокий уровень изолированности; транзакции полностью изолируются друг от друга. Результат выполнения нескольких параллельных транзакций должен быть таким, как если бы они выполнялись последовательно. Только на этом уровне параллельные транзакции не подвержены эффекту «фантомного чтения».


6) изменение неподходящих данных
create function country_trigger() returns trigger as $country_trigger$
    begin 
	    if new.country is null or new.country = '' then
	        new.country := 'Russia';
	    end if;
	    return new;
    end;
$country_trigger$ language plpgsql;

create trigger country_trigger
before insert or update
on scientists
for each row
execute function country_trigger()
;

insert into scientists(full_name)
values ('NEW1');

select * from scientists s where full_name = 'NEW1';



transaction isolation level read uncommitted read write


1.2) потерянных изменений (невозможны ни на одном уровне изоляции)

!!! (это написал теймур, только так может проявиться потерянные изменения, если бы они могли вообще проявиться)

I:
1. begin transaction isolation level read uncommitted read write;
2. select x= count
3. update participation set count = x + 1
   where scientist_id = 2 and conference_id = 1;
6. rollback;

II:
3. begin transaction isolation level read uncommitted read write;
4. update participation set count = count + 3
   where scientist_id = 2 and conference_id = 1;
5. commit;







--------------------------------------------------------------------------

































1.1) грязное чтение (чтение данных незавершенной транзакции)
I:
1. select * from themes;
4. select * from themes;

II:
2. begin transaction isolation level read uncommitted read write;
3. insert into themes values ('NEW1');
5. commit;

1.2) потерянных изменений (невозможны ни на одном уровне изоляции)
I:
1. begin transaction isolation level read uncommitted read write;
2. 
select x= count


update participation set count = x + 1
where scientist_id = 2 and conference_id = 1;
6. rollback;

II:
3. begin transaction isolation level read uncommitted read write;
4. update participation set count = count + 3
where scientist_id = 2 and conference_id = 1;
5. commit;

2.1) грязное чтение
I:
1. set session characteristics as transaction read commited;
2. select * from themes;
6. select * from themes;

II:
3. set session characteristics as transaction isolation level read committed;
4. begin;
5. insert into themes values ('NEW1');
7. commit;

2.2) неповторяющееся чтение
I:
1. begin transaction isolation level read committed;
2. select * from themes;
6. select * from themes;
7. commit;

II:
3. begin transaction isolation level read committed;
4. insert into themes values ('NEW2');
5. commit;


3.1) неповторяющееся чтение
I:
1. begin transaction isolation level repeatable read;
2. select * from themes;
6. select * from themes;
7. commit;

II:
3. begin transaction isolation level repeatable read;
4. insert into themes values ('NEW2');
5. commit;

3.2) фантомное чтение
I:
1. begin transaction isolation level repeatable read;
2. select * from themes where name like 'NEW_';
6. select * from themes where name like 'NEW_';
7. commit;

II:
3. begin transaction isolation level repeatable read;
4. insert into themes values ('NEW2');
5. commit;


4) фантомное чтение
I:
1. begin transaction isolation level repeatable read;
2. select * from themes where name like 'NEW_';
6. select * from themes where name like 'NEW_';
7. commit;

II:
3. begin transaction isolation level repeatable read;
4. insert into themes values ('NEW2');
5. commit;


5) откат при нарушениии целостности
create function first_trigger() returns trigger as $first_trigger$
    begin
    	if new.name = '' then
    	    raise exception 'empty theme name';
    	end if;
    end;
$first_trigger$ language plpgsql;

create trigger first_trigger 
before insert or update
on themes
for each row
execute function first_trigger()
;

insert into themes values ('');


6) изменение неподходящих данных
create function second_trigger() returns trigger as $second_trigger$
    begin 
	    if new.country is null or new.country = '' then
	        new.country := 'Russia';
	    end if;
	    return new;
    end;
$second_trigger$ language plpgsql;

create trigger second_trigger
before insert or update
on scientists
for each row
execute function second_trigger()
;

insert into scientists(full_name)
values ('NEW1');

select * from scientists s where full_name = 'NEW1';






















