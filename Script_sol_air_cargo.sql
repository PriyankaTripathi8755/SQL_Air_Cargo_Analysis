-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- SQL PROJECT : AIR CARGO -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

create database aircargo;  # create database for project
Use aircargo;  # use database

/* Import mentioned tables using Import Wizard: 
Customer, 
passengers_on_flights, 
ticket_details and 
routes */

/* TASK 1 =======================
Create an ER diagram for the given airlines database. */

# ER Diagram :: refer to attached screenshot

/* TASK 2 ======================= 
Write a query to create a route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. 
Implement the check constraint for the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0. */

create table aircargo.route_details (
route_id int unique,
flight_num int check (flight_num > 0) ,
origin_airport varchar(50), 
destination_airport varchar(50), 
aircraft_id varchar(50), 
distance_miles int check (distance_miles > 0)
);

-- Import routes table using Import Wizard inside this table 

/* TASK 3 ======================= 
Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data from the passengers_on_flights table. */

-- method 1 
select * from aircargo.passengers_on_flights where route_id between 1 and 25;

-- method 2
select concat(first_name,' ',last_name) as 'Passengers' from aircargo.customer 
where customer_id in (select customer_id from aircargo.passengers_on_flights where route_id >=1 and route_id  <=25);

-- method 3
select t1.*, t2.route_id from aircargo.customer as t1 
inner join aircargo.passengers_on_flights as t2 on t1.customer_id=t2.customer_id 
where t2.route_id >=1 and t2.route_id  <=25;

/* TASK 4 ======================= 
Write a query to identify the number of passengers and total revenue in bussiness class from the ticket_details table. */

select count(customer_id) as no_of_passengers, sum(price_per_ticket) as total_revenue from aircargo.ticket_details where class_id = 'bussiness';
 
 /* TASK 5 ======================= 
Write a query to display the full name of the customer by extracting the first name and last name from the customer table. */

select concat(first_name,' ',last_name) as 'Full_Name' from aircargo.customer;

/* TASK 6 ======================= 
Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables. */

select * from aircargo.customer where customer_id in (select customer_id from aircargo.ticket_details);

/* TASK 7 ======================= 
Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table. */

-- method 1
select first_name, last_name from aircargo.customer 
where customer_id in (select customer_id from aircargo.ticket_details where brand='Emirates'); 

-- method 2
select distinct(t1.first_name), t1.last_name from aircargo.customer as t1 
inner join aircargo.ticket_details as t2 
where t1.customer_id=t2.customer_id and brand='Emirates'; 

/* TASK 8 ======================= 
Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table. */

SELECT customer_id, class_id FROM aircargo.passengers_on_flights 
WHERE class_id = 'economy plus' GROUP BY customer_id HAVING class_id = 'economy plus';

/* TASK 9 ======================= 
Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table. */

select if(sum(no_of_tickets*Price_per_ticket)>10000,'crossed_10k','not_crossed_10k') as 'Total_Revenue_Status' from aircargo.ticket_details;

/* TASK 10 ======================= 
Write a query to create and grant access to a new user to perform operations on a database. */

create user 'new_username'@'local_host' identified by 'qwert123';  
grant all privileges on Aircargo.* to 'new_username'@'local_host';    

flush privileges;  # cancelling access  

/* TASK 11 ======================= 
Write a query to find the maximum ticket price for each class using window functions on the ticket_details table. */

select distinct(class_id), max(Price_per_ticket) over (partition by class_id) as 'Max_ticket_price' from aircargo.ticket_details;

/* TASK 12 ======================= 
Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table. */

select customer_id, route_id from aircargo.passengers_on_flights where route_id = 4;

/* TASK 13 ======================= 
For the route ID 4, write a query to view the execution plan of the passengers_on_flights table. */

-- method 1
explain analyze select * from aircargo.passengers_on_flights where route_id = 4;   

-- method 2
explain select * from aircargo.passengers_on_flights where route_id = 4;
   
/* TASK 14 ======================= 
Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function. */

select aircraft_id, sum(no_of_tickets*Price_per_ticket) from aircargo.ticket_details 
group by aircraft_id with rollup;

/* TASK 15 ======================= 
Write a query to create a view with only business class customers along with the brand of airlines. */

create view business_class as select customer_id, brand from ticket_details where class_id='bussiness' order by brand;

/* TASK 16 ======================= 
Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. 
Also, return an error message if the table doesn't exist. */

delimiter //
create procedure passengers_details(in start_route int, in end_route int) 
begin
declare table_exists int default 0;
select count(*) into table_exists from information_schema.tables where table_schema = database() and table_name = 'passengers_on_flights';
if table_exists > 0 then 
select p.* from passengers_on_flights p where p.route_id between start_route and end_route order by p.route_id, p.customer_id;
else
signal sqlstate '45000' set message_text = 'Error: passengers_on_flights table does not exist';
end if;
end // 
delimiter ;

call passengers_details(5,7);  # calling procedure

/* TASK 17 ======================= 
Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles. */

delimiter // 
create procedure route_data () 
begin
select * from aircargo.routes where distance_miles > 2000;
end //
delimiter ;

call route_data();  # calling procedure

/* TASK 18 ======================= 
Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500. */

delimiter //
create procedure distance_category () 
begin
select *, case 
when distance_miles >=0 AND distance_miles <= 2000 then 'SDT'
when distance_miles >2000 AND distance_miles <=6500 then 'IDT'
when distance_miles >6500 then 'LDT'
end as distance_category
from aircargo.routes;
end //
delimiter ;

call distance_category();  # calling procedure

/* TASK 19 ======================= 
Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table. 
Condition: If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No. */

delimiter //
create function get_complimentary (class_id varchar(50)) returns varchar(10)
deterministic
begin
return case 
when class_id in ('Business', 'Economy Plus') then 'Yes'
else 'No'
end;
end // 
delimiter;
delimiter //
create procedure ticket_details()
begin
    select p_date, customer_id, class_id, get_complimentary(class_id) as complimentary_service
    from ticket_details;
end //
delimiter ;

call ticket_details();  # calling function

/* TASK 20 ======================= 
Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table. */

delimiter //
create procedure get_Scott()
begin
declare done int default 0;
declare cid int;
declare fname, lname varchar(250);
declare cur cursor for 
select customer_id, first_name, last_name from customer where last_name like '%Scott';
declare continue handler for not found set done = 1;
open cur;
fetch cur into cid, fname, lname;
if not done then
select cid as customer_id, fname as first_name, lname as last_name;
end if;
close cur;
end;
//
delimiter ;

call get_Scott() # calling procedure
  

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- END OF PROJECT -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
