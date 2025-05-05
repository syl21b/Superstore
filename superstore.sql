USE SuperstoreDataset;

--Check NULL values
SELECT 
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN Ship_Date IS NULL THEN 1 ELSE NULL END) AS total_ship_date,
    COUNT(CASE WHEN Order_Date IS NULL THEN 1 ELSE NULL END) AS total_order_date,
    COUNT(CASE WHEN Ship_Mode IS NULL THEN 1 ELSE NULL END) AS total_ship_mode,
    COUNT(CASE WHEN Product_ID IS NULL THEN 1 ELSE NULL END) AS total_product_id,
    COUNT(CASE WHEN Category IS NULL THEN 1 ELSE NULL END) AS total_category,
    COUNT(CASE WHEN Sub_Category IS NULL THEN 1 ELSE NULL END) AS total_sub_category,
     COUNT(CASE WHEN Sales IS NULL THEN 1 ELSE NULL END) AS total_sales,
     COUNT(CASE WHEN Quantity IS NULL THEN 1 ELSE NULL END) AS total_quantity,
     COUNT(CASE WHEN Discount IS NULL THEN 1 ELSE NULL END) AS total_discount,
     COUNT(CASE WHEN Profit IS NULL THEN 1 ELSE NULL END) AS total_profit,
     COUNT(CASE WHEN Customer_ID IS NULL THEN 1 ELSE NULL END) AS total_customer_id,
     COUNT(CASE WHEN City IS NULL THEN 1 ELSE NULL END) AS total_city,
     COUNT(CASE WHEN State IS NULL THEN 1 ELSE NULL END) AS total_state,
     COUNT(CASE WHEN Country IS NULL THEN 1 ELSE NULL END) AS total_country,
     COUNT(CASE WHEN Postal_Code IS NULL THEN 1 ELSE NULL END) AS total_postal_code,
     COUNT(CASE WHEN Region IS NULL THEN 1 ELSE NULL END) AS total_region,
     COUNT(CASE WHEN Order_ID IS NULL THEN 1 ELSE NULL END) AS total_order_id,
     COUNT(CASE WHEN Segment IS NULL THEN 1 ELSE NULL END) AS total_segment,
     COUNT(CASE WHEN Product_Name IS NULL THEN 1 ELSE NULL END) AS total_product_name
     FROM dbo.superstore_dataset;

 -- Check for duplicates
 SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Order_ID) AS distinct_order_id,
    COUNT(DISTINCT Customer_ID) AS distinct_customer_id,
    COUNT(DISTINCT Product_ID) AS distinct_product_id
 FROM dbo.superstore_dataset;
-- Check for duplicates in Order_ID
 SELECT 
    Order_ID,
    COUNT(*) AS order_count
 FROM dbo.superstore_dataset
 GROUP BY Order_ID
 HAVING COUNT(*) > 1;
-- Check for duplicates in Customer_ID
 SELECT 
    Customer_ID,
    COUNT(*) AS customer_count
 FROM dbo.superstore_dataset
 GROUP BY Customer_ID
 HAVING COUNT(*) > 1;
-- Check for duplicates in Product_ID
 SELECT 
    Product_ID,
    COUNT(*) AS product_count
 FROM dbo.superstore_dataset
 GROUP BY Product_ID
 HAVING COUNT(*) > 1;
-- Check for duplicates in Order_ID and Customer_ID
 SELECT 
    Order_ID,
    Customer_ID,
    COUNT(*) AS order_customer_count
 FROM dbo.superstore_dataset
 GROUP BY Order_ID, Customer_ID
 HAVING COUNT(*) > 1;
-- Check for duplicates in Order_ID and Product_ID
 SELECT 
    Order_ID,
    Product_ID,
    COUNT(*) AS order_product_count
 FROM dbo.superstore_dataset
 GROUP BY Order_ID, Product_ID
 HAVING COUNT(*) > 1;
-- Check for duplicates in Customer_ID and Product_ID
 SELECT 
    Customer_ID,
    Product_ID,
    COUNT(*) AS customer_product_count
 FROM dbo.superstore_dataset
 GROUP BY Customer_ID, Product_ID
 HAVING COUNT(*) > 1;


 --1) The 3 Sub-category with the highest number of customers
SELECT TOP 5 Sub_Category, COUNT(Customer_ID) AS Counting_Customer
FROM dbo.superstore_dataset
GROUP BY Sub_Category
ORDER BY Counting_Customer DESC;

--2) The Segment with the largest average profit 
     -- Method 1
     SELECT Segment, AVG(Profit) FROM dbo.superstore_dataset
     GROUP BY Segment
     ORDER BY AVG(Profit) DESC
     OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;
     -- Method 2
     SELECT TOP 1 Segment, AVG(Profit) AS Avg_Profit
     FROM dbo.superstore_dataset
     GROUP BY Segment
     ORDER BY Avg_Profit DESC;
     -- Method 3
     WITH seg_avg AS (
          SELECT Segment, AVG(Profit) AS Average_profit_by_segment FROM dbo.superstore_dataset
          GROUP BY Segment 
     ) 
     SELECT Segment, Average_profit_by_segment FROM seg_avg
     WHERE Average_profit_by_segment = (SELECT MAX( Average_profit_by_segment) FROM seg_avg)

--3) 


/*
📊 Sales & Profit Analysis
	1.	What is the total profit and sales per category and sub-category?
	2.	Which product has generated the highest total profit?
	3.	Which sub-category has the lowest average profit per order?
	4.	What is the profit margin (Profit/Sales) for each product, ordered by highest?
	5.	Which customer has placed the most orders and what’s their total profit contribution?
*/
     --1.
                    SELECT Category, Sub_Category, SUM(Sales) AS Total_sales, SUM(Profit) AS Total_profit
                    FROM dbo.superstore_dataset
                    GROUP BY Category, Sub_Category
     
     --2.
                    --Method 1: Create a function
                    WITH Product_with_highest_profit AS(
                         SELECT Product_ID, Product_Name,  SUM(Profit) AS Total_profit
                         FROM dbo.superstore_dataset
                         GROUP BY Product_ID, Product_Name
                    )
                    SELECT Product_ID, Product_Name,  Total_profit
                    FROM Product_with_highest_profit
                    WHERE Total_profit = (SELECT MAX(Total_profit) FROM Product_with_highest_profit)
                    --Method 2: Sub-query
                    SELECT Product_ID, Product_Name, Total_profit
                    FROM (
                         SELECT Product_ID, Product_Name, SUM(Profit) AS Total_profit
                         FROM dbo.superstore_dataset
                         GROUP BY Product_ID, Product_Name
                    ) AS sub
                         WHERE Total_profit = (
                         SELECT MAX(Total_profit)
                         FROM (
                              SELECT SUM(Profit) AS Total_profit
                              FROM dbo.superstore_dataset
                              GROUP BY Product_ID, Product_Name
                         ) AS inner_sub
                    );
                    --Method 3: TOP
                    SELECT TOP 1 Product_ID, Product_Name,  SUM(Profit) AS Total_profit
                    FROM dbo.superstore_dataset
                    GROUP BY Product_ID, Product_Name
                    ORDER BY Total_profit DESC

     --3. 
                    SELECT TOP 1 Sub_Category,  AVG(Profit) AS Total_profit
                    FROM dbo.superstore_dataset
                    GROUP BY Sub_Category
                    ORDER BY Total_profit ASC
     --4.
                    --This must be the best METHOD to find all the category with highest value of sales or profit
                    WITH highest_marging AS (
                         SELECT Product_ID, Product_Name,  SUM(Profit)/NULLIF(SUM(Sales),0) AS profit_margin
                         FROM dbo.superstore_dataset AS st
                         GROUP BY Product_ID, Product_Name           
                    )
                    SELECT Product_ID, Product_Name,  profit_margin
                    FROM highest_marging 
                    WHERE profit_margin = (SELECT MAX(profit_margin) FROM highest_marging)
     
     --5.
                         SELECT Customer_ID, Customer_Name, COUNT(Order_ID) AS number_order, SUM(Profit) AS Total_contributed_profit
                         FROM dbo.superstore_dataset
                         GROUP BY Customer_ID, Customer_Name
                         HAVING COUNT(Order_ID) = (
                                                                                     SELECT MAX(OrderCount)
                                                                                     FROM (
                                                                                          SELECT COUNT(Order_ID) AS OrderCount
                                                                                          FROM dbo.superstore_dataset
                                                                                          GROUP BY Customer_ID
                                                                                     ) AS sub
                                                                                )


---------------------------------------------------------------------------------------------------------------------
/*
⏱️ Time Series & Date Operations
	6.	How does monthly total sales trend over time?
	7.	What is the average shipping delay (days between Order_Date and Ship_Date) per region?
	8.	Which month and year had the highest total sales?
	9.	How many orders were shipped late (i.e., Ship_Date > Order_Date + 2 days)?
	10.	What is the average profit per order over the years?
*/
          --6. 
               SELECT DISTINCT(YEAR(Order_Date)) FROM dbo.superstore_dataset
               --Method 1
               SELECT YEAR(Order_Date) AS Order_year, MONTH(Order_Date) AS Order_month, SUM(Sales) AS Total_sale FROM dbo.superstore_dataset
               GROUP BY YEAR(Order_Date), MONTH(Order_Date)
               ORDER BY Order_year DESC, Order_month
               --Method 2
               SELECT 
               FORMAT(Order_Date, 'yyyy-MM') AS Year_Month,
               SUM(Sales) AS Total_Sales
               FROM dbo.superstore_dataset
               GROUP BY FORMAT(Order_Date, 'yyyy-MM')
               ORDER BY Year_Month;
          
          --7. 
               SELECT Region, AVG(DATEDIFF(DAY,Order_Date, Ship_Date)) AS Average_delay_days FROM dbo.superstore_dataset
               GROUP BY Region

          --8. 
               --Method1: Subquery in Subquery
               SELECT Year_month, Total_Sales FROM (
                    SELECT FORMAT(Order_Date, 'yyyy-MM') AS Year_Month, SUM(Sales) AS Total_Sales
                    FROM dbo.superstore_dataset
                    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
               ) AS sub
               WHERE Total_Sales = (SELECT MAX(Total_Sales) FROM 
                                                                                                         (
                                                                                                         SELECT FORMAT(Order_Date, 'yyyy-MM') AS Year_Month, SUM(Sales) AS Total_Sales
                                                                                                         FROM dbo.superstore_dataset
                                                                                                         GROUP BY FORMAT(Order_Date, 'yyyy-MM')
                                                                                                         )AS inner_sub
               )
               --Method2: Create a function
               WITH Highest_sales AS(
                    SELECT FORMAT(Order_Date, 'yyyy-MM') AS Year_Month, SUM(Sales) AS Total_Sales
                    FROM dbo.superstore_dataset
                    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
               )
               SELECT Year_Month, Total_Sales
               FROM Highest_sales
               WHERE Total_Sales = (SELECT MAX(Total_Sales) FROM Highest_sales)
     
     --9.

          SELECT COUNT(*) AS Number_of_shipped_late_orders FROM (
               SELECT Order_Date, Ship_Date, DATEDIFF(DAY,Order_Date,Ship_Date) AS Delay_days
               FROM dbo.superstore_dataset
               WHERE Ship_Date > DATEADD(DAY , 2, Order_Date ) 
          ) AS sub
     
     --10.   
          SELECT Year_Order,  AVG(Total_profit) AS Average_profit FROM( 
               SELECT YEAR(Order_Date) AS Year_Order, Order_ID, SUM(Profit)AS Total_profit FROM dbo.superstore_dataset
               GROUP BY YEAR(Order_Date), Order_ID
          ) AS sub
          GROUP BY Year_Order
          ORDER BY Year_Order;

---------------------------------------------------------------------------------------------------------------------
/*
📍 Geographic Analysis
	11.	Which state has the highest total discount given?
	12.	Which city generated the most sales per capita (average per order)?
	13.	Which region has the highest number of orders and total profit?
*/
     --11. 
          --Method 1: Subquery
          SELECT State, Total_Discount FROM(
               SELECT State, SUM(Discount) AS Total_Discount FROM dbo.superstore_dataset
               GROUP BY State
          )AS sub
          WHERE Total_Discount = (SELECT MAX(Total_Discount) FROM 
                                                                                     (SELECT State, SUM(Discount) AS Total_Discount FROM dbo.superstore_dataset
                                                                                     GROUP BY State) AS innersub
                                                       )
          --Method 2: 
          WITH highest_discount_State AS (
               SELECT State, SUM(Discount) AS Total_Discount FROM dbo.superstore_dataset
               GROUP BY State
          )
          SELECT [State], Total_Discount FROM highest_discount_State
          WHERE Total_Discount = (SELECT MAX(Total_Discount) FROM highest_discount_State)

--12
               --Misundersatng ""Sale per capita"
               SELECT City, sales_per_capita FROM (
                    SELECT  Order_ID, City, AVG(Sales) AS sales_per_capita  FROM dbo.superstore_dataset
                    GROUP BY City, Order_ID
               )AS t1
               WHERE sales_per_capita= (SELECT MAX(sales_per_capita) FROM
                                                                                          (SELECT  Order_ID, City, AVG(Sales) AS sales_per_capita  FROM dbo.superstore_dataset
                                                                                          GROUP BY City, Order_ID) AS t2)
               --Correct answer
               SELECT TOP 1 City, AVG(Order_Sales) AS Avg_Sales_Per_Order
               FROM (
               SELECT City, Order_ID, SUM(Sales) AS Order_Sales
               FROM dbo.superstore_dataset
               GROUP BY City, Order_ID
               ) AS sub
               GROUP BY City
               ORDER BY Avg_Sales_Per_Order DESC;
               --Correct answer
               SELECT TOP 1 
               City, 
               AVG(Sales) AS Avg_Sales_Per_Order
               FROM dbo.superstore_dataset
               GROUP BY City
               ORDER BY Avg_Sales_Per_Order DESC;
--13.
--Method 1: Subquery
SELECT Region, Number_of_Orders, Total_Profit
FROM (
    SELECT 
        Region, 
        COUNT(DISTINCT Order_ID) AS Number_of_Orders,
        SUM(Profit) AS Total_Profit
    FROM dbo.superstore_dataset
    GROUP BY Region
) AS sub
WHERE Number_of_Orders = (
    SELECT MAX(OrderCount)
    FROM (
        SELECT COUNT(DISTINCT Order_ID) AS OrderCount
        FROM dbo.superstore_dataset
        GROUP BY Region
    ) AS count_sub
);

--Method 2: Using DESC and TOP 1
SELECT TOP 1
    Region, 
    COUNT(DISTINCT Order_ID) AS Number_of_Orders,
    SUM(Profit) AS Total_Profit
FROM dbo.superstore_dataset
GROUP BY Region
ORDER BY Number_of_Orders DESC, Total_Profit DESC;

---------------------------------------------------------------------------------------------------------------------
/*
👥 Customer & Segment Insights
	14.	What is the average sales and profit per segment?
	15.	How many unique customers placed orders in each segment?
	16.	Who are the top 5 most profitable customers by total profit?
*/
--14.
SELECT Segment, AVG(Sales) AS average_sales, AVG(Profit) AS average_profit
FROM dbo.superstore_dataset
GROUP BY Segment

--15. 
SELECT Segment, COUNT(DISTINCT Customer_ID) AS number_unique_customer
FROM dbo.superstore_dataset
GROUP BY Segment

--16.
--Method 1: Suing TOP 5
SELECT  TOP 5 Customer_ID, Customer_Name, SUM(Profit) AS Total_Profit
FROM dbo.superstore_dataset
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Profit DESC 
--Method 2: Using OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; in SQL Server
SELECT 
    Customer_ID, 
    Customer_Name, 
    SUM(Profit) AS Total_Profit
FROM dbo.superstore_dataset
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Profit DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
---------------------------------------------------------------------------------------------------------------------
/*
📦 Product-Level Exploration
	17.	Which products are sold the most by quantity, and what’s their total sales?
	18.	What’s the average discount by sub-category and its impact on average profit?
	19.	Are there any products that were sold at a loss (negative profit)? List them.
	20.	What are the top 10 best-selling products based on quantity sold?
*/
--17.
--Method1: Subquery
SELECT Product_ID, Product_Name, Total_Quantity, Total_Sales FROM(
          SELECT Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity, SUM(Sales) AS Total_Sales
          FROM dbo.superstore_dataset
          GROUP BY Product_ID, Product_Name
) AS sub1
WHERE Total_Quantity = (SELECT MAX(Total_Quantity) 
                                             FROM (SELECT Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity, SUM(Sales) AS Total_Sales
                                                            FROM dbo.superstore_dataset
                                                            GROUP BY Product_ID, Product_Name) 
                                             AS sub2)
--Method 2: Apply TOP 1
SELECT TOP 1 Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity, SUM(Sales) AS Total_Sales
FROM dbo.superstore_dataset
GROUP BY Product_ID, Product_Name
ORDER BY Total_Quantity DESC

--18.
SELECT Sub_Category, AVG(Discount) AS Total_Discount, AVG(Profit) AS Total_Profit
FROM dbo.superstore_dataset
GROUP BY Sub_Category
ORDER BY Total_Discount DESC

--19.
SELECT Product_ID, Product_Name, SUM(Profit) AS Total_Profit
FROM dbo.superstore_dataset
GROUP BY Product_ID, Product_Name
HAVING SUM(Profit) < 0

--20.
SELECT TOP 10 Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity, SUM(Sales) AS Total_Sales
FROM dbo.superstore_dataset
GROUP BY Product_ID, Product_Name
ORDER BY Total_Quantity DESC

SELECT Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity, SUM(Sales) AS Total_Sales
FROM dbo.superstore_dataset
GROUP BY Product_ID, Product_Name
ORDER BY Total_Quantity DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

/*************************************************************************************************
🔄 Window Functions / Ranking
	21.	For each sub-category, rank the products by total sales. Then return the top-selling product per sub-category.
	22.	Calculate the running total of sales by month and segment.
	23.	For each customer, find their first and last purchase date, and calculate the total number of days they were active.
	24.	Identify products where the profit consistently decreased over time (yearly), using a window function to compare year-over-year profit.
*************************************************************************************/
--21.
SELECT Product_ID, Sub_Category, Total_Sales, Rank_by_Sale FROM(
     --Rank Product by Sales in sub-category
     SELECT Product_ID,Sub_Category,  SUM(Sales) AS Total_Sales, 
                    RANK() OVER ( PARTITION BY Sub_Category ORDER BY SUM(Sales) DESC) AS Rank_by_Sale
     FROM dbo.superstore_dataset
     GROUP BY Product_ID,  Sub_Category
) AS sub1
WHERE sub1.Rank_by_Sale =1

--22. 
          --RUNNING TOTAL
          SELECT Segment, FORMAT(Order_Date, 'yyyy-MM'), Sales,
               SUM (Sales) OVER ( ORDER BY FORMAT(Order_Date, 'yyyy-MM')
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) SaleRunningTotal
          FROM dbo.superstore_dataset

          --ROLLING TOTAL. 
          --If you want a date-based rolling window (e.g. last 30 days), you’ll need a self-join or use range-based logic, 
          --which SQL Server doesn’t support directly with RANGE on datetime.
           SELECT Segment, FORMAT(Order_Date, 'yyyy-MM'), Sales,
               SUM (Sales) OVER ( ORDER BY FORMAT(Order_Date, 'yyyy-MM')
               ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) SaleRunningTotal
          FROM dbo.superstore_dataset

--23.
          SELECT Customer_ID, MIN(Order_Date) AS first_purchase, MAX(Order_Date) AS last_purchase,
                         DATEDIFF(DAY, MIN(Order_Date), MAX(Order_Date)) AS Total_active_day
          FROM dbo.superstore_dataset
          GROUP BY Customer_ID
          ORDER BY Total_active_day DESC

--24. 
--Method 1: Subquery
SELECT *
FROM (
    SELECT 
        Product_ID,  YEAR(Order_Date) AS Order_Year, SUM(Profit) AS Yearly_Profit,
        LAG(SUM(Profit)) OVER (PARTITION BY Product_ID ORDER BY YEAR(Order_Date)) AS Previous_Year_Profit
    FROM dbo.superstore_dataset
    GROUP BY Product_ID, YEAR(Order_Date)
) AS t
WHERE Yearly_Profit < Previous_Year_Profit;

--Method 2: CTE
WITH yearly_profit AS (
    SELECT Product_ID, YEAR(Order_Date) AS Order_Year, SUM(Profit) AS Yearly_Profit
    FROM dbo.superstore_dataset
    GROUP BY Product_ID, YEAR(Order_Date)
),
profit_with_lag AS (
    SELECT Product_ID, Order_Year, Yearly_Profit,
        LAG(Yearly_Profit) OVER ( PARTITION BY Product_ID ORDER BY Order_Year ) AS Previous_Year_Profit
    FROM yearly_profit
)
SELECT *
FROM profit_with_lag
WHERE Yearly_Profit < Previous_Year_Profit;
/*************************************************************************************
📈 Complex Analysis / Correlated Subqueries
	25.	For each order, calculate the percentage contribution of each product’s sales to the total order sales.
	26.	List customers whose average profit per order is higher than the overall average profit per order.
	27.	Identify the sub-category that has the highest profit variance (standard deviation of profit).
*************************************************************************************/
--25. 
SELECT  Order_ID,  Product_ID, Sales,  
    SUM(Sales) OVER (PARTITION BY Order_ID) AS Total_Sale,
    ROUND(Sales * 100.0 / SUM(Sales) OVER (PARTITION BY Order_ID),2) AS percentage_product
FROM dbo.superstore_dataset;

--26.
SELECT Customer_ID,  AVG(OrderProfit) AS AvgProfitPerOrder
FROM (
               SELECT Customer_ID, Order_ID, SUM(Profit) AS OrderProfit
               FROM dbo.superstore_dataset
               GROUP BY Customer_ID, Order_ID
          ) AS sub
GROUP BY Customer_ID
HAVING AVG(OrderProfit) > ( SELECT AVG(OrderProfit)  FROM (
                                                                                                                   SELECT Order_ID, SUM(Profit) AS OrderProfit
                                                                                                                   FROM dbo.superstore_dataset
                                                                                                                   GROUP BY Order_ID
                                                                                                              ) AS overall
                                                  )
ORDER BY AvgProfitPerOrder DESC
--27.
SELECT  TOP 1 Sub_Category, STDEV(Profit) AS Profit_SD
FROM dbo.superstore_dataset
GROUP BY Sub_Category
ORDER BY Profit_SD DESC
/*************************************************************************************
🔍 CTEs / Recursive / Joins
	28.	Using a recursive CTE, simulate month-by-month cumulative sales growth for a given year.
	29.	Join the Customer_ID with itself to find customer pairs that ordered the same product in the same city but on different dates.

*************************************************************************************/
--28. 
WITH MonthlySales AS (
    SELECT  FORMAT(Order_Date, 'yyyy-MM') AS Year_Month, SUM(Sales) AS Sales
    FROM dbo.superstore_dataset
    WHERE YEAR(Order_Date) = 2014
    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
),
OrderedMonths AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY Year_Month) AS rn
    FROM MonthlySales
),
RecursiveSales AS (
    -- Anchor: first month
    SELECT  Year_Month, Sales AS Monthly_Sales, Sales AS Cumulative_Sales,  rn
    FROM OrderedMonths
    WHERE rn = 1

    UNION ALL

    -- Recursive: next month adds to prior cumulative
    SELECT 
        om.Year_Month, om.Sales AS Monthly_Sales, rs.Cumulative_Sales + om.Sales AS Cumulative_Sales, om.rn
    FROM OrderedMonths om
    JOIN RecursiveSales rs ON om.rn = rs.rn + 1
)
SELECT *
FROM RecursiveSales
ORDER BY rn;

--29.
SELECT  st1.Customer_ID AS Customer1,st2.Customer_ID AS Customer2, st1.Product_ID, st1.City, st1.Order_Date AS OrderDate1, st2.Order_Date AS OrderDate2
FROM dbo.superstore_dataset AS st1
JOIN dbo.superstore_dataset AS st2
ON st1.Product_ID = st2.Product_ID AND st1.City = st2.City AND st1.Order_Date !=st2.Order_Date AND st1.Customer_ID != st2.Customer_ID

/*************************************************************************************
🧠 Advanced Insight & Optimization
	30.	Which product has the highest average profit per unit sold, but only among products that were sold in more than 10 different cities and had a discount applied at least once?
*************************************************************************************/
--Method 1: Subquery
SELECT TOP 1 Product_ID, Product_Name, 
          COUNT(DISTINCT City) AS number_of_city ,         
          SUM(CASE WHEN Discount > 0 THEN 1 ELSE 0 END) AS Discount_Count,
          SUM(Profit) /SUM(Quantity) AS Average_profit FROM(
                                   SELECT  Product_ID, Product_Name, City ,Discount, Profit, Quantity
                                   FROM dbo.superstore_dataset
                                   --WHERE Discount > 0 --a discount applied at least once
) AS sub1
GROUP BY Product_ID, Product_Name
HAVING COUNT(DISTINCT City) >10
ORDER BY Average_profit DESC

--To check the result
SELECT  Product_ID, Product_Name, City ,Discount, Profit, Quantity
FROM dbo.superstore_dataset
WHERE  Product_ID = 'FUR-CH-10004287' 

--Method 2: CTE
WITH ProductStats AS (
    SELECT  Product_ID, Product_Name,
        COUNT(DISTINCT City) AS City_Count,
        SUM(CASE WHEN Discount > 0 THEN 1 ELSE 0 END) AS Discount_Count,
        SUM(Profit) * 1.0 / SUM(Quantity) AS Avg_Profit_Per_Unit
    FROM  dbo.superstore_dataset
    GROUP BY  Product_ID, Product_Name
)
SELECT  Product_ID, Product_Name, City_Count, Discount_Count, Avg_Profit_Per_Unit
FROM   ProductStats
WHERE  City_Count > 10 AND Discount_Count > 0
ORDER BY  Avg_Profit_Per_Unit DESC;

/*************************************************************************************
🔮 Deep Analytics / Multi-layered Logic
	31.	For each category, identify the product that had the highest number of returns (assume negative profit = return/loss). 
          Then calculate the percentage that product contributed to total category losses.
	32.	Create a cohort analysis by grouping customers based on their first purchase year and then track their total profit contribution over the next 3 years.
	33.	Detect patterns where a customer made multiple purchases of the same product in the same month — return only those repeating product purchases and their profit impact.
**************************************************************************************/
--31. 
          SELECT * FROM (
               SELECT Category, Product_ID, Product_Name,  Total_Profit AS highest_loss, 
                              RANK() OVER(PARTITION BY Category ORDER BY Total_Profit ASC) AS Rank_Profit FROM (
                    SELECT Category, Product_ID,Product_Name, SUM(Profit) AS Total_Profit
                    FROM dbo.superstore_dataset
                    GROUP BY Category, Product_ID, Product_Name
               )AS s1
          ) AS o1
          WHERE Rank_Profit =1
          -----------------------------Correct Answer---------------------------------------------------------------------------
          WITH CTE1 AS(
          SELECT Category, Product_ID, Product_Name,  Profit, Negative_loss FROM (
                    SELECT Category, Product_ID,Product_Name, Profit, 
                                   CASE WHEN Profit < 0 THEN 0 ELSE 1 END Negative_loss
                    FROM dbo.superstore_dataset
               )AS s1
               WHERE Negative_loss = 0 
          )
          , CTE2 AS(
               SELECT Category, Product_ID, Product_Name,  SUM(Profit) AS Total_Loss_by_Product FROM CTE1
               GROUP BY Category, Product_ID, Product_Name
          )
          ,CTE3 AS (
               SELECT Category, SUM(Total_Loss_by_Product) AS Total_Loss_by_Category FROM CTE2
               GROUP BY Category
          )

          SELECT Category, Product_ID, Product_Name,  Total_Loss_by_Product, Total_Loss_by_Category, ROUND(Percent_Loss, 2) AS Percent_Loss FROM(
                    SELECT c2.Category, c2.Product_ID, c2.Product_Name, c2. Total_Loss_by_Product, c3.Total_Loss_by_Category , 
                                   c2. Total_Loss_by_Product *100.0/ c3.Total_Loss_by_Category AS Percent_Loss,
                                   RANK() OVER(PARTITION BY c2.Category ORDER BY c2. Total_Loss_by_Product) AS Ranking
                    FROM CTE3 AS c3
                    JOIN CTE2 as c2 ON c2.Category = c3.Category
          )AS t1
          WHERE Ranking = 1
          
--32
--Method 1: CTEs
WITH CTE1 AS(
     SELECT Customer_ID, Customer_Name, MIN(Order_Year)AS First_Order_Year, MIN(Order_Year) + 3 AS Next_3_year  FROM(
          SELECT Customer_ID, Customer_Name, YEAR(Order_Date) AS Order_Year
          FROM dbo.superstore_dataset AS s1
     ) AS t1
     GROUP BY Customer_ID, Customer_Name
)
, CTE2 AS(
     SELECT  First_Order_Year, YEAR(st1.Order_date) AS Order_Year, COUNT(DISTINCT st1.Customer_ID) AS Number_Customer, SUM(st1.Profit) AS Profit_Within_3_Years
     FROM dbo.superstore_dataset AS st1
     JOIN CTE1 ON st1.Customer_ID = CTE1.Customer_ID 
     WHERE  YEAR(Order_Date) < CTE1.Next_3_year AND YEAR(Order_Date) >=First_Order_Year
     GROUP BY First_Order_Year, YEAR(st1.Order_date)

)
SELECT * FROM CTE2
ORDER BY First_Order_Year, Order_Year
--Method 2: Subquery
SELECT 
    cohort_year,
    order_year,
    COUNT(DISTINCT Customer_ID) AS Customers_Active,
    SUM(Profit) AS Total_Profit
FROM (
    SELECT 
        Customer_ID,
        YEAR(Order_Date) AS order_year,
        -- Find the cohort year: first year a customer made a purchase
        (SELECT MIN(YEAR(Order_Date)) 
         FROM dbo.superstore_dataset AS inner_data 
         WHERE inner_data.Customer_ID = outer_data.Customer_ID) AS cohort_year,
        Profit
    FROM dbo.superstore_dataset AS outer_data
) AS cohort_data
WHERE order_year BETWEEN cohort_year AND cohort_year + 2
GROUP BY cohort_year, order_year
ORDER BY cohort_year, order_year;


------------------------------------------------------------------------------------------------------
--33
WITH cte1 AS (
     SELECT s1.Customer_ID, s1.Product_ID, FORMAT(s1.Order_Date, 'yyyy-MM') AS order_month_year, COUNT(Product_ID) AS purchase_count, SUM(Profit) AS monthly_profit
     FROM dbo.superstore_dataset AS s1
     GROUP BY Customer_ID, Product_ID, FORMAT(s1.Order_Date, 'yyyy-MM')
) 
SELECT * FROM cte1
WHERE purchase_count > 1
ORDER BY purchase_count DESC, monthly_profit DESC;


/*************************************************************************************

🧠 Dense Calculations with Subqueries / CTEs
	34.	Find the top 3 most profitable products within each region for the last full year of data.
	35.	Identify all products whose sales have increased every single quarter over time (monotonically increasing sales trend).
	36.	Determine which customer had the biggest percentage drop in profit between two consecutive years.
**************************************************************************************/
--34.
          --Method 1: Subquery
          SELECT * FROM (
               SELECT Region, Product_ID, MAX(Total_Profit ) AS Profit_Region, 
                         RANK() OVER (PARTITION BY Region ORDER BY MAX(Total_Profit ) DESC) AS rk 
               FROM (
                              SELECT  Region, Product_ID,  SUM(Profit) AS Total_Profit
                              FROM dbo.superstore_dataset
                              WHERE YEAR(Order_Date) = (SELECT MAX(YEAR(Order_Date) ) FROM dbo.superstore_dataset)
                              GROUP BY Region, Product_ID
                         ) AS inner1 
               GROUP BY Region, Product_ID
          ) AS outer1
          WHERE rk IN (1,2,3)

          --Method 2: CTEs
          WITH last_year_cte AS (
          SELECT MAX(YEAR(Order_Date)) AS last_year
          FROM dbo.superstore_dataset
          ),
          profit_by_region_product AS (
          SELECT 
               Region,
               Product_ID,
               SUM(Profit) AS total_profit
          FROM dbo.superstore_dataset
          WHERE YEAR(Order_Date) = (SELECT last_year FROM last_year_cte)
          GROUP BY Region, Product_ID
          ),
          ranked_products AS (
          SELECT *,
                    RANK() OVER (PARTITION BY Region ORDER BY total_profit DESC) AS rk
          FROM profit_by_region_product
          )
          SELECT Region, Product_ID, total_profit
          FROM ranked_products
          WHERE rk <= 3
          ORDER BY Region, rk;

--35.
          WITH Quarter_data AS(
               SELECT  Product_ID,  YEAR(Order_Date) AS Order_year, 
                              DATEPART(QUARTER, Order_Date) AS Order_Quarter,
                              SUM(Sales) AS Total_Sales_by_Quarter
               FROM dbo.superstore_dataset
               GROUP BY Product_ID, YEAR(Order_Date), DATEPART(QUARTER, Order_Date)
          )
          , Count_Quarter_in_Year AS(
               SELECT Product_ID,  Order_year, COUNT(Order_Quarter) AS countQuarter  FROM Quarter_data
               GROUP BY Product_ID,  Order_year
               HAVING COUNT(Order_Quarter)  = 4
          )
          , Previous_Quarter_profit AS (
               SELECT cd.Product_ID,  cd.Order_year , qd.Order_Quarter, qd.Total_Sales_by_Quarter, 
                    CASE WHEN qd.Order_Quarter = 1 THEN NULL
                              ELSE LAG(qd.Total_Sales_by_Quarter,1) OVER(ORDER BY cd.Order_year  DESC )
                    END previous_sale
               FROM Count_Quarter_in_Year AS cd
               JOIN Quarter_data AS qd ON cd.Product_ID = qd.Product_ID AND cd.Order_year = qd.Order_year 
          ) --SELECT * FROM Previous_Quarter_profit
          , satisfy_cond AS (
               SELECT Product_ID,  Order_year ,Order_Quarter, Total_Sales_by_Quarter, previous_sale,
                              CASE WHEN Total_Sales_by_Quarter >  previous_sale THEN 1 ELSE 0 END satisfy_condition
               FROM Previous_Quarter_profit
               WHERE previous_sale IS NOT NULL
          ) --SELECT * FROM satisfy_cond
          SELECT Product_ID,  Order_year, SUM(satisfy_condition) AS count_SC FROM satisfy_cond
          GROUP BY Product_ID,  Order_year 
          HAVING SUM(satisfy_condition) = 3


          WITH sales_by_quarter AS (
          SELECT
               Product_ID,
               DATEPART(YEAR, Order_Date) AS sales_year,
               DATEPART(QUARTER, Order_Date) AS sales_quarter,
               SUM(Sales) AS total_sales
          FROM dbo.superstore_dataset
          GROUP BY Product_ID, DATEPART(YEAR, Order_Date), DATEPART(QUARTER, Order_Date)
          ),
          ranked_sales AS (
          SELECT *,
                    ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY sales_year, sales_quarter) AS rn
          FROM sales_by_quarter
          ) 
          , compare_sales AS (
          SELECT 
               curr.Product_ID,
               curr.rn,
               curr.total_sales AS current_sales,
               prev.total_sales AS prev_sales
          FROM ranked_sales curr
          LEFT JOIN ranked_sales prev
               ON curr.Product_ID = prev.Product_ID
               AND curr.rn = prev.rn + 1
          ) --SELECT * FROM compare_sales
          , violations AS (
          SELECT Product_ID
          FROM compare_sales
          WHERE prev_sales IS NOT NULL AND current_sales <= prev_sales
          )
          SELECT DISTINCT Product_ID
          FROM ranked_sales
          WHERE Product_ID NOT IN (SELECT Product_ID FROM violations);

--36
--My Answer--------
               WITH Customer_Info AS(
                    SELECT Customer_ID, YEAR(Order_Date)  AS Order_year , 
                    LAG(YEAR(Order_Date)  ) OVER (PARTITION BY Customer_ID ORDER BY YEAR(Order_Date)  ASC)  AS Previous_year, 
                    YEAR(Order_Date)  -  LAG(YEAR(Order_Date)  ) OVER (PARTITION BY Customer_ID ORDER BY YEAR(Order_Date)  ASC) AS gap_years,
                    SUM(Profit) AS Total_Profit
                    --ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY YEAR(Order_Date)  ASC) AS rn
                    FROM dbo.superstore_dataset
                    GROUP BY Customer_ID, YEAR(Order_Date)
               )
               , Drop_Check AS (
                    SELECT  Customer_ID, Order_year , Previous_year, gap_years,
                                        --rn, 
                                        Total_Profit,
                                        LAG(Total_Profit ) OVER (PARTITION BY Customer_ID ORDER BY Order_year ASC) AS Previous_Profit,
                                        LAG(Total_Profit ) OVER (PARTITION BY Customer_ID ORDER BY Order_year ASC) - Total_Profit  AS Drop_profit,
                                        ROUND(ABS((LAG(Total_Profit ) OVER (PARTITION BY Customer_ID ORDER BY Order_year ASC) - Total_Profit) )* 100
                                        / ABS((LAG(Total_Profit ) OVER (PARTITION BY Customer_ID ORDER BY Order_year ASC)  ) ), 2) AS Percentage_Drop ,
                                        CASE WHEN LAG(Total_Profit ) OVER (PARTITION BY Customer_ID ORDER BY Order_year ASC) > Total_Profit THEN 'Drop'
                                                  ELSE 'Not'
                                        END DROP_or_NOT
                    FROM Customer_Info 
               )
               SELECT TOP 1 * FROM Drop_Check
               WHERE DROP_or_NOT='Drop' AND gap_years = 1
               ORDER BY Percentage_Drop DESC

--Chat GPT answer---------------------
          WITH Profit_Per_Year AS (
               SELECT  Customer_ID, DATEPART(YEAR, Order_Date) AS Order_Year,  SUM(Profit) AS Yearly_Profit
               FROM dbo.superstore_dataset
               GROUP BY Customer_ID, DATEPART(YEAR, Order_Date)
          ),
          Profit_With_Change AS (
               SELECT  Customer_ID, Order_Year, Yearly_Profit,
                    LAG(Yearly_Profit) OVER (PARTITION BY Customer_ID ORDER BY Order_Year) AS Prev_Year_Profit
               FROM Profit_Per_Year
          ) 
          , Percentage_Drop AS (
               SELECT Customer_ID, Order_Year, Yearly_Profit, Prev_Year_Profit,
                    CASE 
                         WHEN Prev_Year_Profit IS NOT NULL AND Prev_Year_Profit > 0 THEN
                              ((Prev_Year_Profit - Yearly_Profit) * 1.0 / Prev_Year_Profit) * 100
                         ELSE NULL
                    END AS Profit_Drop_Percentage
               FROM Profit_With_Change
          )
          SELECT  TOP 1 * FROM Percentage_Drop
          WHERE Profit_Drop_Percentage IS NOT NULL
          ORDER BY Profit_Drop_Percentage DESC;

/*************************************************************************************
🔁 Recursive Logic & Hierarchical Joins
	37.	Assuming each order can lead to another (based on a Customer_ID placing another order within 7 days), build a recursive chain to calculate the longest sequence of dependent orders per customer.
**************************************************************************************/
WITH Ordered_CTE AS (
    SELECT  Customer_ID, Order_ID,  Order_Date,
        LAG(Order_Date) OVER(PARTITION BY Customer_ID ORDER BY Order_Date) AS Prev_Order_Date
    FROM dbo.superstore_dataset
    GROUP BY Customer_ID, Order_ID,  Order_Date
),
Chain_Breaks AS (
    SELECT *,
        CASE 
            WHEN Prev_Order_Date IS NULL THEN 1
            WHEN DATEDIFF(DAY, Prev_Order_Date, Order_Date) > 7 THEN 1
            ELSE 0
        END AS Is_New_Chain
    FROM Ordered_CTE
),
Chain_Assignments AS (
    SELECT *,
        SUM(Is_New_Chain) OVER(PARTITION BY Customer_ID ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Chain_ID
    FROM Chain_Breaks
)
SELECT  Customer_ID, Chain_ID, COUNT(*) AS Chain_Length
FROM Chain_Assignments
GROUP BY Customer_ID, Chain_ID
ORDER BY Chain_Length DESC;

--------------------------------------------------------

------------Correct Answer-------------------------
WITH Ordered_CTE AS (
    SELECT Customer_ID, Order_ID, Order_Date
    FROM dbo.superstore_dataset
),
RecursiveChain AS (
    -- Base case: Start each chain from one order
    SELECT  o.Customer_ID,  o.Order_ID AS Start_Order_ID,  o.Order_Date AS Start_Date, o.Order_ID AS Current_Order_ID,   o.Order_Date AS CurrentOrderDate,
        1 AS Chain_Length
    FROM Ordered_CTE o

    UNION ALL

    -- Recursive case: find next order within 7 days
    SELECT   rc.Customer_ID,   rc.Start_Order_ID,   rc.Start_Date,  o.Order_ID AS Current_Order_ID,  o.Order_Date AS CurrentOrderDate, 
        rc.Chain_Length + 1
    FROM RecursiveChain rc
    JOIN Ordered_CTE o
      ON rc.Customer_ID = o.Customer_ID
     AND o.Order_Date > rc.CurrentOrderDate
     AND DATEDIFF(DAY, rc.CurrentOrderDate, o.Order_Date) <= 7
) 
-- Final step: get the max chain length per customer
SELECT  Customer_ID,  MAX(Chain_Length) AS Longest_Order_Chain
FROM RecursiveChain
GROUP BY Customer_ID
ORDER BY Longest_Order_Chain DESC;


/*************************************************************************************
📌 Outlier Detection / Statistical Analysis
	38.	Calculate the z-score of profit for each product, then return products with z-scores > 2 or < -2 (significant outliers in profitability).
**************************************************************************************/
--38.
WITH Observation_Profit AS (
     SELECT Product_ID, SUM(Profit) AS Total_profit
     FROM dbo.superstore_dataset
     GROUP BY Product_ID
)
, stat_calculation AS(
     SELECT AVG(Total_profit) AS mean_profit, STDEV(Total_profit) As standard_deviation
     FROM Observation_Profit
)
, Z_score AS (
     SELECT o.Product_ID,
                    (Total_profit - s.mean_profit  )/ s.standard_deviation  AS z_score_profit
     FROM Observation_Profit AS o
     CROSS JOIN stat_calculation as s
)
SELECT * FROM Z_score
WHERE z_score_profit > 2 OR z_score_profit < -2
ORDER BY z_score_profit DESC

/*************************************************************************************
🔀 Cross Analysis / Correlations
	39.	Correlate discount with profit by sub-category using a windowed correlation formula. Which sub-category shows the strongest negative correlation?
	40.	Create a product affinity table showing which products are frequently purchased together (same Order_ID), and count how often each pair occurs.
**************************************************************************************/
--39. 
WITH define_variables AS (
     SELECT Sub_Category, Discount AS X, Profit AS Y
     FROM dbo.superstore_dataset
)
, numerator AS(
     SELECT Sub_Category,
                    --COUNT (*) AS n,
                    COUNT (*) * SUM(X*Y) AS n1,
                    SUM(X) * SUM(Y) AS n2
     FROM define_variables
     GROUP BY Sub_Category
)

, denominator AS (
     SELECT  Sub_Category,
                    COUNT(*) * SUM(X*X) - SUM(X) * SUM(X)  AS d1,
                    COUNT(*) * SUM(Y*Y) - SUM(Y) * SUM(Y)  AS d2
     FROM define_variables
     GROUP BY Sub_Category
)
, Correlation AS (
     SELECT  n.Sub_Category AS Sub_Category,
                    (n.n1 -n.n2)/(SQRT(d.d1*d.d2)) AS Correlation_Discount_vs_Profit 
     FROM numerator AS n
     LEFT JOIN denominator AS d
     ON n.Sub_Category = d.Sub_Category
)
SELECT Sub_Category, Correlation_Discount_vs_Profit
FROM Correlation
ORDER BY Correlation_Discount_vs_Profit ASC

--40.

     SELECT s1.Product_ID AS Product1, s2.Product_ID AS Product2, COUNT(s1.Order_ID) AS Frequency
     FROM dbo.superstore_dataset AS s1
     JOIN dbo.superstore_dataset AS s2
          ON s1.Order_ID = s2.Order_ID 
               AND s1.Product_ID < s2.Product_ID  -- ensures unique pairs
     GROUP BY s1.Product_ID , s2.Product_ID 
     ORDER BY Frequency DESC

SELECT 
    a.Product_Name AS Product_1,
    b.Product_Name AS Product_2,
    COUNT(*) AS times_bought_together
FROM dbo.superstore_dataset a
JOIN dbo.superstore_dataset b
    ON a.Order_ID = b.Order_ID 
   AND a.Product_Name < b.Product_Name  -- avoids duplicates like (A,B) and (B,A)
GROUP BY a.Product_Name, b.Product_Name
ORDER BY times_bought_together DESC;

INSERT INTO dbo.product_affinity (Product_1, Product_2, times_bought_together)
SELECT 
    a.Product_Name AS Product_1,
    b.Product_Name AS Product_2,
    COUNT(*) AS times_bought_together
FROM dbo.superstore_dataset a
JOIN dbo.superstore_dataset b
    ON a.Order_ID = b.Order_ID 
   AND a.Product_Name < b.Product_Name  -- avoid duplicate pairs like (A,B) and (B,A)
GROUP BY a.Product_Name, b.Product_Name;
SELECT * FROm  dbo.product_affinity 

/*
🧩 Business-Driven & Strategic Analysis Questions

41. Which customers are at risk of churn?
Identify customers who haven’t placed any orders in the last 12 months and had a declining profit trend in their last 3 orders.

42. Which products are frequently sold with high discounts but generate little to no profit?
Analyze high-discount products and their corresponding profit margins to identify potential candidates for pricing strategy review.

43. What is the reorder rate for products by category?
Find the percentage of customers who ordered the same product more than once, grouped by category.

44. Which customer segments contribute the highest profit per marketing dollar?
Assume a marketing cost per order based on segment, and calculate profit minus marketing cost.

45. What is the lifetime value (LTV) of customers across different regions?
Aggregate profit per customer over time, grouped by region, to assess customer value distribution.
*/
/*
46. Which shipping modes are associated with higher return rates?
Assuming negative profit = return, analyze return rates by shipping mode to assess logistical impact.

47. Identify seasonal trends in product performance.
Highlight products that sell significantly more in specific quarters (seasonality) and their corresponding profit impact.

48. What are the top underperforming products by sales-to-inventory ratio?
Assume an inventory quantity field or use quantity sold as a proxy; identify products with low turnover.

49. Which cities show high demand but low profitability?
Find cities with high order volume but below-average profit per order — a red flag for operational inefficiencies or pricing issues.

50. Which sub-categories have rising customer acquisition but declining profitability?
Detect product sub-categories with an increasing number of new customers year over year but a decreasing profit trend.
*/
--41
          -- Step 1: Get the latest order date from the dataset
          WITH last_date AS (
          SELECT MAX(Order_Date) AS last_order_date
          FROM dbo.superstore_dataset
          ),
          -- Step 2: Get the last order date for each customer
          last_order_by_customer AS (
          SELECT Customer_ID, MAX(Order_Date) AS last_order_date_by_Customer
          FROM dbo.superstore_dataset
          GROUP BY Customer_ID
          ),
          -- Step 3: Filter customers who haven’t placed any orders in the last 12 months
          not_placed_order_in_12_months AS (
          SELECT   c.Customer_ID, c.last_order_date_by_Customer, ld.last_order_date,
               DATEDIFF(MONTH, c.last_order_date_by_Customer, ld.last_order_date) AS months_since_last_order
          FROM last_order_by_customer c
          CROSS JOIN last_date ld
          WHERE DATEDIFF(MONTH, c.last_order_date_by_Customer, ld.last_order_date) > 12
          ),
          -- Step 4: Get last 3 orders per customer with profit
          last_3_orders AS (
          SELECT  st.Customer_ID, st.Order_Date, st.Order_ID, st.Profit,
               ROW_NUMBER() OVER (PARTITION BY st.Customer_ID ORDER BY st.Order_Date DESC) AS rn
          FROM dbo.superstore_dataset st
          WHERE st.Customer_ID IN (SELECT Customer_ID FROM not_placed_order_in_12_months)
          ),
          -- Step 5: Only keep the last 3 orders
          top_3_orders AS (
          SELECT *
          FROM last_3_orders
          WHERE rn <= 3
          ),
          -- Step 6: Pivot the last 3 profits to check trend
          profit_trend AS (
          SELECT  Customer_ID,
               MAX(CASE WHEN rn = 1 THEN Profit END) AS profit_1,
               MAX(CASE WHEN rn = 2 THEN Profit END) AS profit_2,
               MAX(CASE WHEN rn = 3 THEN Profit END) AS profit_3
          FROM top_3_orders
          GROUP BY Customer_ID
          )
          -- Step 7: Final selection of customers with strictly declining profit trend
          SELECT   Customer_ID, profit_3 AS oldest_profit, profit_2 AS middle_profit, profit_1 AS most_recent_profit
          FROM profit_trend
          WHERE profit_3 > profit_2 AND profit_2 > profit_1;

--42.
          WITH highest_marging AS (
                    SELECT Product_ID, Product_Name,  Discount, SUM(Profit)/NULLIF(SUM(Sales),0) AS profit_margin
                    FROM dbo.superstore_dataset 
                    GROUP BY Product_ID, Product_Name, Discount           
                              )
          SELECT Product_ID, Product_Name,  Discount, profit_margin
          FROM highest_marging 
          WHERE profit_margin <=0 AND Discount >=0.2
          ORDER BY profit_margin, Discount
--43.
          WITH customer_product_orders AS (
          SELECT  Customer_ID,  Product_ID,  Sub_Category, COUNT(*) AS order_count
          FROM dbo.superstore_dataset
          GROUP BY Customer_ID, Product_ID, Sub_Category
          ),
          reordered_customers AS (
               SELECT DISTINCT Customer_ID, Sub_Category
               FROM customer_product_orders
               WHERE order_count > 1
          ),
          total_customers_by_category AS (
               SELECT DISTINCT Customer_ID, Sub_Category
               FROM dbo.superstore_dataset
          ) SELECT * FROM total_customers_by_category
          ,
          reorder_rate AS (
               SELECT  tc.Sub_Category, COUNT(DISTINCT rc.Customer_ID) * 1.0 / COUNT(DISTINCT tc.Customer_ID) * 100 AS reorder_percentage
               FROM total_customers_by_category tc
               LEFT JOIN reordered_customers rc 
                    ON tc.Customer_ID = rc.Customer_ID AND tc.Sub_Category = rc.Sub_Category
               GROUP BY tc.Sub_Category
          )
          SELECT * 
          FROM reorder_rate
          ORDER BY reorder_percentage DESC;
          
--44.
          WITH Segment_with_Market_cost AS(
          SELECT Segment,
               COUNT(DISTINCT Order_ID) AS Couting_Orders,
               SUM(Profit) AS Total_Profit,
               -- Assign marketing cost based on segment
               CASE Segment
                    WHEN 'Consumer' THEN 5
                    WHEN 'Corporate' THEN 3
                    WHEN 'Home Office' THEN 2
               END AS Marketing_Cost_Per_Order
          FROM dbo.superstore_dataset
          GROUP BY Segment
          )
          SELECT Segment, Couting_Orders, Total_Profit, Marketing_Cost_Per_Order,
                         Total_Profit - Couting_Orders * Marketing_Cost_Per_Order AS Net_Profit,
                         (Total_Profit - (Couting_Orders * Marketing_Cost_Per_Order)) * 1.0 / (Couting_Orders * Marketing_Cost_Per_Order) AS Net_Profit_Per_Marketing_Dollar
          FROM Segment_with_Market_cost
--45.
          SELECT   Customer_ID , Region,   YEAR(Order_Date) AS Order_Year, SUM(Profit) AS Total_Profit
          FROM dbo.superstore_dataset
          GROUP BY Customer_ID, Region, YEAR(Order_Date)
          ORDER BY Region, Order_Year, Total_Profit DESC;

--46: 
          WITH Define_return AS (
          SELECT  Ship_Mode, 
               CASE  
                    WHEN Profit < 0 THEN 'Return'
                    ELSE 'Accept' 
               END AS Return_Order
          FROM dbo.superstore_dataset
          )
          , Return_Counts AS (
               SELECT   Ship_Mode,  Return_Order, 
               COUNT(*) AS Total_Orders
               FROM Define_return
               GROUP BY Ship_Mode, Return_Order
          )
          , Ship_Mode_Total AS (
               SELECT 
                    Ship_Mode, 
                    COUNT(*) AS Total_Ship_Mode
               FROM dbo.superstore_dataset
               GROUP BY Ship_Mode
          )
          SELECT  rc.Ship_Mode, rc.Return_Order,  rc.Total_Orders,  smt.Total_Ship_Mode,
          CAST(rc.Total_Orders * 100.0 / smt.Total_Ship_Mode AS DECIMAL(5,2)) AS Percentage
          FROM Return_Counts rc
          JOIN Ship_Mode_Total smt
          ON rc.Ship_Mode = smt.Ship_Mode
          ORDER BY rc.Ship_Mode, rc.Return_Order;

--47.
          WITH sales_profit_by_quarter AS (
          SELECT
               Product_ID,
               DATEPART(YEAR, Order_Date) AS sales_year,
               DATEPART(QUARTER, Order_Date) AS sales_quarter,
               SUM(Sales) AS total_sales,
               SUM(Profit) AS total_profit
          FROM dbo.superstore_dataset
          GROUP BY Product_ID, DATEPART(YEAR, Order_Date), DATEPART(QUARTER, Order_Date)
          ),
          ranked_sales AS (
          SELECT *,
                    RANK() OVER (PARTITION BY Product_ID, sales_year ORDER BY total_sales DESC) AS sales_rank
          FROM sales_profit_by_quarter
          ),
          seasonal_products AS (
          SELECT Product_ID, sales_quarter, COUNT(*) AS count_peak_quarter
          FROM ranked_sales
          WHERE sales_rank = 1
          GROUP BY Product_ID, sales_quarter
          HAVING COUNT(*) >= 2  -- Appears as top-selling quarter in at least 2 years
          )
          SELECT sp.Product_ID, sp.sales_quarter, sp.count_peak_quarter, 
               AVG(sq.total_profit) AS avg_profit_in_quarter
          FROM seasonal_products sp
          JOIN sales_profit_by_quarter sq 
          ON sp.Product_ID = sq.Product_ID AND sp.sales_quarter = sq.sales_quarter
          GROUP BY sp.Product_ID, sp.sales_quarter, sp.count_peak_quarter
          ORDER BY avg_profit_in_quarter DESC;

--48. 
          WITH Quantity_sold_by_month AS (
          SELECT Product_ID, MONTH(Order_date) AS Month_Sale
          FROM dbo.superstore_dataset
          )
          , Active_Month AS (
               SELECT Product_ID, COUNT(DISTINCT Month_Sale) AS number_active_month
               FROM Quantity_sold_by_month
               GROUP BY Product_ID
          ),
          Total_Quantity AS (
          SELECT Product_ID, SUM(Quantity) AS Total_quantity_sold
          FROM dbo.superstore_dataset
          GROUP BY Product_ID
          )
          SELECT   am.Product_ID,  pn.Product_Name, am.number_active_month,  tq.Total_quantity_sold, 
          tq.Total_quantity_sold * 1.0 / NULLIF(am.number_active_month, 0) AS turnover_rate
          FROM Active_Month AS am
          JOIN Total_Quantity AS tq ON am.Product_ID = tq.Product_ID
          JOIN dbo.superstore_dataset AS pn ON am.Product_ID = pn.Product_ID
          GROUP BY am.Product_ID, pn.Product_Name, am.number_active_month, tq.Total_quantity_sold
          ORDER BY turnover_rate ASC;

--49:
          WITH CityStats AS (
          SELECT   City,  COUNT(Order_ID) AS Order_Count, SUM(Profit) AS Total_Profit,   SUM(Profit) * 1.0 / COUNT(Order_ID) AS Profit_Per_Order
          FROM  dbo.superstore_dataset
          GROUP BY  City
          ),
          AverageProfit AS (
          SELECT AVG(Profit_Per_Order) AS Avg_Profit_Per_Order
          FROM CityStats
          )
          SELECT   cs.City, cs.Order_Count,  cs.Total_Profit,  cs.Profit_Per_Order
          FROM  CityStats cs
          JOIN   AverageProfit ap ON 1=1
          WHERE  cs.Order_Count > (SELECT AVG(Order_Count) FROM CityStats) -- high demand
               AND cs.Profit_Per_Order < ap.Avg_Profit_Per_Order -- low profitability
          ORDER BY   cs.Order_Count DESC;

--50. 
          SELECT Sub_Category,  Order_Year
          FROM (
                    SELECT Sub_Category,  Order_Year, Customer_by_year, Customer_prev_year, 
                                   CASE WHEN Customer_prev_year > Customer_by_year THEN 1 ELSE 0 END new_customer,
                                   Total_Profit, Profit_prev_year,
                                   CASE WHEN Profit_prev_year < Total_Profit THEN 1 ELSE 0 END decrease_profit

                    FROM (
                                   SELECT   Sub_Category,  
                                             YEAR(Order_Date) AS Order_Year, 
                                             COUNT(DISTINCT Customer_ID) AS Customer_by_year, 
                                             LAG(COUNT(DISTINCT Customer_ID)) OVER (PARTITION BY Sub_Category ORDER BY YEAR(Order_Date)) AS Customer_prev_year, 
                                             SUM(Profit) AS Total_Profit, 
                                             LAG(SUM(Profit)) OVER (PARTITION BY Sub_Category ORDER BY YEAR(Order_Date)) AS Profit_prev_year
                                   FROM  dbo.superstore_dataset
                                   GROUP BY  Sub_Category,  YEAR(Order_Date)
                              ) AS st
          ) AS sto
          WHERE decrease_profit = 1 AND new_customer =1 

/*
TIME SERIES ANALYSIS

Time series data is a collection of variables whose values depend on time. Analyzing time-series data is trivial with Python, but with SQL, 
it becomes a pretty challenging task. Work on this project to understand what difficulties one might encounter using SQL for time series analysis. 

Dataset: Use the SuperStore Time Series Dataset (https://www.kaggle.com/datasets/blurredmachine/superstore-time-series-dataset) 
from Kaggle to work on this project. The dataset contains 20 columns, namely, 
Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, and City.
SQL Project Idea: Clean the data first using the data preprocessing method and make it SQL-ready. After that, complete the following tasks:

     - Use the LEAD window function to create a new column sales_next that displays the sales of the next row in the dataset. 
        This function will help you quickly compare a given row’s values and values in the next row.
     - Create a new column sales_previous to display the values of the row above a given row.
     - Rank the data based on sales in descending order using the RANK function.
     - Use common SQL commands and aggregate functions to show the monthly and daily sales averages.
     - Analyze discounts on two consecutive days.
     - Evaluate moving averages using the window functions.
*/

-------------------LOOK UP ALL THE COLUMNS------------------------------------------
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'superstore_dataset' AND TABLE_SCHEMA = 'dbo';
-----------------------------------------------------------------------------------------------------
--create a new column sales_next that displays the sales of the next row in the dataset.
WITH Sale_Info AS(
     SELECT  Product_ID, Order_date, 
         LAG(Sales) OVER(PARTITION BY Product_ID ORDER BY  Product_ID, Order_date) AS sales_previous ,
          Sales, 
          LEAD(Sales) OVER(PARTITION BY Product_ID ORDER BY Product_ID, Order_date) AS sales_next ,
          RANK() OVER(ORDER BY Sales) AS rank_sales
     FROM dbo.superstore_dataset
)
WITH Monthly_Sales_Calculation AS (
     SELECT  Product_ID, FORMAT(Order_Date,'yyyy-MM') AS month_year,
               AVG(Sales)  AS Monthly_Sales
     FROM dbo.superstore_dataset
     GROUP BY   Product_ID, FORMAT(Order_Date,'yyyy-MM')
     ORDER BY month_year

)
WITH Daily_Sales_Calculation AS (
     SELECT  Product_ID, Order_Date AS Daily,
               AVG(Sales)  AS Daily_Sales
     FROM dbo.superstore_dataset
     GROUP BY   Product_ID, Order_Date
     ORDER BY Order_Date
)
--AVERAGE SALES BETWEEN TWO CONSECUTIVE DAYS
WITH Two_consecutive_days AS (
     SELECT Product_ID, previous_date , Order_date, day_different FROM (
               SELECT  Product_ID, 
                    LAG(Order_date) OVER(PARTITION BY Product_ID ORDER BY  Product_ID, Order_date) AS previous_date,
                    Order_date ,
                    DATEDIFF(DAY,  LAG(Order_date) OVER(PARTITION BY Product_ID ORDER BY  Product_ID, Order_date), Order_Date) AS day_different
               FROM dbo.superstore_dataset
     ) AS Subquery
     WHERE day_different =1 
)
, Average_Sales_by_2_consecutive_days AS(
     SELECT tc1.Product_ID AS Product_ID,  tc1.previous_date, st.Sales AS previous_sales, tc1.Order_date AS current_month, st2.Sales AS current_month_sale
     FROM Two_consecutive_days AS tc1
     LEFT JOIN dbo.superstore_dataset AS st
     ON tc1.Product_ID = st.Product_ID AND tc1.previous_date = st.Order_Date

     LEFT JOIN dbo.superstore_dataset AS st2
     ON tc1.Product_ID = st2.Product_ID AND tc1.Order_date = st2.Order_Date
)
SELECT Product_ID, previous_sales, current_month_sale , (previous_sales + current_month_sale) / 2 AS Average_sale  FROM Average_Sales_by_2_consecutive_days

--AVERAGE SALES BETWEEN TWO CONSECUTIVE MONTHS
WITH load_data_product AS (
     SELECT  Product_ID, 
                    --FORMAT(Order_Date, 'yyyy-MM') AS Order_month_str,
                    CAST(FORMAT(Order_Date, 'yyyy-MM-01') AS DATE) AS Order_month,
                    SUM(Sales) AS Sales 
     FROM dbo.superstore_dataset
     GROUP BY  Product_ID,     FORMAT(Order_Date, 'yyyy-MM-01')
)
, Two_consecutive_months AS (
     SELECT Product_ID, previous_month , Order_month, month_difference FROM (
               SELECT  Product_ID, 
                    LAG(Order_month) OVER(PARTITION BY Product_ID ORDER BY  Product_ID, Order_month) AS previous_month,
                    Order_month ,
                    DATEDIFF(MONTH,  LAG(Order_month) OVER(PARTITION BY Product_ID ORDER BY  Product_ID, Order_month), Order_month) AS month_difference
               FROM load_data_product
     ) AS Subquery
     WHERE month_difference =1 
)
, Average_Sales_by_2_consecutive_months AS(
     SELECT tc1.Product_ID AS Product_ID,  FORMAT(tc1.previous_month,'yyyy-MM') AS previous_month, st.Sales AS previous_sales, FORMAT(tc1.Order_month, 'yyyy-MM') AS current_month, st2.Sales AS current_month_sale
     FROM Two_consecutive_months AS tc1

     LEFT JOIN load_data_product AS st
     ON tc1.Product_ID = st.Product_ID AND FORMAT(tc1.previous_month, 'yyyy-MM') = FORMAT(st.Order_month, 'yyyy-MM')

     LEFT JOIN load_data_product AS st2
     ON tc1.Product_ID = st2.Product_ID AND FORMAT(tc1.Order_month, 'yyyy-MM') = FORMAT(st2.Order_month, 'yyyy-MM')
)
SELECT Product_ID, previous_sales, current_month_sale , (previous_sales + current_month_sale) / 2 AS Average_sale  FROM Average_Sales_by_2_consecutive_months

/*------------------MOVING AVERAGE: -------------------*/
--Calculate moving average of sales for each product over time
SELECT Order_ID, Product_ID, Order_Date, Sales,
     AVG (Sales) OVER ( PARTITION BY Product_ID) AvgByProduct,
     AVG (Sales) OVER ( PARTITION BY Product_ID ORDER BY Order_Date) AvgByProduct,
     --Calculate moving average of sales for each product over 30 days, including only the next order
     AVG (Sales) OVER ( PARTITION BY Product_ID ORDER BY Order_Date
                                        ROWS BETWEEN CURRENT ROW AND 30 FOLLOWING) AvgByProduct
FROM dbo.superstore_dataset

------------------------------------------------END-------------------------------------------------------------------------
