/*
    Rewrite the below code for readability, correcting as many code smells as you can
    If possible, add in-line comments to indicate what the query does
 */

--;WITH A AS(SELECT AAA.Id,DisplayName,COUNT(AAAA.Id)COUNT FROM Users AAA JOIN Posts AAAA ON AAA.Id=OwnerUserId GROUP BY AAA.Id,DisplayName),AA AS
--(SELECT AAA.Id,DisplayName,COUNT(AAAA.Id)[COUNT]FROM Users AAA JOIN Comments AAAA ON AAA.Id=UserId GROUP BY AAA.Id,DisplayName)
--SELECT COALESCE(A.Id,AA.Id)[1],COALESCE(AA.DisplayName,A.DisplayName),ISNULL(AA.COUNT,0)[O],ISNULL(A.COUNT,0)[0]FROM A AA FULL JOIN AA A ON AA.Id=A.Id ORDER BY 2

;WITH PostCount AS
(
    SELECT U.Id
         , U.DisplayName
         , COUNT(P.Id) AS NumPosts
      FROM dbo.Users AS U
      JOIN dbo.Posts AS P ON U.Id = P.OwnerUserId
     GROUP BY U.Id, U.DisplayName
)
, CommentCount AS
(
    SELECT U.Id
         , U.DisplayName
         , COUNT(C.Id) AS NumComments
      FROM dbo.Users AS U
      JOIN dbo.Comments AS C ON U.Id = C.UserId
     GROUP BY U.Id, U.DisplayName
)
SELECT COALESCE(PC.Id,CC.Id) AS UserId
     , COALESCE(PC.DisplayName,CC.DisplayName) AS DisplayName
     , ISNULL(PC.NumPosts,0) AS NumPosts
     , ISNULL(CC.NumComments,0) AS NumComments
  FROM PostCount AS PC
  FULL JOIN CommentCount AS CC ON PC.Id = CC.Id
 ORDER BY DisplayName ASC

/*
    Rewrite the query below so it runs in under a minute. Even better if it runs in under 10 seconds!

    The query does the following:
    1. Identifies the user ID and display name of users that have never made a post
       but have commented on someone else's post
    2. Includes the comment, post title, post ID, and Post author of the post the user commented on
       in the final results

    Note: Takes just roughly 2 minutes to run (without execution plan enabled) and returns 227 rows
 */
--SELECT U.Id AS CommentingUserId
--     , U.DisplayName AS CommentingUserDisplayName
--     , C.Text AS Comment
--     , CP.Id AS CommentedPostId
--     , CP.Title AS CommentedPostTitle
--     , PU.DisplayName AS CommentedPostAuthor
--  FROM dbo.Users AS U
--  LEFT JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
--  JOIN dbo.Comments AS C ON C.UserId = U.Id
--  JOIN dbo.Posts AS CP ON CP.Id = C.PostId
--  JOIN dbo.Users AS PU ON PU.Id = CP.OwnerUserId
-- WHERE P.Id IS NULL


;WITH UsersWithoutPosts AS
(
    SELECT U.Id AS CommentingUserId
         , U.DisplayName AS CommentingUserDisplayName
      FROM dbo.Users AS U
     WHERE NOT EXISTS (SELECT P.OwnerUserId
                         FROM dbo.Posts AS P
                        WHERE P.OwnerUserId = U.Id)
)
, PostsWithComments AS
(
    SELECT C.UserId AS CommentingUserId
         , C.Text AS Comment
         , P.Id AS PostId
         , P.Title AS PostTitle
         , U.DisplayName AS PostAuthor
      FROM dbo.Comments AS C
      JOIN dbo.Posts AS P ON P.Id = C.PostId
      JOIN dbo.Users AS U ON U.Id = P.OwnerUserId
)
SELECT UWP.CommentingUserId
     , UWP.CommentingUserDisplayName
     , PWC.Comment
     , PWC.PostId
     , PWC.PostTitle
     , PWC.PostAuthor
  FROM UsersWithoutPosts AS UWP
  JOIN PostsWithComments AS PWC ON PWC.CommentingUserId = UWP.CommentingUserId