--Exercise 1: We’ll be using the users table to answer the question “How many new users are added each day?“. 
--Start by making sure you understand the columns in the table.
--Answer Note: Spotted that some users were deleted and merged. When id <> parent_user_id and parent_user id is not null, the users were merged. 
SELECT 
  id,
  parent_user_id,
  merged_at
FROM 
  dsv1069.users
ORDER BY
  parent_user_id


--Exercise 2: Without worrying about deleted user or merged users, count the number of users added each day.
SELECT 
  DATE(created_at)  AS Day,
  COUNT(*)          AS New_Added_Users
FROM 
  dsv1069.users
GROUP BY 
  Day
ORDER BY
  Day


--Exercise 3: Consider the following query. Is this the right way to count userser except merged or deleted users? 
--If all of our users were deleted tomorrow what would the result look like?
--Answer Note: tried to find the not deleted and not merged users. 

SELECT
  DATE(created_at)  AS Day,
  COUNT(*)          AS Net_Users
FROM
  dsv1069.users
WHERE
  deleted_at IS NULL
AND
  (id = parent_user_id OR parent_user_id IS NULL)
GROUP BY
  date(created_at)


--Exercise 4: Count the number of users deleted each day. Then count the number of users removed due to merging in a similar way.
--Part1
SELECT 
  DATE(deleted_at)        AS Day,
  COUNT(*)                AS Deleted_Users
FROM 
  dsv1069.users
WHERE
  deleted_at IS NOT NULL
GROUP BY  
  Day
--Part2
SELECT 
  DATE(merged_at)   AS Day,
  COUNT(*)          AS Merged_Users
FROM 
  dsv1069.users
WHERE
  id <> parent_user_id 
AND 
  parent_user_id IS NOT NULL
GROUP BY  
  Day


--Exercise 5: Use the above pieces you’ve built as subtables and create a table that has a column for the date, the number of users created, the number of users deleted and the number of users merged that day.
SELECT 
  New.Day,
  New.New_Added_Users,
  Deleted.Deleted_Users,
  Merged.Merged_Users
FROM
  (SELECT 
    DATE(created_at)    AS Day,
    COUNT(*)            AS New_Added_Users
  FROM 
    dsv1069.users
  GROUP BY 
    Day ) AS New
LEFT JOIN 
  (SELECT 
    DATE(deleted_at)    AS Day,
    COUNT(*)            AS Deleted_Users
  FROM 
    dsv1069.users
  WHERE
    deleted_at IS NOT NULL
  GROUP BY  
    Day) AS Deleted
ON 
  New.Day = Deleted.Day
LEFT JOIN 
  (SELECT 
    DATE(merged_at)   AS Day,
    COUNT(*)          AS Merged_Users
  FROM 
    dsv1069.users
  WHERE
    id <> parent_user_id 
  AND 
    parent_user_id IS NOT NULL
  GROUP BY  
    Day) AS Merged  
ON
  New.Day = Merged.Day
ORDER BY New.Day


-- Exercise 6: Refine your query from #5 to have informative column names and so that null columns return 0.
SELECT 
  New.Day,
  New.New_Added_Users,
  COALESCE(Deleted.Deleted_Users,0)                                       AS Deleted_Users,
  COALESCE(Merged.Merged_Users,0)                                         AS Merged_Users,
  New.New_Added_Users-COALESCE(Deleted_Users,0)-COALESCE(Merged_Users,0)  AS Net_Users
FROM
  (SELECT 
    DATE(created_at)    AS Day,
    COUNT(*)            AS New_Added_Users
  FROM 
    dsv1069.users
  GROUP BY 
    Day ) AS New
LEFT JOIN 
  (SELECT 
    DATE(deleted_at)    AS Day,
    COUNT(*)            AS Deleted_Users
  FROM 
    dsv1069.users
  WHERE
    deleted_at IS NOT NULL
  GROUP BY  
    Day) AS Deleted
ON 
  New.Day = Deleted.Day
LEFT JOIN 
  (SELECT 
    DATE(merged_at)   AS Day,
    COUNT(*)          AS Merged_Users
  FROM 
    dsv1069.users
  WHERE
    id <> parent_user_id 
  AND 
    parent_user_id IS NOT NULL
  GROUP BY  
    Day) AS Merged  
ON
  New.Day = Merged.Day
ORDER BY New.Day   
    
  
--Exercise 7: What if there were days where no users were created, but some users were deleted or merged. 
--Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this query, so that we won’t miss any dates.
SELECT 
  Date,
  COALESCE(New.New_Added_Users,0)                                                   AS New_Added_Users,
  COALESCE(Deleted.Deleted_Users,0)                                                 AS Deleted_Users,
  COALESCE(Merged.Merged_Users,0)                                                   AS Merged_Users,
  COALESCE(New_Added_Users,0)-COALESCE(Deleted_Users,0)-COALESCE(Merged_Users,0)    AS Net_Users
FROM 
  dsv1069.dates_rollup
LEFT JOIN
  (SELECT 
    DATE(created_at)    AS Day,
    COUNT(*)            AS New_Added_Users
  FROM 
    dsv1069.users
  GROUP BY 
    Day ) AS New
ON 
  dates_rollup.date = New.Day
LEFT JOIN
  (SELECT 
    DATE(deleted_at)    AS Day,
    COUNT(*)            AS Deleted_Users
  FROM 
    dsv1069.users
  WHERE
  deleted_at IS NOT NULL
  GROUP BY  
    Day) AS Deleted
ON
  dates_rollup.date = Deleted.Day
LEFT JOIN
  (SELECT 
    DATE(merged_at)   AS Day,
    COUNT(*)          AS Merged_Users
  FROM 
    dsv1069.users
  WHERE
    id <> parent_user_id 
  AND 
    parent_user_id IS NOT NULL
  GROUP BY  
    Day) AS Merged
ON
  dates_rollup.date = Merged.Day
ORDER BY dsv1069.dates_rollup.Date

