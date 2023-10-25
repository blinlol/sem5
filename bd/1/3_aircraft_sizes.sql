-- compare aircraft sizes
with aircrafts as (
    select a.aircraft_code code, 
           s.fare_conditions fare,
	       count(*) count
    from aircrafts a left join seats s on a.aircraft_code = s.aircraft_code
    group by (a.aircraft_code, s.fare_conditions)
    order by a.aircraft_code
)
select  *, 
        max(count) over (partition by fare) as max_in_class
from aircrafts
order by code
;