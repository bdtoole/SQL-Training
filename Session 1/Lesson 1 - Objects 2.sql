SELECT U.Id
	 , U.DisplayName
	 , COUNT(P.Id) AS NumPosts
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 WHERE U.DisplayName LIKE '%Toole%'
 GROUP BY U.Id, U.DisplayName
GO

SELECT *
  FROM dbo.Posts
 WHERE OwnerUserId = 42604
GO

/* CREATE VIEW */
DROP VIEW IF EXISTS Training.vwFavoritePosts
GO

CREATE VIEW Training.vwFavoritePosts AS
SELECT Id AS PostId
	 , Body
	 , CreationDate
	 , FavoriteCount
	 , Score
  FROM dbo.Posts
 WHERE OwnerUserId = 42604
   AND FavoriteCount > 0
GO

SELECT * FROM Training.vwFavoritePosts

/* CREATE TABLE VALUED FUNCTION */
DROP FUNCTION IF EXISTS Training.fnGetFavoritedPosts
GO

CREATE FUNCTION Training.fnGetFavoritedPosts(@UserID INT) RETURNS TABLE
AS
RETURN
(
SELECT Id AS PostId
	 , Body
	 , CreationDate
	 , FavoriteCount
	 , Score
  FROM dbo.Posts
 WHERE OwnerUserId = @UserID
   AND FavoriteCount > 0
)
GO

SELECT * FROM Training.fnGetFavoritedPosts(42604)

/* APPLY WITH TABLE VALUED FUNCTION */
SELECT U.Id AS UserId
	 , U.AboutMe
	 , U.DisplayName
	 , U.CreationDate AS UserCreationDate
	 , P.PostId
	 , P.Body
	 , P.CreationDate AS PostCreationDate
	 , P.FavoriteCount
	 , P.Score
  FROM dbo.Users AS U
 CROSS APPLY Training.fnGetFavoritedPosts(U.Id) AS P
 WHERE DisplayName LIKE '%Toole%'

/* PROCEDURE WITH OUTPUT PARAMETERS */

DROP PROCEDURE IF EXISTS Training.spPopulateUserPostDetails
GO

CREATE PROCEDURE Training.spPopulateUserPostDetails(@DisplayName NVARCHAR(40), @PostIDWithLongestBody INT OUTPUT, @LongestBodyLength INT OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	DROP TABLE IF EXISTS #FavoritedPosts
	SELECT U.Id AS UserId
		 , U.AboutMe
		 , U.DisplayName
		 , U.CreationDate AS UserCreationDate
		 , P.PostId
		 , P.Body
		 , P.CreationDate AS PostCreationDate
		 , P.FavoriteCount
		 , P.Score
	  INTO #FavoritedPosts
	  FROM dbo.Users AS U
	 CROSS APPLY Training.fnGetFavoritedPosts(U.Id) AS P
	 WHERE DisplayName LIKE CONCAT('%',@DisplayName,'%')

	DECLARE @LongestBody VARCHAR(MAX)
		  , @MaxFavoriteCount INT

	SELECT @MaxFavoriteCount = MAX(FavoriteCount)
	  FROM #FavoritedPosts

	SELECT @LongestBody = Body
	  FROM #FavoritedPosts
	 WHERE LEN(Body) = (SELECT MAX(LEN(Body))
					      FROM #FavoritedPosts
					   )

	INSERT INTO Training.UserPostDetails( DisplayName
										, PostId
										, Body
										, FavoriteCount
										)
	SELECT DisplayName
		 , PostId
		 , Body
		 , FavoriteCount
	  FROM #FavoritedPosts
	 WHERE FavoriteCount = @MaxFavoriteCount

	--INSERT INTO Training.UserPostDetails( DisplayName
	--									, PostId
	--									, Body
	--									, FavoriteCount
	--									)
	--SELECT SRC.DisplayName
	--	 , SRC.PostId
	--	 , SRC.Body
	--	 , SRC.FavoriteCount
	--  FROM #FavoritedPosts AS SRC
	--  LEFT JOIN Training.UserPostDetails AS DST ON DST.DisplayName = SRC.DisplayName
	--										   AND DST.PostId = SRC.PostId
	--										   AND DST.FavoriteCount = SRC.FavoriteCount
	-- WHERE SRC.FavoriteCount = @MaxFavoriteCount
	--   AND DST.DisplayName IS NULL

	--Populate output parameters
	SELECT @PostIDWithLongestBody = PostId
		 , @LongestBodyLength = LEN(Body)
	  FROM #FavoritedPosts
	 WHERE Body = @LongestBody

	SET NOCOUNT OFF
END
GO

--Create our table
DROP TABLE IF EXISTS Training.UserPostDetails
CREATE TABLE Training.UserPostDetails
(
	DisplayName NVARCHAR(40) NOT NULL
  , PostId INT NOT NULL
  , Body NVARCHAR(MAX)
  , FavoriteCount INT
  , CONSTRAINT PK_UserPostDetails PRIMARY KEY CLUSTERED (DisplayName ASC, PostId ASC, FavoriteCount ASC)
)
GO

--Run the thing
DECLARE @PostID INT
	  , @BodyLength INT
	  , @SearchName VARCHAR(10) = 'Toole'
BEGIN
	EXEC Training.spPopulateUserPostDetails @SearchName, @PostID OUTPUT, @BodyLength OUTPUT

	DECLARE @Output VARCHAR(100) = CONCAT('Post ID: ', @PostID, CHAR(13), CHAR(10), '-->Length: ',@BodyLength);

	SELECT *
	  FROM Training.UserPostDetails

	PRINT @Output

END