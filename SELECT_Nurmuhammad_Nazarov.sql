-- 1. Highest Revenue by Staff Members for Each Store in 2017
-- A: Subquery and GROUP BY

SELECT store_id, staff_id, MAX(revenue) AS highest_revenue
FROM (
    SELECT store_id, staff_id, SUM(amount) AS revenue
    FROM payment
    JOIN rental ON rental.rental_id = payment.rental_id
    WHERE YEAR(payment_date) = 2017
    GROUP BY store_id, staff_id
) AS revenue_summary
GROUP BY store_id;

-- B: JOIN with a Ranked CTE for Filtering

WITH RankedRevenue AS (
    SELECT store_id, staff_id, SUM(amount) AS revenue,
           RANK() OVER(PARTITION BY store_id ORDER BY SUM(amount) DESC) AS rev_rank
    FROM payment
    JOIN rental ON rental.rental_id = payment.rental_id
    WHERE YEAR(payment_date) = 2017
    GROUP BY store_id, staff_id
)
SELECT store_id, staff_id, revenue
FROM RankedRevenue
WHERE rev_rank = 1;

---------------------------------------------------------------
-- 2.Top Five Movies Rented More Than Others and Expected Audience Age
-- Approach A: JOINs and GROUP BY

SELECT film_id, title, COUNT(rental_id) AS rental_count, 'Expected age range' AS audience_age
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY film_id
ORDER BY rental_count DESC
LIMIT 5;

-- B: Using Film Categories
-- This query assumes a link between films and their categories, which can influence the expected audience age
SELECT film.title, COUNT(rental.rental_id) AS rental_count, category.name AS genre, 'Expected age range' AS audience_age
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY film.film_id
ORDER BY rental_count DESC
LIMIT 5;

---------------------------------------------------------
-- 3.Actors/Actresses with Longer Periods Without Acting
-- Approach A: Using MAX Function
        
SELECT actor_id, MAX(DATEDIFF(CURDATE(), film_actor.last_update)) AS days_without_acting
FROM film_actor
GROUP BY actor_id
ORDER BY days_without_acting DESC;

-- Approach B: Using a Date Range

SELECT actor_id, DATEDIFF(CURDATE(), MAX(last_update)) AS days_since_last_movie
FROM film_actor
GROUP BY actor_id
ORDER BY days_since_last_movie DESC
LIMIT 1;


