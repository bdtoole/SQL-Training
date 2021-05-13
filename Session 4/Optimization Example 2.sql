/*
    Old logic - lots of steps
 */
DROP TABLE IF EXISTS #UpVotes
SELECT Id
     , DisplayName
     , 'UpVotes' AS SourceTable
  INTO #UpVotes
  FROM dbo.Users
 WHERE UpVotes > 10000

DROP TABLE IF EXISTS #DownVotes
SELECT Id
     , DisplayName
     , 'DownVotes' AS SourceTable
  INTO #DownVotes
  FROM dbo.Users
 WHERE DownVotes > 10000

DROP TABLE IF EXISTS #OldDestination
GO
CREATE TABLE #OldDestination
(
    Id INT IDENTITY
  , UserId INT
  , DisplayName NVARCHAR(40)
  , SourceTable VARCHAR(10)
)

INSERT INTO #OldDestination (UserId, DisplayName, SourceTable)
SELECT Id
     , DisplayName
     , SourceTable
  FROM #UpVotes

INSERT INTO #OldDestination (UserId, DisplayName, SourceTable)
SELECT Id
     , DisplayName
     , SourceTable
  FROM #DownVotes

DROP TABLE IF EXISTS #InBothSources
SELECT UserId
     , DisplayName
     , MAX(Id) AS MaxId
  INTO #InBothSources
  FROM #OldDestination
 GROUP BY UserId
        , DisplayName
   HAVING COUNT(*) > 1

DELETE D
  FROM #OldDestination AS D
  JOIN #InBothSources AS I ON I.UserId = D.UserId
                          AND D.Id < I.MaxId

UPDATE D
   SET D.SourceTable = 'UpAndDown'
  FROM #OldDestination AS D
  JOIN #InBothSources AS I ON I.MaxId = D.Id

SELECT *
  FROM #OldDestination
 --WHERE SourceTable = 'UpAndDown' --15
 --WHERE SourceTable = 'UpVotes' --97
 --WHERE SourceTable = 'DownVotes' --44
GO

/*
    New Logic - simplified
 */
DROP TABLE IF EXISTS #NewDestination
GO
;WITH UpVotes AS
(
SELECT Id
     , DisplayName
     , 'UpVotes' AS SourceTable
  FROM dbo.Users
 WHERE UpVotes > 10000
)
, DownVotes AS
(
SELECT Id
     , DisplayName
     , 'DownVotes' AS SourceTable
  FROM dbo.Users
 WHERE DownVotes > 10000
)
SELECT COALESCE(UV.Id,DV.Id) AS UserId
     , COALESCE(UV.DisplayName,DV.DisplayName) AS DisplayName
     , CASE WHEN UV.Id IS NULL THEN DV.SourceTable
            WHEN DV.Id IS NULL THEN UV.SourceTable
            ELSE 'UpAndDown'
             END AS SourceTable
  INTO #NewDestination
  FROM UpVotes AS UV
  FULL JOIN DownVotes AS DV ON DV.Id = UV.Id

SELECT *
  FROM #NewDestination
 --WHERE SourceTable = 'UpAndDown' --15
 --WHERE SourceTable = 'UpVotes' --97
 --WHERE SourceTable = 'DownVotes' --44