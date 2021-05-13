/*
    1. Create new database from scratch
    2. Export data from StackOverflow2010
    3. Import data into table that doesn't exist
    4. Import data into table that already exists
    5. Backup database
    6. Drop tables
    7. Restore database from backup
 */

USE TooleTraining
GO

SELECT U.Id AS UserId
     , CONCAT('"',U.DisplayName,'"') AS QuotedDisplayName
     , U.AboutMe
     , U.CreationDate
     , P.Title
     , CAST(U.Id * 0.33 AS DECIMAL(18,2)) AS DecimalValue
  FROM StackOverflow2010.dbo.Users AS U
  JOIN StackOverflow2010.dbo.Posts AS P ON P.OwnerUserId = U.Id
 WHERE P.Tags LIKE '%SQL%'
GO

--SELECT * FROM dbo.DataImport_New

DROP TABLE IF EXISTS dbo.DataImport
CREATE TABLE dbo.DataImport
(
    UserId            INT NOT NULL
  , QuotedDisplayName NVARCHAR(40) NOT NULL
  , AboutMe           NVARCHAR(MAX)
  , CreationDate      DATETIME NOT NULL
  , Title             NVARCHAR(250)
  , DecimalValue      DECIMAL(18,2)
)