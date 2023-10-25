-- 1) find scientists who participated in "Nauka 0+"
with nauka_id(id) as 
    (select id from conference c where c.name like 'Nauka 0+')
select distinct s.full_name
from scientists s join (
    select p.scientist_id, c.name 
    from conference c  join participation p on (c.id = p.conference_id)
    where c.id in (select id from nauka_id)
    ) cp 
on (s.id = cp.scientist_id)
;


-- 2) find scientists that dont participated in conferences
with ids(id) as (
    select id
    from scientists s 
    except
    select scientist_id 
    from participation p
)
select full_name 
from scientists s
where s.id in (select id from ids)
;


-- 3) top topics in popularity among scientists
select theme, count(*)
from specialization s 
group by theme
order by count(*) desc 
;


-- print Pup's themes
select theme
from specialization sp join scientists sc on (sp.scientist_id = sc.id)
where sc.full_name = 'PUP GOROHOVIY'
;


-- 4) swap "physics" topic to "math modelling" for Pup Gorohoviy 
-- ("math modeling" theme doesn't exist)

with pup_id as (
    select id 
    from scientists s
    where full_name = 'PUP GOROHOVIY'
)
update specialization 
set theme = 'math modeling'
where scientist_id = (select * from pup_id) and
      theme = 'physics'
;



-- 5) swap "physics" topic to "math" for Pup Gorohoviy 
-- ("math" theme exists)
with pup_id as (
    select id 
    from scientists s
    where full_name = 'PUP GOROHOVIY'
)
update specialization 
set theme = 'math'
where scientist_id = (select * from pup_id) and
      theme = 'physics'
;


-- 6) reset changes
with pup_id as (
    select id 
    from scientists s
    where full_name = 'PUP GOROHOVIY'
)
delete from specialization s 
where scientist_id in (select * from pup_id)
;
with pup_id as (
    select id 
    from scientists s
    where full_name = 'PUP GOROHOVIY'
)
insert into specialization(scientist_id, theme)
values ((select * from pup_id), 'physics'),
       ((select * from pup_id), 'quantum theory')
;


























