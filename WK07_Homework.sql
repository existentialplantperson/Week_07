-- Week 07 Homework
-- Angela Spencer 11/03/21

--1.	Create a new column called “status” in the rental table that uses a case statement to indicate if a film was returned late, early, or on time. 
SELECT                   --SELECT the CASE statement as a column
	CASE WHEN rental_duration >
		EXTRACT(DAY FROM return_date-rental_date)   --extract day from dates
		THEN 'Returned early.'     --extract day from dates to determine if rental duration was greater than or less than actual rental time
	WHEN rental_duration <
		EXTRACT(DAY FROM return_date-rental_date)
		THEN 'Returned late.' 
		ELSE 'Returned on time.' END AS status --end as dates being equal
FROM rental AS r  --rental table for rental_date and return_date
LEFT JOIN inventory AS i  -- needed to connect rental and film
	ON r.inventory_id = i.inventory_id
LEFT JOIN film as f  -- for rental_duration
	ON i.film_id = f.film_id;

---------------------------------------------------------------
--2.	Show the total payment amounts for people who live in Kansas City or Saint Louis. 
SELECT  
--select customer info and sum of payment amounts
	c.first_name,   
	c.last_name
	address,
	city.city, 
	SUM(p.amount) AS total_payment
--from payment table
FROM payment AS p
--join sutomer table to get first and last name
LEFT JOIN customer AS c
	ON p.customer_id = c.customer_id
--join address table to get address and city id
LEFT JOIN address AS a
	ON c.address_id = a.address_id
join city to get city name
LEFT JOIN city 
	ON a.city_id = city.city_id
--sort by two selected cities
WHERE city.city = 'Kansas City'
	OR city.city = 'Saint Louis'
--groupby remaining columns
GROUP BY city.city, a.address, c.first_name, c.last_name;

-------------------------------------------------------------
--3.	How many films are in each category? Why do you think there is a table for category and a table for film category?
SELECT
--select category name and a county of film titles
	c.name AS category, 
	COUNT(f.title) AS film_count
--from film table
FROM film as f
--join film_category as a intermediary
LEFT JOIN film_category AS fc
	ON f.film_id = fc.film_id
--join category to access category names
LEFT JOIN category AS c
	ON fc.category_id = c.category_id
--group by category names
GROUP BY category;

--There may be the intermediary table of film_category because there would be too much data to work with in a single table that held the category names and ids along with all of the film information.

---------------------------------------------------------------
--4.	Show a roster for the staff that includes their email, address, city, and country (not ids)
SELECT
--select all values from 4 tables
	s.first_name, 
	s.last_name,
	s.email, 
	a.address, 
	ci.city, 
	co.country
--from staff to access first name, last name, and email
FROM staff AS s
--join address to access address
LEFT JOIN address AS a
	ON s.address_id = a.address_id
--join city to access city name    
LEFT JOIN city as ci
	ON a.city_id = ci.city_id
--join country to access country name
LEFT JOIN country as co
	ON ci.country_id = co.country_id;

---------------------------------------------------------------
--5.	Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
SELECT
--select desired columns from tables with alias names
	f.film_id,
	f.title,
	f.length,
	r.return_date
--from film to retrieve film_id, title, and length
FROM film AS f
--join inventory as intermediary 
LEFT JOIN inventory AS i
	ON f.film_id = i.film_id
--join rental to access return_date
LEFT JOIN rental AS r
	ON i.inventory_id = r.inventory_id
--filter for desired dates
WHERE return_date >= '2005-05-15'
	AND return_date <= '2005-05-31'
--order by date
ORDER BY return_date;

---------------------------------------------------------------
--6.	Write a subquery to show which movies are rented below the average price for all movies. 
SELECT
--select title and rental rate
	title,
	rental_rate
--from film table
FROM film
--filter for rental rate less than subquery
WHERE rental_rate <
--subquery = average rental_rate
	(SELECT AVG(rental_rate)
	FROM film)
--order by title
ORDER BY title;

---------------------------------------------------------------
--7.	Write a join statement to show which movies are rented below the average price for all movies.

SELECT
--select title, rental_rate and average rental rate
	f1.title,
	f1.rental_rate, 
--calculate average rental rate
	AVG(f2.rental_rate) AS avg_rate
--from film as f1
FROM film AS f1
--cross join on same table to show aggregate column
CROSS JOIN film AS f2
--filter for rentals that are less than the average rental cost
WHERE f1.rental_rate < 2.98
--group by and order by
GROUP BY f1.title, f1.rental_rate
ORDER BY f1.title;

---------------------------------------------------------------
--8.	Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.
/*
EXPLAIN ANALYZE #6
"Sort  (cost=146.96..147.80 rows=333 width=21) (actual time=3.745..3.764 rows=341 loops=1)"
"  Sort Key: film.title"
"  Sort Method: quicksort  Memory: 50kB"
"  InitPlan 1 (returns $0)"
"    ->  Aggregate  (cost=66.50..66.51 rows=1 width=32) (actual time=0.889..0.890 rows=1 loops=1)"
"          ->  Seq Scan on film film_1  (cost=0.00..64.00 rows=1000 width=6) (actual time=0.013..0.374 rows=1000 loops=1)"
"  ->  Seq Scan on film  (cost=0.00..66.50 rows=333 width=21) (actual time=0.936..1.699 rows=341 loops=1)"
"        Filter: (rental_rate < $0)"
"        Rows Removed by Filter: 659"
"Planning Time: 0.433 ms"
"Execution Time: 3.917 ms"


EXPLAIN ANALYZE #7
"Sort  (cost=6969.96..6970.81 rows=341 width=53) (actual time=575.745..575.766 rows=341 loops=1)"
"  Sort Key: f1.title"
"  Sort Method: quicksort  Memory: 51kB"
"  ->  HashAggregate  (cost=6951.35..6955.61 rows=341 width=53) (actual time=573.784..574.127 rows=341 loops=1)"
"        Group Key: f1.title, f1.rental_rate"
"        Batches: 1  Memory Usage: 285kB"
"        ->  Nested Loop  (cost=0.00..4393.85 rows=341000 width=27) (actual time=0.051..152.532 rows=341000 loops=1)"
"              ->  Seq Scan on film f2  (cost=0.00..64.00 rows=1000 width=6) (actual time=0.025..1.323 rows=1000 loops=1)"
"              ->  Materialize  (cost=0.00..68.20 rows=341 width=21) (actual time=0.000..0.050 rows=341 loops=1000)"
"                    ->  Seq Scan on film f1  (cost=0.00..66.50 rows=341 width=21) (actual time=0.018..0.742 rows=341 loops=1)"
"                          Filter: (rental_rate < 2.98)"
"                          Rows Removed by Filter: 659"
"Planning Time: 0.472 ms"
"Execution Time: 575.951 ms"


Comparing the explain plan of the subquery solution to the join solution shows that the subquery was executed significantly faster and with fewer steps than the join solution.

The subquery path for performing this operations was:
Sort > Aggregate > Seq Scan 
executiuon time = 3.917ms

While the join pathway was:
Sort > Hash Aggregate > Nested Loop > Seq Scan > Materialize > Seq Scan
execution time = 575.951ms

*/

---------------------------------------------------------------
--9.	With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 
SELECT 
--select title and length of film
	title, 
	length, 
--select NTILE to calculate percentile as new column    
	NTILE(100) OVER(PARTITION BY length)
	AS percentile
--all data from film table    
FROM film
--order by percentile column descending
ORDER BY percentile DESC;

---------------------------------------------------------------
--10.	In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are. 

/*
Procedural programming is specific and tells  the system explicitly what to do and what logic and algorithems to use to execute the program while set based programming provides the operational conditions and the logic is completed internally without specification from the user
*/

---------------------------------------------------------------
--Bonus: Find the relationship that is wrong in the data model. Explain why it’s wrong. 
