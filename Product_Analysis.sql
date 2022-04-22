--Exercise 0: Count how many users we have 
--Also, Merged users should be considered

SELECT 
  COUNT(DISTINCT COALESCE(users.parent_user_id,id))
FROM
  dsv1069.users

--Exercise 1: Find out how many users have ever ordered
--Also, Merged users should be considered
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
--Also, Merged users should be considered
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
  ORDER BY
    Items_Orders_Count DESC
    )  AS Users_level_orders
WHERE 
  Items_Orders_Count >1

  
  

