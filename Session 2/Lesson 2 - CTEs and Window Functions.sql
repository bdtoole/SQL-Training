/* Window Function */
SELECT DisplayName
     --, Id
     --, CreationDate
     , YEAR(CreationDate) AS CreationYear
     , COUNT(Id) AS NumUsers
  FROM dbo.Users
 WHERE DisplayName = 'Brian'
 GROUP BY DisplayName
        , YEAR(CreationDate)
        --, Id
        --, CreationDate

SELECT DISTINCT
       DisplayName
     --, Id
     --, CreationDate
     , YEAR(CreationDate) AS CreationYear
     , COUNT(Id) OVER (PARTITION BY DisplayName, YEAR(CreationDate)) AS NumUsers
  FROM dbo.Users
 WHERE DisplayName = 'Brian'
GO

/* CTE with Window Functions Example */
DROP TABLE IF EXISTS #Example
SELECT DISTINCT
	   U.Id AS UserId
	 , U.DisplayName
	 , P.Id AS PostId
	 , P.Body
  INTO #Example
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.PostTypes AS PT ON PT.Id = P.PostTypeId
  JOIN dbo.Votes AS V ON V.PostId = P.Id
                     AND V.UserId = U.Id
  JOIN dbo.VoteTypes AS VT ON VT.Id = V.VoteTypeId
  JOIN dbo.Comments AS C ON C.PostId = P.Id
                        AND C.UserId = U.Id
 WHERE PT.Type IN('Question','Answer')
GO

SELECT DisplayName
  FROM #Example
 GROUP BY DisplayName
HAVING COUNT(PostId) = (SELECT MAX(NumPosts)
						 FROM (SELECT COUNT(PostID) AS NumPosts
								 FROM #Example
								GROUP BY UserId
							  ) AS SUB
					   )
GO

/* CTE Example 1 */
;WITH CTE AS
(
SELECT DisplayName
	 , COUNT(PostId) OVER (PARTITION BY UserId) AS NumPosts
  FROM #Example
)
SELECT DISTINCT
	   DisplayName
  FROM CTE
 WHERE NumPosts = (SELECT MAX(NumPosts)
					 FROM CTE)
GO

/* CTE Example 2 */
;WITH CTE AS
(
SELECT TOP 1
	   DisplayName
	 , COUNT(PostId) OVER (PARTITION BY UserId) AS NumPosts
  FROM #Example
 ORDER BY NumPosts DESC
)
SELECT DisplayName
  FROM CTE
GO

/* CTE Example 3 */
;WITH CTE AS
(
SELECT DISTINCT
	   U.Id AS UserId
	 , U.DisplayName
	 , P.Id AS PostId
	 , P.Body
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.PostTypes AS PT ON PT.Id = P.PostTypeId
  JOIN dbo.Votes AS V ON V.PostId = P.Id
                     AND V.UserId = U.Id
  JOIN dbo.VoteTypes AS VT ON VT.Id = V.VoteTypeId
  JOIN dbo.Comments AS C ON C.PostId = P.Id
                        AND C.UserId = U.Id
 WHERE PT.Type IN('Question','Answer')
)
, WindowedCTE AS
(
SELECT DisplayName
	 , COUNT(PostId) OVER (PARTITION BY UserId) AS NumPosts
  FROM CTE
)
SELECT DISTINCT
	   DisplayName
  FROM WindowedCTE
 WHERE NumPosts = (SELECT MAX(NumPosts)
					 FROM WindowedCTE)
GO

/* CTE getting user through sequencing */
;WITH BasePopulation AS
(
SELECT DISTINCT
	   U.Id AS UserId
	 , U.DisplayName
	 , P.Id AS PostId
	 , P.Body
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.PostTypes AS PT ON PT.Id = P.PostTypeId
  JOIN dbo.Votes AS V ON V.PostId = P.Id
                     AND V.UserId = U.Id
  JOIN dbo.VoteTypes AS VT ON VT.Id = V.VoteTypeId
  JOIN dbo.Comments AS C ON C.PostId = P.Id
                        AND C.UserId = U.Id
 WHERE PT.Type IN('Question','Answer')
)
, AggPopulation AS
(
SELECT DISTINCT
	   UserId
	 , DisplayName
	 , COUNT(PostId) OVER (PARTITION BY UserId) AS NumPosts
  FROM BasePopulation
)
, SeqPopulation AS
(
SELECT DisplayName
	 , NumPosts
	 , ROW_NUMBER() OVER (ORDER BY NumPosts DESC) AS SEQ_ROWNUM
	 , RANK() OVER (ORDER BY NumPosts DESC) AS SEQ_RANK
	 , DENSE_RANK() OVER (ORDER BY NumPosts DESC) AS SEQ_DENSERANK
  FROM AggPopulation
)
SELECT *
  FROM SeqPopulation
 --WHERE SEQ_ROWNUM = 1
GO

/* LEAD/LAG Example */
;WITH PostCount AS
(
SELECT DISTINCT
	   U.Id AS UserId
	 , U.DisplayName
     , YEAR(P.CreationDate) AS PostYear
	 , COUNT(P.Id) OVER (PARTITION BY U.Id, YEAR(P.CreationDate)) AS NumPostsPerYear
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 --ORDER BY U.Id ASC, PostYear DESC
)
SELECT UserId
     , DisplayName
     , PostYear
     , NumPostsPerYear
     , LAG(NumPostsPerYear) OVER (ORDER BY PostYear ASC) AS NumPostsPrevYear
     , LEAD(NumPostsPerYear) OVER (ORDER BY PostYear ASC) AS NumPostsNextYear
  FROM PostCount
 WHERE UserId = 1
 ORDER BY PostYear DESC
GO

/* Recursive CTE */
--Example 1
DECLARE @Date DATETIME = GETDATE()
--DECLARE @Date DATETIME = DATEADD(MONTH,1,GETDATE())
SELECT @Date

;WITH DaysCTE AS
(
SELECT DATEADD(DAY,1,EOMONTH(@Date,-1)) AS [Date]
     , DATENAME(WEEKDAY, DATEADD(DAY,1,EOMONTH(@Date,-1))) AS [Day]
 UNION ALL
SELECT DATEADD(DAY,1,[Date])
     , DATENAME(WEEKDAY, DATEADD(DAY,1,[Date]))
  FROM DaysCTE
 WHERE DAY([Date]) < DAY(EOMONTH(@Date))
)
SELECT [Date], [Day]
  FROM DaysCTE
GO

--Example 2
;WITH RecursivePosts AS
(
SELECT Id
     , AcceptedAnswerId
     , Body
     , ParentId
     , 1 AS RecursionLevel
  FROM dbo.Posts
 WHERE ParentId = 0
   AND Id = 4
 UNION ALL
SELECT P.Id
     , P.AcceptedAnswerId
     , P.Body
     , P.ParentId
     , RP.RecursionLevel + 1
  FROM dbo.Posts AS P
  JOIN RecursivePosts AS RP ON RP.Id = P.ParentId
)
SELECT *
  FROM RecursivePosts