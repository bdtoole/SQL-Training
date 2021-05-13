--SELECT TOP 10 * FROM dbo.Users
--SELECT TOP 10 * FROM dbo.Posts
--SELECT TOP 10 * FROM dbo.PostTypes WHERE Type IN('Question','Answer')
--SELECT TOP 10 * FROM dbo.Votes
--SELECT TOP 10 * FROM dbo.VoteTypes
--SELECT TOP 10 * FROM dbo.Comments WHERE Score > 100

/*
    Create a schema called Training
*/


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

--	/*<Your Code Goes Here>*/

	SET NOCOUNT OFF
END
GO

/*
	Create a view called vwDistinctUserPosts in the Training schema that contains the User ID, Display Name, Post ID, and Body
	from your UserPostDetails table without duplicates
*/







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
	HAVING 
		 = (SELECT 
			  FROM (SELECT 
					  FROM Training.vwDistinctUserPosts
					 GROUP BY UserId
				   ) AS SUB
						   

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

	--Populate your Variable from your function

	--Complete the PRINT statement
	PRINT CONCAT('The user with the highest number of posts is: '
				,CHAR(10),CHAR(13)
				,'--> '
				,@UserName
				)

END