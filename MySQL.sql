create database project;
use project;
select * from zomato;
select * from country_code;
desc zomato;

/** 1. Build a country Map Table"**/
select c.country_name,count(z.restaurant_id) count
from zomato z join country_code c 
on z.countrycode=c.country_code 
group by country_name order by 2 desc;

/** 2. Build a Calendar Table using the Column Datekey
  Add all the below Columns in the Calendar Table using the Formulas.**/
CREATE TABLE Calendar(
    DateKey DATE,
    Year INT,
    MonthNo INT,
    MonthFullName VARCHAR(20),
    Quarter VARCHAR(2),
    YearMonth VARCHAR(10),
    WeekdayNo INT,
    WeekdayName VARCHAR(15),
    FinancialMonth VARCHAR(4),
    FinancialQuarter VARCHAR(4)
);
INSERT INTO Calendar
SELECT 
    z.datekey_opening AS DateKey,

    /* A. Year */
    YEAR(z.datekey_opening),

    /* B. Month Number */
    MONTH(z.datekey_opening),

    /* C. Month Full Name */
    MONTHNAME(z.datekey_opening),

    /* D. Quarter */
    CONCAT('Q', QUARTER(z.datekey_opening)),

    /* E. Year-Month (YYYY-MMM) */
    DATE_FORMAT(z.datekey_opening, '%Y-%b'),

    /* F. Weekday Number (Monday = 1) */
    WEEKDAY(z.datekey_opening) + 1,

    /* G. Weekday Name */
    DAYNAME(z.datekey_opening),

    /* H. Financial Month (April = FM1 … March = FM12) */
    CONCAT(
        'FM',
        CASE
            WHEN MONTH(z.datekey_opening) >= 4 THEN MONTH(z.datekey_opening) - 3
            ELSE MONTH(z.datekey_opening) + 9
        END
    ),

    /* I. Financial Quarter */
    CASE
        WHEN MONTH(z.datekey_opening) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(z.datekey_opening) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(z.datekey_opening) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END

FROM Zomato z;
select * from calendar;

/** 3.Find the Numbers of Resturants based on City and Country.**/
select c.country_name,count(z.restaurant_id) as count
from zomato z join country_code c 
on z.countrycode=c.country_code
group by country_name order by count desc;
select city,count(restaurant_id) count
from zomato 
group by city order by 2 desc;
SELECT z.city,c.country_name,COUNT(z.restaurant_id) AS number_of_restaurants
FROM zomato z JOIN country_code c ON z.countrycode = c.country_code
GROUP BY z.city,c.country_name ORDER BY number_of_restaurants desc;

/** 4.Numbers of Resturants opening based on Year , Quarter , Month **/
select year(datekey_opening) as year,count(restaurant_id)
from zomato 
group by year order by year;
select month(datekey_opening)monthno, monthname(datekey_opening) as monthname,
count(restaurant_id)
from zomato 
group by monthname,monthno 
order by monthno;
select concat('Q',quarter(datekey_opening)) as quarter,
count(restaurant_id)
from zomato 
group by quarter order by quarter;

/** 5. Count of Resturants based on Average Ratings**/
SELECT 
CASE 
WHEN Rating BETWEEN 0 AND 1 THEN '0–1 Poor'
WHEN Rating BETWEEN 1.1 AND 2 THEN '1–2 Below Avg'
WHEN Rating BETWEEN 2.1 AND 3 THEN '2–3 Average'
WHEN Rating BETWEEN 3.1 AND 4 THEN '3–4 Good'
WHEN Rating BETWEEN 4.1 AND 5 THEN '4–5 Excellent'
ELSE 'No Rating'
END AS Rating_Bucket,
COUNT(Restaurant_ID) AS Restaurant_Count
FROM zomato
GROUP BY Rating_Bucket
ORDER BY Rating_Bucket;

/** 6. Create buckets based on Average Price of reasonable size and find out 
how many resturants falls in each buckets**/
select case
when average_cost_for_two between 0 and 1000 then '0-1000'
when average_cost_for_two between 1001 and 2000 then '1001-2000'
when average_cost_for_two between 2001 and 3000 then '2001-3000'
else '3++'
end as average_price,
count(restaurant_id) 
from zomato
group by average_price order by 2 desc;

/** 7.Percentage of Resturants based on "Has_Table_booking" **/
select Has_Table_booking,
concat(round( (count(*)/(select count(*) from zomato))* 100,2),'%') as percentage 
from zomato
group by 1 order by percentage;

/** 8.Percentage of Resturants based on "Has_Online_delivery"**/
select Has_Online_delivery,
concat(round( (count(*)/(select count(*) from zomato))* 100,2),'%') as percentage 
from zomato
group by 1 order by percentage;

/** 9. Develop Charts based on Cusines, City, Ratings**/

# Top 10 Cuisines By Count of Restaurants
select cuisines,count(restaurant_id) from zomato 
group  by cuisines
order by 2 desc limit 10;