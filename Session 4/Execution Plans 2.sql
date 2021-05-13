/* INNER JOIN */
SELECT U.Id
     , U.DisplayName
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 GROUP BY U.Id, U.DisplayName

/* LEFT JOIN */
SELECT U.Id
     , U.DisplayName
  FROM dbo.Users AS U
  LEFT JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 WHERE P.Id IS NOT NULL
 GROUP BY U.Id, U.DisplayName

/* IN */
SELECT Id
     , DisplayName
  FROM dbo.Users
 WHERE Id IN (SELECT OwnerUserId
                FROM dbo.Posts)

/* EXISTS */
SELECT U.Id
     , U.DisplayName
  FROM dbo.Users AS U
 WHERE EXISTS (SELECT P.OwnerUserId
                 FROM dbo.Posts AS P
                WHERE P.OwnerUserId = U.Id)
GO



/* LEFT JOIN */
SELECT U.Id
     , U.DisplayName
  FROM dbo.Users AS U
  LEFT JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 WHERE P.Id IS NULL
 GROUP BY U.Id, U.DisplayName

/* IN */
SELECT Id
     , DisplayName
  FROM dbo.Users
 WHERE Id NOT IN (SELECT OwnerUserId
                    FROM dbo.Posts)

/* EXISTS */
SELECT U.Id
     , U.DisplayName
  FROM dbo.Users AS U
 WHERE NOT EXISTS (SELECT P.OwnerUserId
                     FROM dbo.Posts AS P
                    WHERE P.OwnerUserId = U.Id)

--GO
--SET STATISTICS XML OFF
--GO

--DROP INDEX IF EXISTS IX_Posts_OwnerUserId ON dbo.Posts
--CREATE INDEX IX_Posts_OwnerUserId ON dbo.Posts(OwnerUserId)

--GO
--SET STATISTICS XML ON
--GO

--SELECT U.Id
--     , U.DisplayName
--  FROM dbo.Users AS U
-- WHERE NOT EXISTS (SELECT P.OwnerUserId
--                     FROM dbo.Posts AS P
--                    WHERE P.OwnerUserId = U.Id)