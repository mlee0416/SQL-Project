
--1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;
--1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat_ws(" ", first_name, last_name) AS 'Actor Name' from actor;
--2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor where first_name = 'Joe';
--2b. Find all actors whose last name contain the letters GEN:
select first_name, last_name from actor where last_name like "%gen%";
--2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select first_name, last_name from actor where last_name like "%li%" 
order by last_name asc, first_name asc;
--2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan','Bangladesh','China');
--3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(45) null after first_name;
--3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor
change column middle_name middle_name BLOB null default null;
--3c. Now delete the middle_name column.
alter table actor 
drop column middle_name;
--4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) from actor group by last_name;
--4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as counts from actor group by last_name having count(last_name) > 1;
--4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO WILLIAMS' and last_name = "WILLIAMS";
--4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor set first_name = 'GROUCHO' where actor_id in 
(select actor_id from(select actor_id from actor where first_name = "HARPO" and last_name = "WILLIAMS") as aid);
--5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;
--6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address from staff s left join address a on (a.address_id = s.address_id);
--6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) from staff s left join payment p on (s.staff_id = p.staff_id) where p.payment_date like "%-08-%" group by p.staff_id;
--6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) as actors_in_movie from film_actor fa inner join film f on (f.film_id = fa.film_id) group by fa.film_id;
--6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) as number_of_copies from inventory where film_id in 
	(select film_id from film where title = "Hunchback Impossible");
--6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) from customer c left join payment p on (c.customer_id = p.customer_id) group by p.customer_id order by c.last_name asc;
    --![Total amount paid](Images/total_payment.png)
--7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film where (title like "Q%" or title like "K%") and language_id in 
    (select language_id from language where name = "English");
--7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id in
	(select actor_id from film_actor where film_id in
		(select film_id from film where title = 'Alone Trip'));
--7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email from customer 
	inner join address on (customer.address_id = address.address_id)
    inner join city on (address.city_id = city.city_id)
    inner join country on (city.country_id = country.country_id)
    where country = "Canada";
--7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select title from film where film_id in
	(select film_id from film_category where category_id in
    (select category_id from category where name = "Family"));
--7e. Display the most frequently rented movies in descending order.
select title, count(*) as rental_count from film f 
	inner join film_category fc on (f.film_id = fc.film_id)
    inner join category c on (fc.category_id = c.category_id)
    inner join inventory i on (f.film_id = i.film_id)
    inner join rental r on (r.inventory_id = i.inventory_id)
    where c.name = "Family"
    group by i.film_id
    order by rental_count desc;

select title, count(*) as rental_count from rental r
	inner join inventory i on (r.inventory_id = i.inventory_id)
    inner join film f on (f.film_id = i.film_id)
    group by f.film_id
    order by rental_count desc;
--7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as store_income from store s
	left join inventory i on (s.store_id = i.store_id)
    left join rental r on (r.inventory_id = i.inventory_id)
    left join payment p on (p.rental_id = r.rental_id)
    group by s.store_id;

--7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, country.country from store s
	left join address a on (s.address_id = a.address_id)
    left join city c on (a.city_id = c.city_id)
    left join country on (c.country_id = country.country_id);
--7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(amount) as gross_revenue from category c
	left join film_category fc on (c.category_id = fc.category_id)
	left join inventory i on (fc.film_id = i.film_id)
	left join rental r on (i.inventory_id = r.inventory_id)
    left join payment p on (p.rental_id = r.rental_id)
    group by c.category_id
    order by gross_revenue desc
    limit 5;
--8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
select c.name, sum(amount) as gross_revenue from category c
	left join film_category fc on (c.category_id = fc.category_id)
	left join inventory i on (fc.film_id = i.film_id)
	left join rental r on (i.inventory_id = r.inventory_id)
    left join payment p on (p.rental_id = r.rental_id)
    group by c.category_id
    order by gross_revenue desc
    limit 5;
--8b. How would you display the view that you created in 8a?
select * from top_five_genres;
--8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;
