/* Basic JOINs */
DROP TABLE IF EXISTS #UsersNamedBrian
SELECT Id, DisplayName
  INTO #UsersNamedBrian
  FROM dbo.Users
 WHERE DisplayName = 'Brian'

DROP TABLE IF EXISTS #UserPostCount
SELECT OwnerUserId
	 , COUNT(Id) AS NumPosts
  INTO #UserPostCount
  FROM dbo.Posts
 GROUP BY OwnerUserId

SELECT U.Id
	 , U.DisplayName
     , P.NumPosts
  FROM #UsersNamedBrian AS U
  JOIN #UserPostCount AS P ON P.OwnerUserId = U.Id
 --WHERE P.NumPosts = 0

SELECT U.Id
	 , U.DisplayName
     , P.NumPosts
  FROM #UsersNamedBrian AS U
  LEFT JOIN #UserPostCount AS P ON P.OwnerUserId = U.Id
 WHERE P.OwnerUserId IS NULL

/* FULL JOIN */
SELECT *
  FROM #UsersNamedBrian AS U
  FULL JOIN #UserPostCount AS P ON P.OwnerUserId = U.Id
 WHERE U.Id IS NOT NULL
   AND P.OwnerUserId IS NOT NULL

/* CROSS JOIN */
DROP TABLE IF EXISTS #UsersWithToole
SELECT Id, DisplayName
  INTO #UsersWithToole
  FROM dbo.Users
 WHERE DisplayName LIKE '%Toole%'

DROP TABLE IF EXISTS #BotPosts
SELECT Id
	 , Body
  INTO #BotPosts
  FROM dbo.Posts
 WHERE OwnerUserId = -1
   AND LastEditorUserId = -1

SELECT *
  FROM #UsersWithToole
 CROSS JOIN #BotPosts

/* CROSS APPLY */
SELECT Id
	 , DisplayName
	 , Reputation
	 , UpVotes
	 , DownVotes
  FROM dbo.Users
 WHERE DisplayName LIKE '%Toole%'

SELECT Id
	 , DisplayName
	 , Calc.Description
	 , Calc.Value
  FROM dbo.Users
 CROSS APPLY (VALUES('Reputation',Reputation)
				   ,('UpVotes',UpVotes)
				   ,('DownVotes',DownVotes)) AS Calc(Description,Value)
 WHERE DisplayName LIKE '%Toole%'

/* DISTINCT */
SELECT DISTINCT Reputation
  FROM dbo.Users
ORDER BY Reputation
-- DISTINCT can be a very expensive operator! Imagine how much work it takes to determine every single column in a large output is unique

/* UNION and UNION ALL */
 SELECT Id
	 , DisplayName
	 , Reputation
	 , UpVotes
	 , DownVotes
  FROM dbo.Users
 WHERE DisplayName LIKE '%Toole%'

 UNION ALL

 SELECT Id
	 , DisplayName
	 , Reputation
	 , UpVotes
	 , DownVotes
  FROM dbo.Users
 WHERE DisplayName LIKE '%Eric Fr%'
 --WHERE DisplayName LIKE '%Toole%'

/* NULL operators */
SELECT FirstName
	 , MI
	 , LastName
	 , FirstName + ' ' + MI + ' ' + LastName AS FullNameAdd
	 , CONCAT(FirstName,' ',MI,' ',LastName) AS FullNameConcat
  FROM ( SELECT 'Eric' AS FirstName
			  , null AS MI
			  --, 5 AS MI
			  , 'Fraker' AS LastName
	   ) AS names

/* CASE STATEMENTS AND HIERARCHIES */
SELECT Id
	 , AboutMe
	 , CASE WHEN AboutMe IS NULL THEN ''
			WHEN AboutMe IS NULL THEN '(null)'
			WHEN AboutMe = '' THEN '(blank)'
			ELSE AboutMe
		END AS AboutMeCase
  FROM dbo.Users

/* SITUATIONAL CASE STATEMENT ALTERNATIVES */
SELECT Id
	 , ISNULL(DisplayName,'') AS DisplayName
  FROM dbo.Users

SELECT Id
	 , DisplayName
	 , IIF(DisplayName = 'tooleb',UPPER(DisplayName),'') AS DisplayName
  FROM dbo.Users
 WHERE DisplayName LIKE '%Toole%'

/* AGGREGATES */
SELECT DisplayName
	 , AVG(UpVotes) AS AvgUpVotes
	 , MAX(UpVotes) AS MaxUpVotes
	 , MIN(UpVotes) AS MinUpVotes
	 , SUM(UpVotes) AS SumUpVotes
  FROM dbo.Users
 GROUP BY DisplayName