--WK07 IN Class Notes

CREATE TABLE dogs (
	dog_id      integer,
	dog_name	varchar(40) NOT NULL,
	dog_breed	varchar(40) NOT NULL,
	birthdate	date
	CONSTRAINT dog_id PRIMARY KEY);

INSERT INTO dogs (dog_id, dog_name, dog_breed, birthdate)
VALUES (1, 'Brutus', 'boxer','2012-05-15'),
	(2,'Jack','mini aussie','2019-10-08');

-- References: 
-- https://www.postgresql.org/docs/9.1/sql-createtable.html
-- https://www.postgresqltutorial.com/postgresql-create-table/

--Homework from Week 06
--Rental Question -- good answer
SELECT
COUNT(CASE
WHEN rental_duration > date_part('day',return_date - rental_date) THEN 'Returned Early'
	END) AS Return_Early,
COUNT (CASE
	WHEN rental_duration < date_part('dat', return_date - rental_date) THEN 'Returned Late'
	END) AS Return_Late,
COUNT(CASEWHEN rental_duration = date_part('day', return_date - rental_date) THEN 'Returned on time'
END) AS Return_Ontime

FROM film
INNER JOIN inventory
	USING (film_id)
INNER JOIN rental_date
	USING (inventory_id);

-- SQL is set-based, Python is procedural
-- SQL think of it as a set, not individual pieces of data, each query returns a set; Python is line by line to process data, can make it slower also

--Degrees of relationship in a database
--  O = optional   | = mandatory

--Data modeling


--Data stewardship
--FAIR (Findable, Accessible, Interoperable, Reusable)


--Subqueries
--query nested in a larger query
--inner query is used in the parent query
--can take a lot longer to execute, so not used unless a JOIN is not an option
--often used to update, insert, and delete
SELECT column_name
FROM table_name
WHERE column_name operator ANY/all
(SELECT column_name FROM table_name
WHERE condition);

--subquery example; find films ith replacement costs that are greater than the average replacement cost
SELECT film_id, title, replacement_cost
FROM film
WHERE replacement_cost > 
(SELECT AVG(replacement_cost) as avg_replacement
FROM film)
ORDER BY replacement_cost DESC;