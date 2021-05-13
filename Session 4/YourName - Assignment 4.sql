/*
    Rewrite the below code for readability, correcting as many code smells as you can
    If possible, add in-line comments to indicate what the query does
 */
--;WITH A AS(SELECT AAA.Id,DisplayName,COUNT(AAAA.Id)COUNT FROM Users AAA JOIN Posts AAAA ON AAA.Id=OwnerUserId GROUP BY AAA.Id,DisplayName),AA AS
--(SELECT AAA.Id,DisplayName,COUNT(AAAA.Id)[COUNT]FROM Users AAA JOIN Comments AAAA ON AAA.Id=UserId GROUP BY AAA.Id,DisplayName)
--SELECT COALESCE(A.Id,AA.Id)[1],COALESCE(AA.DisplayName,A.DisplayName),ISNULL(AA.COUNT,0)[O],ISNULL(A.COUNT,0)[0]FROM A AA FULL JOIN AA A ON AA.Id=A.Id ORDER BY 2









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









