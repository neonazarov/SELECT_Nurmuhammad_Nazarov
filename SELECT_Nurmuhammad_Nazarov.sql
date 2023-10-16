with StoreIncome as (
select
        store_id,
        s.staff_id,
        first_name,
        last_name,
sum(p.amount) as total_revenue
    from staff as s
    join payment as p on s.staff_id = p.staff_id
    where extract(year from p.payment_date) = 2017
    group by s.store_id, s.staff_id, s.first_name, s.last_name
),
RankIncome as (
    select
        store_id,
        staff_id,
        first_name,
        last_name,
        total_revenue,
        row_number() over (partition by store_id order by total_revenue desc) as ranking
    from StoreIncome
)
select store_id, staff_id, first_name, last_name, total_revenue
from RankIncome
where ranking = 1;



with Best_Movies as (
    select
        f.film_id,
        f.title as movie_title,
        COUNT(r.rental_id) as rental_count
    from film as f
    join inventory as i on f.film_id = i.film_id
    join rental as r on i.inventory_id = r.inventory_id
    group by f.film_id
    order by rental_count desc 
    limit 5
),
Movie_Rating as (
    select
        f.film_id,
        f.title as movie_title,
        case
            when f.rating = 'G' then '0+'
            when f.rating = 'PG' then '7+'
            when f.rating = 'PG-13' then '13+'
            when f.rating = 'R' then '17+'
            else 'Unknown'
        end as age_category
    from film as f
)
select
    pm.movie_title,
    pm.rental_count,
    age_category as expected_age
from Best_Movies as pm
join Movie_Rating as mr on pm.film_id = mr.film_id





with Actor_Last_Acted as (
    select
        a.actor_id,
        a.first_name,
        a.last_name,
        max(f.release_year) as last_act_year
    from
        actor as a
    join
        film_actor as fa on a.actor_id = fa.actor_id
    join
        film as f on fa.film_id = f.film_id
    group by 
        a.actor_id, a.first_name, a.last_name
)
, Latest_Year as (
    select 
        max(f.release_year) as latest_year
    from
        film as f
)
select
    actor_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    last_act_year
from
    Actor_Last_Acted as ala, Latest_Year as ly
where
    ala.last_act_year < ly.latest_year
order by
    ala.last_act_year;