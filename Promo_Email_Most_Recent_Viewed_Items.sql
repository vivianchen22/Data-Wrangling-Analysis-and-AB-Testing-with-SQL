--Exercise 1: Create the right subtable for recently viewed events using the view_item_events table.
SELECT 
  user_id,
  item_id,
  event_time,
  RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS VIEW_RANK
FROM 
  dsv1069.view_item_events
  
  
--Exercise 2: Check your joins. Join your tables together recent_views, users, items
-- Starter Code: The result from Ex1

SELECT
  *
FROM
  (SELECT 
    view_item_events.user_id AS user_id ,
    view_item_events.item_id AS item_id,
    event_time,
    RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS VIEW_RANK
    
  FROM 
    dsv1069.view_item_events) AS recent_views
JOIN
  dsv1069.users
ON 
  recent_views.user_id = dsv1069.users.id
JOIN
  dsv1069.items
ON
  recent_views.item_id = dsv1069.items.id
WHERE 
  VIEW_RANK =1 
  
--Exercise 3: Clean up your columns. The goal of all this is to return all of the information
--we’ll need to send users an email about the item they viewed more recently. 
--Clean up this query outline from the outline in EX2 and pull only the columns you need. 
--Make sure they are named appropriately so that another human can read and understand their contents.
--Starter Code: Code from Ex2

SELECT
  dsv1069.users.id                    AS user_id,
  dsv1069.users.email_address         AS user_email,
  dsv1069.items.id                    AS item_id,
  dsv1069.items.name                  AS item_name,
  dsv1069.items.category              AS item_category
FROM
  (SELECT 
    view_item_events.user_id AS user_id ,
    view_item_events.item_id AS item_id,
    event_time,
    RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS VIEW_RANK
    
  FROM 
    dsv1069.view_item_events) AS recent_views
JOIN
  dsv1069.users
ON 
  recent_views.user_id = dsv1069.users.id
JOIN
  dsv1069.items
ON
  recent_views.item_id = dsv1069.items.id
WHERE 
  VIEW_RANK =1 

--Exercise 4: Consider any edge cases. If we sent an email to everyone in the results of this query, what would we want to filter out. 
--Add in any extra filtering that you think would make this email better. 
--For example should we include deleted users? 
--Should we send this email to users who already ordered the item they viewed most recently?

SELECT
  COALESCE(dsv1069.users.parent_user_id, dsv1069.users.id)        AS user_id,
  dsv1069.users.email_address                                     AS user_email,
  recent_views.event_time                                         AS view_time,
  dsv1069.items.id                                                AS item_id,
  dsv1069.items.name                                              AS item_name,
  dsv1069.items.category                                          AS item_category
FROM
  (SELECT 
    view_item_events.user_id AS user_id ,
    view_item_events.item_id AS item_id,
    event_time,
    RANK() OVER (PARTITION BY user_id ORDER BY event_time DESC ) AS VIEW_RANK
  FROM 
    dsv1069.view_item_events) AS recent_views
JOIN
  dsv1069.users
ON 
  recent_views.user_id = dsv1069.users.id
JOIN
  dsv1069.items
ON
  recent_views.item_id = dsv1069.items.id
LEFT JOIN 
 dsv1069.orders
ON
  recent_views.user_id = dsv1069.orders.user_id
AND 
  recent_views.item_id = dsv1069.orders.item_id
WHERE 
  VIEW_RANK =1 
AND 
  dsv1069.users.deleted_at IS NULL
AND 
  dsv1069.orders.item_id IS NULL
  
