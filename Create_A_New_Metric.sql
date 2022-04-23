--Exercise 1: Using the table from Exercise 4.3 and compute a metric that measures whether a user created an order after their test assignment
--Requirements: Even if a user had zero orders, we should have a row that counts their number of orders as zero
--If the user is not in the experiment they should not be included
SELECT
  Test_Event.test_id,
  Test_Event.assignment,
  Test_Event.user_id,
  MAX(CASE WHEN 
        dsv1069.orders.paid_at IS NOT NULL THEN 1 
      ELSE 0 END) AS Order_Binary
FROM
  (SELECT 
    event_id, 
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id'THEN CAST(parameter_value AS INT) 
        ELSE NULL END ) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value
        ELSE NULL END ) AS assignment
  FROM
    dsv1069.events
  WHERE 
    event_name = 'test_assignment'
  GROUP BY
    event_id,
    event_time,
    user_id) AS Test_Event
LEFT JOIN 
  dsv1069.orders
ON
  Test_Event.user_id = dsv1069.orders.user_id
AND 
  Test_Event.event_time < dsv1069.orders.paid_at
GROUP BY 
  Test_Event.test_id,
  Test_Event.assignment,
  Test_Event.user_id

--Exercise 2:Using the table from the previous exercise, add the following metrics
--1) the number of orders/invoices
--2) the number of items ordered
--3) the total revenue from the order after treatment
SELECT
  Test_Event.test_id,
  Test_Event.assignment,
  Test_Event.user_id,
  COALESCE(COUNT(DISTINCT dsv1069.orders.invoice_id),0)     AS Orders_Count,
  COALESCE(COUNT(DISTINCT dsv1069.orders.item_id),0)        AS Items_Count,
  COALESCE(SUM(dsv1069.orders.price),0)                     AS Revenue
FROM
  (SELECT 
    event_id, 
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id'THEN CAST(parameter_value AS INT) 
        ELSE NULL END ) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value
        ELSE NULL END ) AS assignment
  FROM
    dsv1069.events
  WHERE 
    event_name = 'test_assignment'
  GROUP BY
    event_id,
    event_time,
    user_id) AS Test_Event
LEFT JOIN 
  dsv1069.orders
ON
  Test_Event.user_id = dsv1069.orders.user_id
AND 
  Test_Event.event_time < dsv1069.orders.paid_at
GROUP BY 
  Test_Event.test_id,
  Test_Event.assignment,
  Test_Event.user_id
