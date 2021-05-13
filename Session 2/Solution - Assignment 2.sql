/*
    Rewrite the below query using a CTE and Window Functions
*/
    --SELECT PostsByUser.Id
    --     , PostsByUser.DisplayName
    --     , CommentsByUserAndPost.PostId
    --     , PostsByUser.NumPosts AS NumTotalPosts
    --     , CommentsByUserAndPost.NumComments
    --  FROM (SELECT U.Id
    --             , U.DisplayName
    --             , COUNT(P.Id) AS NumPosts
    --          FROM dbo.Users AS U
    --          JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
    --         WHERE U.DisplayName = 'Jeff Atwood'
    --         GROUP BY U.Id, U.DisplayName) AS PostsByUser
    --  JOIN (SELECT U.Id
    --             , U.DisplayName
    --             , P.Id AS PostId
    --             , COUNT(C.Id) AS NumComments
    --          FROM dbo.Users AS U
    --          JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
    --          JOIN dbo.Comments AS C ON C.UserId = U.Id
    --                                AND C.PostId = P.Id
    --         WHERE U.DisplayName = 'Jeff Atwood'
    --         GROUP BY U.Id, U.DisplayName, P.Id) AS CommentsByUserAndPost
    --    ON PostsByUser.Id = CommentsByUserAndPost.Id

;WITH CTE_Posts AS
(
SELECT OwnerUserId
     , Id
     , COUNT(Id) OVER (PARTITION BY OwnerUserId) AS NumTotalPosts
  FROM dbo.Posts
)
SELECT DISTINCT
       U.Id
     , U.DisplayName
     , P.Id
     , P.NumTotalPosts
     , COUNT(C.Id) OVER (PARTITION BY U.Id, P.Id) AS NumComments
  FROM dbo.Users AS U
  JOIN CTE_Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.Comments AS C ON C.UserId = U.Id
                        AND C.PostId = P.Id
 WHERE U.DisplayName = 'Jeff Atwood'

/*
    Rewrite the below query using CTEs instead of subqueries
*/
--SELECT A.Id
--     , A.DisplayName
--     , A.AboutMe
--     , A.NetVotes
--     , A.Views
--  FROM (SELECT B.Id
--             , B.DisplayName
--             , B.AboutMe
--             , B.NetVotes
--             , B.Views
--          FROM (SELECT Id
--                     , DisplayName
--                     , AboutMe
--                     , UpVotes - DownVotes AS NetVotes
--                     , Views
--                  FROM dbo.Users
--                 WHERE AboutMe IS NOT NULL
--               ) AS B
--         WHERE B.NetVotes >= 10000
--       ) AS A
--   WHERE A.AboutMe = ''
--   ORDER BY Views DESC

;WITH Votes AS
(
SELECT Id
     , DisplayName
     , AboutMe
     , UpVotes - DownVotes AS NetVotes
     , Views
  FROM dbo.Users
 WHERE AboutMe IS NOT NULL
)
, FiveDigitVotes AS
(
SELECT Id
     , DisplayName
     , AboutMe
     , NetVotes
     , Views
  FROM Votes
 WHERE NetVotes >= 10000
)
SELECT Id
     , DisplayName
     , AboutMe
     , NetVotes
     , Views
  FROM FiveDigitVotes
 WHERE AboutMe = ''
 ORDER BY Views DESC

/*
    Add two Window functions to the CTE and complete the query below to return
    all the columns in the CTE for the two most recent comments where there are
    three or more comments for a given user and post, ordered by name and post ascending
    with the most recent comment in each group first
*/

;WITH SortedData AS
(
    SELECT U.DisplayName
         , P.Body AS Post
         , P.CreationDate AS PostDate
         , C.Text AS Comment
         , C.CreationDate AS CommentDate
         --, Your Window functions go here
         , COUNT(C.Id) OVER (PARTITION BY U.Id
                                        , P.Id) AS NumComments
         , ROW_NUMBER() OVER (PARTITION BY U.Id
                                         , P.Id
                                  ORDER BY C.CreationDate DESC) AS SEQ
      FROM dbo.Users AS U
      JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
      JOIN dbo.Comments AS C ON C.UserId = U.Id
                            AND C.PostId = P.Id
)
SELECT DisplayName
     , Post
     , PostDate
     , Comment
     , CommentDate
     , NumComments
     , SEQ
  FROM SortedData
 WHERE NumComments >= 3
   AND SEQ <= 2
 ORDER BY DisplayName ASC
        , Post ASC

/*
    Rewrite the below MERGE statement as a DELETE statement

    Note:
        SELECT COUNT(*) FROM #UsersFromOregon prior to executing MERGE returns 156
        SELECT COUNT(*) FROM #UsersFromOregon after executing MERGE returns 26
*/
DROP TABLE IF EXISTS #UsersFromOregon
SELECT Id
     , DisplayName
     , CreationDate
     , AboutMe
  INTO #UsersFromOregon
  FROM dbo.Users
 WHERE Location LIKE '%Oregon%'
GO

DROP TABLE IF EXISTS #UsersWithPosts
SELECT DISTINCT
       U.Id
     , U.DisplayName
     , U.CreationDate
     , U.AboutMe
  INTO #UsersWithPosts
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
GO

--MERGE #UsersFromOregon AS UO
--USING #UsersWithPosts AS UP
--   ON UO.Id = UP.Id
-- WHEN MATCHED THEN DELETE;

--Your DELETE statement goes here
DELETE UO
  FROM #UsersFromOregon AS UO
  JOIN #UsersWithPosts AS UP ON UP.Id = UO.Id
GO

/*
    Bonus Question:
    Rewrite the below MERGE statement as individual UPDATE, DELETE and INSERT statements. Id should be preserved

    SELECT COUNT(*) FROM #UsersMissingData prior to executing MERGE returns 45,197 rows
    SELECT COUNT(*) FROM #UsersMissingData prior to executing MERGE returns 121,951 rows
    The end result should only have NULLS in the AboutMe column of Inserted Records
*/
DROP TABLE IF EXISTS #UsersMissingData
SELECT Id
     , DisplayName
     , AboutMe
     , WebsiteUrl
     , Location
  INTO #UsersMissingData
  FROM dbo.Users
 WHERE AboutMe = ''
   AND ISNULL(WebsiteUrl,'') = ''
   AND ISNULL(Location,'') = ''
GO

DROP TABLE IF EXISTS #UsersWithNoAboutMe
SELECT Id
     , DisplayName
     , AboutMe
  INTO #UsersWithNoAboutMe
  FROM dbo.Users
 WHERE ISNULL(AboutMe,'') = ''
   AND ISNULL(WebsiteUrl,'') = ''
   AND ISNULL(Location,'') = ''
GO

--SET IDENTITY_INSERT #UsersMissingData ON

--MERGE #UsersMissingData AS M
--USING #UsersWithNoAboutMe AS N
--   ON M.Id = N.Id
-- WHEN NOT MATCHED BY TARGET
--      THEN INSERT( Id
--                 , DisplayName
--                 , AboutMe
--                 , WebsiteUrl
--                 , Location
--                 )
--           VALUES( N.Id
--                 , N.DisplayName
--                 , N.AboutMe
--                 , 'Inserted'
--                 , 'Record'
--                 )
-- WHEN MATCHED AND M.AboutMe = ''
--              AND M.WebsiteUrl = ''
--              AND M.Location = ''
--      THEN UPDATE SET M.AboutMe = 'All'
--                    , M.WebsiteUrl = 'Three'
--                    , M.Location = 'Blank'
-- WHEN MATCHED AND (M.WebsiteUrl IS NULL OR M.Location IS NULL)
--      THEN DELETE;

--SET IDENTITY_INSERT #UsersMissingData OFF

--Your UPDATE, DELETE, and INSERT statements go here
UPDATE M
   SET M.AboutMe = 'All'
     , M.WebsiteUrl = 'Three'
     , M.Location = 'Blank'
  FROM #UsersMissingData AS M
  JOIN #UsersWithNoAboutMe AS N ON N.Id = M.Id
 WHERE M.AboutMe = ''
   AND M.WebsiteUrl = ''
   AND M.Location = ''

DELETE M
  FROM #UsersMissingData AS M 
  JOIN #UsersWithNoAboutMe AS N ON N.Id = M.Id
 WHERE M.WebsiteUrl IS NULL
    OR M.Location IS NULL

SET IDENTITY_INSERT #UsersMissingData ON

INSERT INTO #UsersMissingData
            (
                Id
              , DisplayName
              , AboutMe
              , WebsiteUrl
              , Location
            )
       SELECT N.Id
            , N.DisplayName
            , N.AboutMe
            , 'Inserted'
            , 'Record'
         FROM #UsersWithNoAboutMe AS N
         LEFT JOIN #UsersMissingData AS M ON M.Id = N.Id
        WHERE M.Id IS NULL
          --AND N.AboutMe IS NULL

SET IDENTITY_INSERT #UsersMissingData OFF