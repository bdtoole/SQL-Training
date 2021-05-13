SET STATISTICS IO, TIME OFF

SELECT Id
     , CreationDate
     , DisplayName
     , Age
--SELECT *
  FROM dbo.Users
 WHERE CreationDate > '2009/01/01'
 --WHERE CreationDate > '1800/01/01'
 ORDER BY CreationDate ASC

SELECT Id
     , CreationDate
     , DisplayName
     , Age
  FROM dbo.Users
 WHERE CreationDate > '2209/01/01'
 ORDER BY CreationDate ASC

--DROP INDEX IF EXISTS IX_Users_DisplayName ON dbo.Users
--CREATE INDEX IX_Users_DisplayName ON dbo.Users(DisplayName)
--DBCC SHOW_STATISTICS('dbo.Users','IX_Users_DisplayName')

DROP INDEX IF EXISTS IX_Users_LastAccessDate_Id ON dbo.Users
CREATE INDEX IX_Users_LastAccessDate_Id ON dbo.Users(LastAccessDate, Id)

SELECT Id
     , DisplayName
     , Age
     , LastAccessDate
  FROM dbo.Users
 WHERE LastAccessDate BETWEEN '2018-08-27' AND '2018-08-28'
 ORDER BY LastAccessDate ASC

SELECT Id
     , DisplayName
     , Age
     , LastAccessDate
  FROM dbo.Users
 WHERE CAST(LastAccessDate AS DATE) = '2018-08-27'
 --WHERE LastAccessDate = '2018-08-27'
 ORDER BY LastAccessDate ASC