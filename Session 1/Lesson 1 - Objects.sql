--DROP PROCEDURE IF EXISTS Training.spPopulateScores
--DROP FUNCTION IF EXISTS Training.fnCalculateScore
--DROP TABLE IF EXISTS Training.UserScore
DROP SCHEMA IF EXISTS Training
GO

CREATE SCHEMA Training
GO

/* CREATE SCHEMA AND TABLE */
--DROP TABLE IF EXISTS Training.UserScore
CREATE TABLE Training.UserScore
(
	UserID INT NOT NULL
  , DisplayName NVARCHAR(40) NOT NULL
  , UpVotes INT NOT NULL
  , DownVotes INT NOT NULL
  , Views INT NOT NULL
  , AboutMe NVARCHAR(MAX)
  , Score INT
  , CONSTRAINT PK_LetterConversion PRIMARY KEY CLUSTERED (UserID ASC)
)
GO

/* CREATE FUNCTIONS */
--DROP FUNCTION IF EXISTS Training.fnCalculateScore
CREATE FUNCTION Training.fnCalculateScore(@UserID INT, @ScoreType CHAR(1) = 'U') RETURNS INT
AS
BEGIN
	DECLARE @Score INT
		  , @PostScore INT
		  , @DisplayNameLength INT
		  , @AboutMeLength INT

	SELECT @PostScore = ( (UpVotes - DownVotes) * Views)
	  FROM dbo.Users
	 WHERE Id = @UserID

	SET @Score = CASE WHEN @ScoreType = 'U' THEN @PostScore
					  ELSE NULL
					  END

	RETURN @Score
END
GO

/* CREATE PROCEDURE */
--DROP PROCEDURE IF EXISTS Training.spPopulateScores
CREATE PROCEDURE Training.spPopulateScores(@DisplayName NVARCHAR(40), @Append CHAR(1) = 'Y')
AS
BEGIN
	SET NOCOUNT ON

	IF @Append <> 'Y'
    BEGIN
		TRUNCATE TABLE Training.UserScore
	END
	ELSE
	BEGIN
		DELETE US
		  FROM Training.UserScore AS US
		  JOIN dbo.Users AS U ON U.Id = US.UserID
		 WHERE U.DisplayName LIKE CONCAT('%',@DisplayName,'%')
	END

	INSERT INTO Training.UserScore( UserID
								  , DisplayName
								  , UpVotes
								  , DownVotes
								  , Views
								  , AboutMe
								  , Score
								  )
	SELECT Id
		 , DisplayName
		 , UpVotes
		 , DownVotes
		 , Views
		 , AboutMe
		 , Training.fnCalculateScore(Id, Default)
	  FROM dbo.Users
	 WHERE UPPER(DisplayName) LIKE CONCAT('%',UPPER(@DisplayName),'%')

    UPDATE Training.UserScore
       SET DisplayName = LOWER(DisplayName)

    UPDATE US
       SET US.DisplayName = UPPER(US.DisplayName)
      FROM Training.UserScore AS US

	SET NOCOUNT OFF
END
GO

/* Execute Objects */
SELECT * FROM Training.UserScore
EXEC Training.spPopulateScores 'TOOLE'