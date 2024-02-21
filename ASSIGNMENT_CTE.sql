/*1. First Normal Form (1NF)
 Identify a table in the Sakila database that violates 1NF. Explain how you would normalize it to achieve 1NF.*/
 
 - As the first normal form suggest:- 
       1. every column/attribute need to have a single value.  
       2. each row should be unique. (either through a single or multiple column)
       3. not necessary to have a primary key.  
       
- Considering such condition in 'actor_award' table I found that, in 'awards' column there are multiple entries in a single column.
  That violates the first normal form. 
- To  achieve the first normal  form I can split the multiple entries ( like-Emmy,Oscar,Tony) in different rows,
  such that there will be no multiple entries in a single column and the rows will be unique.
  
  
/*2. Second Normal Form (2NF)
  Choose a table in Sakila and describe how you would determine whether it is in 2NF. If it violates 2NF,
explain the steps to normalize it.*/

-As the second normal form suggests:-
      1. Must  be in first normal form.
      2. All non-key attribute must be fully  dependent on candidate key. If  a non-key column is partially 
         dependent on a candidate key then splite them into seperate table.
      3. remove redundency.   
	  3. Every table should have a primary key and  relationship  between the tables should be form using foreign key.
  
  - In "rental" table we can preform second normalization form. 
       1. I have noticed the 'inventory_id' have 4580 unique values,customer_id have 599 unique values , 
		  staff_id have 2 unique values.
       2. so these 3 columns create so much redundancy.
       3. To achive the second normalization form we can split the table into two.
           1. table-1 :-rental_id,rental_date,return_date,last_update,inventory_id (as foreign key)
           2. table-2 :-inventory_id(as a foreign key),customer_is,staff_id
	   4.   such that we can achieve the less redundancy.
       
       # whereas this normalization takes place according to our requirement. 
           
		

/*3. Third Normal Form (3NF)
  Identify a table in Sakila that violates 3NF. Describe the transitive dependencies present and outline the
steps to normalize the table to 3NF.*/        
      
- The criteria of 3NF is:-
           1. must be in 2NF
           2. avoid transitive dependencies.
           
- lets consider the "payment" table for 3NF.
     1. 'Payment' table can have multiple provision to transform it into different form with the help of 3NF.
         I pick one of them ,like- 'amount','payment_date','last_date' is not fully dependent on customer_id and staff_id.
         'Customer_id' and 'staff_id' is also redudent in this table.
     2. So, we can create a seperate table of 'staff_information' where we can assign 'payment_id','customer_id' and 'staff_id'.
		then remove the 'customer_id' and 'staff_id' from the payment table to nullify the transitive dependency of
        'customer_id' and 'staff_id' to 'payment_id'.
      Thus we can achieve the third normal form in the 'payment' table.

           





/* QUETION:-1 CTE BASIC:
Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have
acted in from the actor and film_actor table*/
use mavenmovies


-- # process:1
with
    actor_details as (select a.actor_id,concat(first_name," ",last_name) as actor_name,count(film_id) as actor_films_count
					from actor a
                    join film_actor fa
                    on a.actor_id=fa.actor_id
                    group by fa.actor_id)
select *
from actor_details 

-- # process:2

with
   film_count as (select actor_id,count(film_id) as actor_films_count
                 from film_actor
                 group by actor_id),
   actor_names as (select distinct actor_id,first_name,last_name
                  from actor),
  actor_details as ( select an.actor_id,concat(first_name," ",last_name) as actor_name,actor_films_count 
					from film_count  fc
                    join actor_names  an
                    on fc.actor_id=an.actor_id)
 select *
 from actor_details
 
 
 /* QUESTION:-2 RECURSIVE CTE:
 Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category
table in Sakila*/

/*since there is no sub-category_id in category table in sakila database , i have create a new category table and perform the task*/

-- Create Category table
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    name VARCHAR(50),
    subcategory_id INT
);

-- Insert data into Category table
INSERT INTO Category (category_id, name, subcategory_id) VALUES
(1, 'Action', NULL),
(2, 'Superhero', 1),
(3, 'Thriller', 1),
(4, 'War', 1),
(5, 'Drama', NULL),
(6, 'Fiction', 5),
(7, 'Roadtrip', 5),
(8, 'Music', 5);


--  here is the query 

with recursive category_h as(select category_id,name,subcategory_id
                             from category
                             union 
							 
                             select h.category_id,h.name,h.subcategory_id 
                             from category_h h
                             join category c
                             on c.category_id=h.subcategory_id)
select *
from category_h;  



/* QUESTION:-3 CTE WITH JOINS: 
Create a CTE that combines information from the film and language tables to display the film title, language
name, and rental rate */



with 
    film_language as (select film_id,title, name,rental_rate
                      from film m
                      join language l
                      on m.language_id=l.language_id )
 select title, name,rental_rate
 from film_language;
                      
/*QUESTION:-4 CTE for Aggregation>
 Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from
the customer and payment table*/


with
    customer_payment as (select c.customer_id,concat(first_name," ",last_name) as customer_name,revenue 
                         from (select customer_id, sum(amount) as revenue
                               from payment
	                           group by customer_id) x
						 join customer c
                         on x.customer_id=c.customer_id  )
 select *
 from  customer_payment;

/*QUESTION:-5 CTE with Window Functions:
 Utilize a CTE with a window function to rank films based on their rental duration from the film table*/
 
 
 with 
     film_r as (select film_id,title,rental_duration
               from film)
 select *, dense_rank() over( order by rental_duration desc) as ranking 
 from film_r;
 
 /* QUESTION:-6 CTE and Filtering:
 Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer
 table to retrieve additional customer details*/

 
 
with
    customer_rental as ( select  r.customer_id,concat(first_name," ",last_name) as customer_name,email,
                                  address_id,count(rental_id) as rental_count
                         from rental r
                         join customer c
                         on r.customer_id=c.customer_id
                         group by  r.customer_id) 
select *
from  customer_rental
where  rental_count>2;
 
/* QUESTION:-7 CTE for Date Calculations:
 Write a query using a CTE to find the total number of rentals made each month, considering the rental_date
from the rental table*/

with
    rental_made as (select monthname(rental_date) as month_name,rental_id
                    from rental)
select month_name,count(rental_id) as rental_per_month
from  rental_made
group by  month_name;

/* QUESTION:-8   CTE for Pivot Operations:
Use a CTE to pivot the data from the payment table to display the total payments made by each customer in
separate columns for different payment methods*/

with                                                              -- i do not find any payment methods in it
    customer_payment as (select customer_id,amount
                         from payment)
select customer_id,sum(amount) as total_payments
from  customer_payment  
group by customer_id
order by total_payments ;   



/*QUESTION:-9   CTE and Self-Join:
 Create a CTE to generate a report showing pairs of actors who have appeared in the same film together,
using the film_actor table*/    
                    
with 
actor_matching as (select  a.film_id , a.actor_id as  actor_one,b.actor_id as actor_two
                         from film_actor a
						 join film_actor b
                         on a.film_id=b.film_id
				         where a.actor_id < b.actor_id)

select *
from actor_matching;

/*QUESTION:-10 CTE foV Recursive Search:
Implement a recursive CTE to find all employees in the staff table who report to a specific manager,
considering the reports_to column.*/


/* as there is no report_to column I create a staff table (staff_id,name,report_to) and perform the query*/ 

-- Create the staff table
CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(255),
    report_to INT,
    FOREIGN KEY (report_to) REFERENCES staff(staff_id)
);

-- Insert data into the staff table
INSERT INTO staff (staff_id, name, report_to) VALUES
(1, 'John', NULL),
(4, 'Alice', 3),
(3, 'Bob', 5),
(5, 'Charlie', 6),
(6, 'David', 2),
(2, 'Eva', 1);


-- This is the query 

with recursive staff_manager as 
            ( select staff_id,name,report_to
              from staff
              
              union
              
              select sf.staff_id,sf.name,sf.report_to
              from staff_manager as sm
              join staff as sf
              on sf.staff_id=sm.report_to)
select *
from staff_manager;  




 
 

						




 
 
 
                    










 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



























