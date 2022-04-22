--Exercise 0: Count how many users we have 
--Also, Merged users should be considered

SELECT 
  COUNT(DISTINCT COALESCE(users.parent_user_id,id))
FROM
  dsv1069.users

--Exercise 1: Find out how many users have ever ordered
--***Also, Merged users should be considered
SELECT
  COUNT(*) AS Users_with_Orders
FROM
  (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id) AS User_ID,
    COALESCE(COUNT(DISTINCT dsv1069.orders.invoice_id),0)   AS Order_Count
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
  GROUP BY
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)) AS New_Table
WHERE
  Order_Count > 0 
  
--Exercise 2: Goal find how many users have reordered the same item
--***Also, Merged users should be considered
SELECT
  COUNT(*) AS Users_with_reorder_items
FROM
  (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)         AS User_ID,
    dsv1069.orders.item_id,
    COALESCE(COUNT(DISTINCT dsv1069.orders.line_item_id),0  )         AS Items_Orders_Count
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
  GROUP BY
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id),
    dsv1069.orders.item_id
    )  AS Users_level_orders
WHERE 
  Items_Orders_Count >1

  
-- Exercise 3: Do users even order more than once?
--***Also, Merged users should be considered
SELECT
  COUNT(*) AS Users_with_reorder
FROM
  (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)         AS User_ID,
    COALESCE(COUNT(DISTINCT dsv1069.orders.invoice_id),0  )         AS Orders_Count
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
  GROUP BY
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)
    )  AS Users_level_orders
WHERE 
  Orders_Count >1
  
-- Exercise 4: Orders per item
SELECT 
  item_id,
  COUNT(DISTINCT line_item_id) AS Order_Count
FROM
  dsv1069.orders
GROUP BY
  item_id
  

-- Exercise 5: Orders per category
SELECT 
  item_category,
  COUNT(DISTINCT line_item_id ) AS Order_Count
FROM
  dsv1069.orders
GROUP BY
  dsv1069.orders.item_category
  
-- Exercise 6: Do user order multiple things from the same category?
--***Also, Merged users should be considered
SELECT
  Users_level_orders.Category,
  AVG(Users_level_orders.Orders_Count)      AS Average_Orders_Count
FROM
  (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)         AS User_ID,
    dsv1069.orders.item_category                                    AS Category,
    COALESCE(COUNT(DISTINCT line_item_id),0)                        AS Orders_Count
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
  GROUP BY
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id),
    dsv1069.orders.item_category
    )  AS Users_level_orders
WHERE 
  Users_level_orders.Category IS NOT NULL
GROUP BY
  Users_level_orders.Category
  
--Exercise 7:Find the average time between orders
--Decide if this analysis is necessary
--***Also, Merged users should be considered
SELECT 
  First_Order.User_ID,
  DATE(First_Order.paid_at)                             AS First_Order_Date,
  DATE(Second_Order.paid_at)                            AS Second_Order_Date,
  DATE(Second_Order.paid_at)-DATE(First_Order.paid_at)  AS Date_Difference  
FROM 
  (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)         AS User_ID,
    dsv1069.orders.invoice_id                                       AS invoice_id,
    dsv1069.orders.paid_at                                          AS paid_at,
    DENSE_RANK() OVER (PARTITION BY User_ID ORDER BY paid_at ASC)   AS Order_Rank
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
    ) AS First_Order
JOIN
    (SELECT
    COALESCE(dsv1069.users.parent_user_id,dsv1069.users.id)         AS User_ID,
    dsv1069.orders.invoice_id                                       AS invoice_id,
    dsv1069.orders.paid_at                                          AS paid_at,
    DENSE_RANK() OVER (PARTITION BY User_ID ORDER BY paid_at ASC)   AS Order_Rank
  FROM 
    dsv1069.users
  LEFT JOIN
    dsv1069.orders
  ON
    dsv1069.users.id = dsv1069.orders.user_id
    ) AS Second_Order
ON 
  First_Order.User_ID = Second_Order.User_ID
WHERE 
  First_Order.Order_Rank = 1
AND 
  Second_Order.Order_Rank =2


