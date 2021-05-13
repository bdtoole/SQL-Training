--SELECT TOP 10 * FROM dbo.Users
--SELECT TOP 10 * FROM dbo.Posts
--SELECT TOP 10 * FROM dbo.PostTypes WHERE Type IN('Question','Answer')
--SELECT TOP 10 * FROM dbo.Votes
--SELECT TOP 10 * FROM dbo.VoteTypes
--SELECT TOP 10 * FROM dbo.Comments WHERE Score > 100

--Create a schema called Training
/*
	Create a table called UserPostDetails in the Training schema that contains the following columns:
	User ID
	User Display Name
	Post ID
	Post Body
	Post View Count
	Post Type (not ID)
	Vote Type (not ID)
	Comment Score
	Comment Text

	Data types, sizes, and nullability should match their sources
	No Primary Key necessary
*/
DROP TABLE IF EXISTS Training.UserPostDetails
GO

CREATE TABLE Training.UserPostDetails
(
	UserID INT NOT NULL
  , DisplayName NVARCHAR(40) NOT NULL
  , PostID INT NOT NULL
  , Body NVARCHAR(MAX)
  , ViewCount INT NOT NULL
  , PostType NVARCHAR(50) NOT NULL
  , VoteType NVARCHAR(50) NOT NULL
  , CommentScore INT NULL
  , Text NVARCHAR(700) NOT NULL
)
GO

/*
	Complete the procedure Training.spUserPostDetailsLoad so it populates
	your UserPostDetails table with data that meets the following criteria:
	1. Post Type is either Question or Answer
	2. Comment Score is more than (not including) 100
*/

DROP PROCEDURE IF EXISTS Training.spUserPostDetailsLoad
GO

CREATE PROCEDURE Training.spUserPostDetailsLoad
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE Training.UserPostDetails;

	INSERT INTO Training.UserPostDetails
	(
		UserID
	  , DisplayName
	  , PostID
	  , Body
	  , ViewCount
	  , PostType
	  , VoteType
	  , CommentScore
	  , Text
	)
	SELECT U.Id AS UserId
		 , U.DisplayName
		 , P.Id AS PostId
		 , P.Body
		 , P.ViewCount
		 , PT.Type
		 , VT.Name
		 , C.Score
		 , C.Text
	  FROM dbo.Users AS U
	  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
	  JOIN dbo.PostTypes AS PT ON PT.Id = P.PostTypeId
	  JOIN dbo.Votes AS V ON V.PostId = P.Id
                         --AND V.UserId = U.Id
	  JOIN dbo.VoteTypes AS VT ON VT.Id = V.VoteTypeId
	  JOIN dbo.Comments AS C ON C.PostId = P.Id
                            --AND C.UserId = U.Id
	 WHERE PT.Type IN('Question','Answer')
	   AND C.Score > 100

	SET NOCOUNT OFF
END
GO

/*
	Create a view called vwDistinctUserPosts in the Training schema that contains the User ID, Display Name, Post ID, and Body
	from your UserPostDetails table without duplicates
*/

DROP VIEW IF EXISTS Training.vwDistinctUserPosts
GO

CREATE VIEW Training.vwDistinctUserPosts AS
SELECT DISTINCT
	   UserId
	 , DisplayName
	 , PostID
	 , Body
  FROM Training.UserPostDetails
GO

/*
	Complete the function Training.fnMostPosts so it returns the name of the user with the highest number of posts
*/
DROP FUNCTION IF EXISTS Training.fnMostPosts
GO

CREATE FUNCTION Training.fnMostPosts() RETURNS NVARCHAR(40)
AS
BEGIN
	DECLARE @UserName NVARCHAR(40)

	SELECT @UserName = DisplayName
	  FROM Training.vwDistinctUserPosts
	 GROUP BY DisplayName
	HAVING COUNT(PostId) = (SELECT MAX(NumPosts)
							  FROM (SELECT COUNT(PostID) AS NumPosts
									  FROM Training.vwDistinctUserPosts
									 GROUP BY UserId
								   ) AS SUB
						   )

	RETURN @UserName
END
GO

/*
	Complete the following SQL block so that when you run the script, the name from your function gets printed out to the Messages window
*/
DECLARE
	@UserName NVARCHAR(40) = 'Incorrect!'
BEGIN
	--Execute your procedure
	EXEC Training.spUserPostDetailsLoad

	--Populate your Variable from your function
	SET @UserName = Training.fnMostPosts()

	--Complete the PRINT statement
	PRINT CONCAT('The user with the highest number of posts is: '
				,CHAR(10),CHAR(13)
				,'--> '
				,@UserName
				)

END