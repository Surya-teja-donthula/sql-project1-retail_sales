SELECT * FROM retail_sales
WHERE transactions_id IS NULL OR 
	   sale_date IS NULL OR
	   sale_time IS NULL OR
	   customer_id IS NULL OR
	   gender IS NULL OR
	   age IS NULL OR
	   category IS NULL OR
	   quantiy IS NULL OR
	   price_per_unit IS NULL OR
	   cogs	IS NULL OR
	   total_sale IS NULL;

--

DELETE FROM retail_sales
WHERE transactions_id IS NULL OR 
	   sale_date IS NULL OR
	   sale_time IS NULL OR
	   customer_id IS NULL OR
	   gender IS NULL OR
	   age IS NULL OR
	   category IS NULL OR
	   quantiy IS NULL OR
	   price_per_unit IS NULL OR
	   cogs	IS NULL OR
	   total_sale IS NULL;

--

SELECT COUNT(*) FROM retail_sales;


-- data exploration
-- how many sales we have?

SELECT COUNT(*) AS total_sales FROM retail_sales;


--how many unique cutomers we have

SELECT COUNT(DISTINCT customer_id) AS total_sales FROM retail_sales;


-- how many unique categories we have


SELECT COUNT(DISTINCT category) AS total_sales FROM retail_sales;

-- DATA ANALYSIS OR BUSINESS PROBLEMS AND ANSWERS


-- Q1) Write a SQL query to retrieve all columns for sales made on '2022-11-05:





SELECT * FROM retail_sales
WHERE sale_date = '2022-11-02';


-- q2)Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:


SELECT * FROM retail_sales
WHERE category='Clothing' AND
      quantiy>=4 AND
	  TO_CHAR(sale_date,'YYYY-MM') = '2022-10'


-- q3)Write a SQL query to calculate the total sales (total_sale) and total orders for each category.:

SELECT Category,SUM(total_sale) AS category_sale,COUNT(*) AS total_orders FROM retail_sales
GROUP BY Category;

-- q4)Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:


SELECT ROUND(AVG(age),2) AS new_age,Category FROM retail_sales
WHERE Category = 'Beauty'
GROUP BY Category;

-- q5)Write a SQL query to find all transactions where the total_sale is greater than 1000.:


SELECT transactions_id,total_sale FROM retail_sales
WHERE total_sale>1000;


-- q6)Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:

SELECT COUNT(*) AS total_transactions,gender,Category FROM retail_sales
GROUP BY Category,gender ORDER BY 1;

-- q7)Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT  
		year,
		month,
		avg_sale,
		rank
		FROM
		(
     SELECT 
	 EXTRACT(YEAR FROM sale_date) AS year,
	 EXTRACT(MONTH FROM sale_date) AS month,
	 AVG(total_sale) AS avg_sale,
					RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
					FROM retail_sales
					GROUP BY 1,2
					) AS t1
WHERE rank = 1;
					
-- - ORDER BY 3 DESC ;

-- q8)**Write a SQL query to find the top 5 customers based on the highest total sales **:

SELECT customer_id,SUM(total_sale) AS total_sales
   FROM retail_sales
   GROUP BY 1 -- group the table according to the input
   ORDER BY 2 DESC  -- -DESC helps to show the orders in descending order(higher to lowest) i.e.,  from top sales if we put order by
   LIMIT 5; -- it will limit the table only to the given limit number followed to order by statement


-- q9)Write a SQL query to find the number of unique customers who purchased items from each category.:


SELECT COUNT(DISTINCT customer_id) AS unique_customers,Category
FROM retail_sales
GROUP BY 2;



--q10)Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

WITH hourly_sale --it is a CTE(common table expression)(WITH (give any name) AS( SELECT((CASE   WHEN(_LOGIC_) THEN'CALL'    WHEN(_LOGIC_) THEN'CALL'   ELSE'CALL'  END)))
AS --from line 150 to 159 we are using a logic to create a column called shift for these we are using a logic as
(--(CASE   WHEN(_LOGIC_) THEN'CALL'    WHEN(_LOGIC_) THEN'CALL'   ELSE'CALL'  END) from the question
SELECT
	CASE--from these case we cant do the groupby function so we use CTE to store this shift in and use it to generate a group by)
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN  12 AND 17 THEN 'afternoon'
		WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'evening'
	END AS shift
FROM retail_sales
)
SELECT shift,COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;


--END OF PROJECT1
