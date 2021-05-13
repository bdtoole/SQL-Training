/*
    Get user, post, and comment information for the user with the most number of comments
    on a post where the user created an account, made a post, then commented on their own post,
    all on the same day
 */
;WITH CommentPostDetails AS
(
SELECT U.Id AS UserId
     , U.DisplayName
     , U.CreationDate AS UserCreateDate
     , P.Id AS PostId
     , P.Body
     , P.CreationDate AS PostDate
     , C.Id AS CommentId
     , C.Text
     , C.CreationDate AS CommentDate
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.Comments AS C ON C.UserId = U.Id
                        AND C.PostId = P.Id
)
, DetailsSorted AS
(
    SELECT UserId
         , DisplayName
         , UserCreateDate
         , Body
         , PostDate
         , Text
         , CommentDate
         , DENSE_RANK() OVER (PARTITION BY UserId ORDER BY CAST(CommentDate AS DATE) DESC) AS Seq
         , COUNT(CommentId) OVER (PARTITION BY PostId)  AS NumComments
      FROM CommentPostDetails
)
SELECT DisplayName
     , UserCreateDate
     , Body
     , PostDate
     , Text
     , CommentDate
     , NumComments
  FROM DetailsSorted
 WHERE Seq = 1
   AND NumComments = (SELECT MAX(NumComments)
                        FROM DetailsSorted
                       WHERE Seq = 1
                         AND CAST(UserCreateDate AS DATE) = CAST(PostDate AS DATE)
                         AND CAST(UserCreateDate AS DATE) = CAST(CommentDate AS DATE)
                      )
   AND CAST(UserCreateDate AS DATE) = CAST(PostDate AS DATE)
   AND CAST(UserCreateDate AS DATE) = CAST(CommentDate AS DATE)
 ORDER BY CommentDate DESC, PostDate DESC, UserCreateDate DESC


;WITH CommentPostDetails AS
(
SELECT U.Id AS UserId
     , U.DisplayName
     , U.CreationDate AS UserCreateDate
     , P.Id AS PostId
     , P.Body
     , P.CreationDate AS PostDate
     , C.Id AS CommentId
     , C.Text
     , C.CreationDate AS CommentDate
     , COUNT(C.Id) OVER (PARTITION BY P.Id) AS NumComments
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
  JOIN dbo.Comments AS C ON C.UserId = U.Id
                        AND C.PostId = P.Id
 WHERE CAST(U.CreationDate AS DATE) = CAST(P.CreationDate AS DATE)
   AND CAST(U.CreationDate AS DATE) = CAST(C.CreationDate AS DATE)
)
, DetailsSorted AS
(
    SELECT DisplayName
         , UserCreateDate
         , Body
         , PostDate
         , Text
         , CommentDate
         , NumComments
         , DENSE_RANK() OVER (ORDER BY NumComments DESC) AS Seq
      FROM CommentPostDetails
)
SELECT DisplayName
     , UserCreateDate
     , Body
     , PostDate
     , Text
     , CommentDate
     , NumComments
  FROM DetailsSorted
 WHERE Seq = 1
 ORDER BY CommentDate DESC, PostDate DESC, UserCreateDate DESC