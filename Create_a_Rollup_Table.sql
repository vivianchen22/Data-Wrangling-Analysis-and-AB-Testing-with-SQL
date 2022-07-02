--Exercise 1: Create a subtable of orders per day. Make sure you decide whether you are counting invoices or line items.
--Answer Note: decided to count order by unique invoice_id.
SELECT 
  DATE(paid_at)                 AS Day,
  COUNT(DISTINCT invoice_id)    AS Orders,
  COUNT(DISTINCT line_item_id)  AS Line_Item
FROM 
  dsv1069.orders
GROUP BY
  Day
ORDER BY 
  Day 
  
  
--Exercise 2: “Check your joins”. We are still trying to count orders per day.
--In this step join the sub table from the previous exercise to the dates rollup table so we can get a row for every date. 
--Check that the join works by just running a “select *” query

SELECT
  *
FROM
  dsv1069.dates_rollup
LEFT JOIN
  (SELECT 
    DATE(paid_at)                 AS Day,
    COUNT(DISTINCT invoice_id)    AS Orders,
    COUNT(DISTINCT line_item_id)  AS Items_Ordered
  FROM 
    dsv1069.orders
  GROUP BY
    Day) AS Daily_orders
ON
  dsv1069.dates_rollup.date =Daily_orders.Day
 
--Exercise 3: “Clean up your Columns” In this step be sure to specify the columns you actually
--want to return, and if necessary do any aggregation needed to get a count of the orders made per day.

SELECT
  dsv1069.dates_rollup.date             AS Day,
  COALESCE(SUM(Orders),0)               AS Orders,
  COALESCE(SUM(Items_Ordered),0)        AS Items_Ordered  
FROM
  dsv1069.dates_rollup
LEFT JOIN
  (SELECT 
    DATE(paid_at)                 AS Day,
    COUNT(DISTINCT invoice_id)    AS Orders,
    COUNT(DISTINCT line_item_id)  AS Items_Ordered
  FROM 
    dsv1069.orders
  GROUP BY
    Day) AS Daily_orders
ON
  dsv1069.dates_rollup.date =Daily_orders.Day
GROUP BY 
  dsv1069.dates_rollup.date
 
 
--Exercise 4: Weekly Rollup. Figure out which parts of the JOIN condition need to be edited create 7 day rolling orders table.
--Starter Code: Result from EX2
--Answer Note: needed to join on the condition that dsv1069.dates_rollup.d7_ago < Daily_orders.Day <= d7_ago.Date 
SELECT
  *
FROM
  dsv1069.dates_rollup
LEFT JOIN
  (SELECT 
    DATE(paid_at)                 AS Day,
    COUNT(DISTINCT invoice_id)    AS Orders,
    COUNT(DISTINCT line_item_id)  AS Items_Ordered
  FROM 
    dsv1069.orders
  GROUP BY
    Day) AS Daily_orders
ON
  dsv1069.dates_rollup.date >=Daily_orders.Day
AND
  dsv1069.dates_rollup.d7_ago < Daily_orders.Day


-- Exercise 5: Column Cleanup. Finish creating the weekly rolling orders table, 
--by performing any aggregation steps and naming your columns appropriately.
SELECT
  dsv1069.dates_rollup.date             AS Day,
  COALESCE(SUM(Orders),0)               AS Orders,
  COALESCE(SUM(Items_Ordered),0)        AS Items_Ordered
FROM
  dsv1069.dates_rollup
LEFT JOIN
  (SELECT 
    DATE(paid_at)                 AS Day,
    COUNT(DISTINCT invoice_id)    AS Orders,
    COUNT(DISTINCT line_item_id)  AS Items_Ordered
  FROM 
    dsv1069.orders
  GROUP BY
    Day) AS Daily_orders
ON
  dsv1069.dates_rollup.date >=Daily_orders.Day
AND
  dsv1069.dates_rollup.d7_ago < Daily_orders.Day
GROUP BY 
  dsv1069.dates_rollup.date
