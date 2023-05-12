use marketing;
#2. Data Manipulation
#focus our reseaches on the 801 households who completed the surveys
#count the total household number
SELECT 
    COUNT(*) as total_household_number
FROM
    household;

#1.find them in the transactions table
SELECT 
    *
FROM
    transactions
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household);

#2.find them in the coupon table
SELECT 
    household_id, COUNT(*) AS coupon_amount
FROM
    coupon
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household)
GROUP BY household_id
ORDER BY coupon_amount DESC;

#2.1 Consumer Demopraphics
#create a new table with all the marital status in the extra status rather than code
SELECT 
    h.household_id,
    h.age,
    m.marital_status,
    h.income,
    h.household_size,
    h.kid_number
FROM
    household AS h
        INNER JOIN
    marital AS m ON m.marital_status_code = h.marital_status_code;
#export it and import back as household_m

#see if any null is in household
SELECT 
    COUNT(*)
FROM
    household
WHERE
    age IS NULL
        OR marital_status_code IS NULL
        OR income IS NULL
        OR household_size IS NULL
        OR kid_number IS NULL;

#count age range
SELECT 
    age, COUNT(age) AS age_range
FROM
    household
GROUP BY age;
#%
SELECT 
    age, ROUND(COUNT(age) / 801 * 100, 2) 
    AS 'age_range(%)'
FROM
    household
GROUP BY age;

#count income range
SELECT 
    income, COUNT(income) AS income_range
FROM
    household
GROUP BY income;
#%
SELECT 
    income, ROUND(COUNT(income)/801*100, 2) 
    AS 'income_range(%)'
FROM
    household
GROUP BY income;

#larger range group
SELECT 
    CASE
        WHEN income = 'Under 15K' OR income = '15-24K' THEN 'Under 24K'
        WHEN income = '25-34K' OR income = '35-49K' THEN '25-49K'
        WHEN income = '50-74K' OR income = '75-99K' THEN '50-99K'
        WHEN income = '100-124K' OR income = '125-149K' THEN '100-149K'
        WHEN income = '150-174K' OR income = '175-199K' THEN '150-199K'
        ELSE '200K+'
    END AS income_l,
    COUNT(*) AS income_range
FROM
    household
GROUP BY income_l;
#%
SELECT 
    CASE
        WHEN income = 'Under 15K' OR income = '15-24K' THEN 'Under 24K'
        WHEN income = '25-34K' OR income = '35-49K' THEN '25-49K'
        WHEN income = '50-74K' OR income = '75-99K' THEN '50-99K'
        WHEN income = '100-124K' OR income = '125-149K' THEN '100-149K'
        WHEN income = '150-174K' OR income = '175-199K' THEN '150-199K'
        ELSE '200K+'
    END AS income_l,
     ROUND(COUNT(*) / 801 * 100, 2) AS 'income_range(%)'
FROM
    household
GROUP BY income_l;

#count marital status
SELECT 
    marital_status, COUNT(marital_status) 
    AS marital_number
FROM
    household_m
GROUP BY marital_status;
#%
SELECT 
    marital_status,
    ROUND(COUNT(marital_status) / 801 * 100, 2) 
    AS 'marital_number(%)'
FROM
    household_m
GROUP BY marital_status;

#count household size
SELECT 
    household_size, COUNT(household_size) AS household_sizes
FROM
    household
GROUP BY household_size;
#%
SELECT 
    household_size, ROUND(COUNT(household_size)/801*100, 2) 
    AS 'household_sizes(%)'
FROM
    household
GROUP BY household_size;

#has kids or not
SELECT 
    household_id,
    IF(kid_number = 0,
        'no kid',
        'has kid(s)') AS kids_or_not
FROM
    household;
#count kid number
SELECT 
    kid_number, COUNT(kid_number) AS kid_numbers
FROM
    household
GROUP BY kid_number;
#%
SELECT 
    kid_number, ROUND(COUNT(kid_number)/801*100, 2) 
    AS 'kid_numbers(%)'
FROM
    household
GROUP BY kid_number;


#Coupon Redemption
#find top 50 households who used coupon most frequently
WITH top50_coupon_user AS
(SELECT 
    household_id, COUNT(*) AS coupon_amount
FROM
    coupon
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household)
GROUP BY household_id
ORDER BY coupon_amount DESC
LIMIT 50)
SELECT h.*, t.coupon_amount
FROM 
	top50_coupon_user AS t 
		INNER JOIN 
	household_m AS h USING(household_id);

#count each catergory
#1.income
WITH top50_coupon_user AS
(SELECT 
    household_id, COUNT(*) AS coupon_amount
FROM
    coupon
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household)
GROUP BY household_id
ORDER BY coupon_amount DESC
LIMIT 50)
SELECT h.income, count(*) as coupon_amount
FROM 
	top50_coupon_user AS t 
		INNER JOIN 
	household_m AS h USING(household_id)
    group by h.income;
    
#2.marital status
WITH top50_coupon_user AS
(SELECT 
    household_id, COUNT(*) AS coupon_amount
FROM
    coupon
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household)
GROUP BY household_id
ORDER BY coupon_amount DESC
LIMIT 50)
SELECT h.marital_status, count(*) as coupon_amount
FROM 
	top50_coupon_user AS t 
		INNER JOIN 
	household_m AS h USING(household_id)
    group by h.marital_status;



#2.2 Consumer Segmentation
# 1.calculate the number of household included in the transactions table
SELECT 
    COUNT(DISTINCT (household_id))
FROM
    transactions;

# 2.group transactions data by household_id
SELECT 
    *
FROM
    transactions
ORDER BY household_id ;

# 3.check for duplicate value
SELECT 
    *
FROM
    transactions
GROUP BY household_id , basket_id , product_id , quantity , sales_values
HAVING COUNT(household_id) > 1;

# 4. check for null value (method 1)
SELECT 
    *
FROM
    transactions
WHERE
    quantity IS NULL OR sales_values IS NULL
        OR basket_id IS NULL;

# 5. check for null value (method 2)
SELECT 
    COUNT(household_id),
    COUNT(basket_id),
    COUNT(product_id),
    COUNT(quantity),
    COUNT(sales_values)
FROM
    transactions;

# 6.calculate the frequency of shopping and total purchase amount on the household level
SELECT 
    household_id,
    COUNT(household_id) AS frequency,
    ROUND(SUM(sales_values), 2) AS total_purchase_amount
FROM
    transactions
GROUP BY household_id
ORDER BY household_id;# save as talbe namd 'transactions_hh'

# 7. mathematical description:
SELECT 
    MAX(total_purchase_amount) AS max_values,
    MIN(total_purchase_amount) AS min_values,
    ROUND(AVG(total_purchase_amount), 2) AS avg_values,
    MAX(total_purchase_amount) - MIN(total_purchase_amount) AS rng_values,
    MAX(frequency) AS max_freq,
    MIN(frequency) AS min_freq,
    ROUND(AVG(frequency), 2) AS avg_freq,
    MAX(quantity) AS max_quantity,
    MIN(quantity) AS min_quantity
FROM
    (SELECT 
        household_id,
            COUNT(household_id) AS frequency,
            ROUND(SUM(sales_values), 2) AS total_purchase_amount,
            COUNT(quantity) AS quantity
    FROM
        transactions
    GROUP BY household_id
    ORDER BY total_purchase_amount) AS sub1;


# 8. value range of top 25%, 25 ~ 50%,50% ~ 75%,75%~100% customers' purchase amount
SELECT 
    household_id, total_purchase_amount
FROM
    transaction_hh
ORDER BY total_purchase_amount DESC
LIMIT 200;#top 25% customes'purchase amount lies in [104.8,700)
SELECT 
    household_id, total_purchase_amount
FROM
    transaction_hh
ORDER BY total_purchase_amount DESC
LIMIT 200 , 200;#top 25%~50% customes'purchase amount lies in [63.65,104.8)
SELECT 
    household_id, total_purchase_amount
FROM
    transaction_hh
ORDER BY total_purchase_amount DESC
LIMIT 400 , 200;#top 50%~75% customes'purchase amount lies in [37.58,63.65)

# 9.divide customers into diff group based on purchase amount
SELECT 
    household_id, total_purchase_amount
FROM
    transaction_hh
ORDER BY total_purchase_amount DESC
LIMIT 600 , 200;#top 75%~100% customes'purchase amount lies in [0.33,37.58)
SELECT 
    t.household_id,
    CASE
        WHEN total_purchase_amount BETWEEN 104.8 AND 700 THEN 'Core Customer'
        WHEN total_purchase_amount BETWEEN 63.65 AND 104.8 THEN 'Main Customer'
        WHEN total_purchase_amount BETWEEN 37.58 AND 63.65 THEN 'Medium Customer'
        ELSE 'Small Customer'
    END AS customer_group,
    age,
    income,
    household_size,
    kid_number
FROM
    transaction_hh AS t
        LEFT JOIN
    household AS h ON t.household_id = h.household_id
LIMIT 10;

# 10. split household into different based on their frequency of shopping
select household_id,
	case when frequency> 25 then 'frequency above average'
    else 'frequency under average' end as frequency_group
from transaction_hh as t;

# 11.claculate the number of household in each frequency_group
select 
sum(case when frequency >25  then 1 else 0 end) as num_over_avg,
sum(case when frequency <25 then 1 else 0 end) as num_under_avg
from 
transaction_hh;

# 12. filter first_time client
SELECT 
    t.household_id, age, income, household_size, kid_number
FROM
    transactions AS t
        LEFT JOIN
    household AS h USING (household_id)
GROUP BY household_id
HAVING COUNT(household_id) = 1;

# 13. top 5 selling product and their share of total turnover
SELECT 
    t.product_id,
    ROUND(SUM(sales_values), 2) AS total_value,
    COUNT(t.product_id) AS popularity,
    CONCAT(CAST(ROUND((ROUND(SUM(sales_values), 2) / (SELECT 
                                SUM(sales_values)
                            FROM
                                transactions)) * 100,
                        2)
                AS CHAR),
            '%') AS percentage
FROM
    transactions AS t
        LEFT JOIN
    product AS p USING (product_id)
GROUP BY (t.product_id)
ORDER BY popularity DESC
LIMIT 5;
 
# 14. top5 high-spending customer
SELECT 
    t.household_id,
    COUNT(sales_values) AS total_amount_purchase,
    income,
    kid_number
FROM
    transactions AS t
        LEFT JOIN
    household AS h USING (household_id)
GROUP BY t.household_id
ORDER BY total_amount_purchase DESC
LIMIT 5;

# 15.coupon usage of high-value customers
SELECT 
    coupon.household_id, COUNT(coupon_upc)
FROM
    coupon
        INNER JOIN
    (SELECT 
        household_id, COUNT(sales_values) AS total_amount_purchase
    FROM
        transactions
    GROUP BY household_id
    ORDER BY total_amount_purchase DESC
    LIMIT 5) AS high_value_customers ON high_value_customers.household_id = coupon.household_id;

#2.3 Targeting Strategy
#Create a table which combined household, product and transactions tables
SELECT 
    h.household_id,
    age,
    h.marital_status_code,
    h.income,
    h.household_size,
    h.kid_number,
    t.product_id,
    quantity,
    sales_values
FROM
    household AS h
        INNER JOIN
    transactions AS t USING (household_id);
SELECT 
    ht.household_id, age, ht.marital_status_code, ht.income, ht.household_size,
    ht.kid_number, product_id, ht.quantity, ht.sales_values, p.category
    FROM
    household_transaction as ht
        INNER JOIN
    product AS p 
    USING (product_id);
    
#(1) Purchasing strategy
#Most popular products    
SELECT 
    category, COUNT(*) AS count
FROM
    household_transaction_product
GROUP BY category
ORDER BY count DESC;
#soft drinks, fluid milk, baked bread, cheese, frozen meat, crackers

#(2) Targeting household with children
#Things that households with children are likely to buy
SELECT 
    kid_number, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    kid_number != 0
GROUP BY category
ORDER BY count DESC;
#Fluid milk, soft drinks, baked bread, convenient breakfast, vegetables,cheese

#(3) Consumer insights of no-child families
#Things that households without children are likely to buy
SELECT 
    kid_number, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    kid_number = 0
GROUP BY category
ORDER BY count DESC;
#soft drinks, crackers, fluid milk, frozen pizza, forzen meat

#(4) Strategy for high-income households
#Things that high-income households are likely to buy
SELECT 
    income, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    income = '250K+' OR income = '200-249K'
        OR income = '175-199K'
        OR income = '150-174K'
        OR income = '125-149K'
        OR income = '100-124K'
GROUP BY category
ORDER BY count DESC;
#fluid milk products, baked bread, lunchmeat

#(5) For different-age groups
#Things that different age groups people are likely to buy
#the young
SELECT 
    age, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    age LIKE '1%' OR age LIKE '2%'
GROUP BY category
ORDER BY count DESC;
#soft drinks, fluid milk products, chicken

#the middle-age
SELECT 
    age, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    age LIKE '3%' OR age LIKE '4%'
GROUP BY category
ORDER BY count DESC;
#fluid milk products, baked bread, frozen meat

#the old
SELECT 
    age, category, COUNT(*) AS count
FROM
    household_transaction_product
WHERE
    age LIKE '5%' OR age LIKE '6%'
GROUP BY category
ORDER BY count DESC;
#fluid milk products, cheese, tropical fruit

#(6) Pricing Strategy
#compare the different sales value of different income household
SELECT 
    income,
    ROUND(AVG(CASE
                WHEN
                    income = '250K+' OR income = '200-249K'
                        OR income = '175-199K'
                        OR income = '150-174K'
                        OR income = '125-149K'
                        OR income = '100-124K'
                THEN
                    sales_values
            END),
            2) AS avg_sales_high
FROM
    household_transaction_product;
#3.89
SELECT 
    income,
    ROUND(AVG(CASE
                WHEN
                    income = 'Under 15K'
                        OR income = '15-24K'
                        OR income = '25-34K'
                        OR income = '35-49K'
                        OR income = '50-74K'
                        OR income = '75-99K'
                THEN
                    sales_values
            END),
            2) AS Avg_Sales_low
FROM
    household_transaction_product;
#3.09

#max and min size
SELECT 
    MAX(household_size) AS max_size,
    MIN(household_size) AS max_size
FROM
    household_transaction_product;

#(7) Most popular products from all age groups	
#popular products for all ages
WITH youth AS (SELECT age, category, COUNT(*) AS count
FROM household_transaction_product
WHERE age LIKE '1%' OR age LIKE '2%'
GROUP BY category
ORDER BY count DESC
limit 10), 
middle_age AS (SELECT age, category, COUNT(*) AS count
FROM household_transaction_product
WHERE age LIKE '3%' OR age LIKE '4%'
GROUP BY category
ORDER BY count DESC
LIMIT 10), 
old AS (SELECT age, category, count(*) AS count
FROM household_transaction_product
WHERE age LIKE '5%' or age LIKE '6%'
GROUP BY category
ORDER BY count DESC
LIMIT 10)
SELECT category FROM youth 
UNION 
SELECT category FROM middle_age 
UNION
SELECT category FROM old;

#(8) Stable family group
#stable households
SELECT DISTINCT
    (household_id),
    household_size,
    marital_status_code,
    sales_values,
    income
FROM
    household_transaction_product
WHERE
    household_id IN (SELECT 
            household_id
        FROM
            household_transaction_product
        WHERE
            marital_status_code = 'A'
                AND household_size BETWEEN 2 AND 4)
ORDER BY sales_values DESC;