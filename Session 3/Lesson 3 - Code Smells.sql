/* CODE SMELLS */

--Not referencing schema when referencing object
SELECT * FROM LinkTypes

--Incorrect data types (VARCHAR(1) or VARCHAR(2), VARCHAR without explicit length)
DECLARE @StateCode VARCHAR(2) = 'OR'
SELECT @StateCode

--Implicit conversion
DECLARE @Five INT = 5
SELECT CONCAT('Converted: ',@Five)

--SELECT *
--Ambiguous inserts
DROP TABLE IF EXISTS #PostTypes
CREATE TABLE #PostTypes
(
    ID INT NOT NULL
  , Type NVARCHAR(50) NOT NULL
)
GO

INSERT
  INTO #PostTypes
SELECT *
  FROM dbo.PostTypes

--ORDER BY with constants
SELECT *
  FROM dbo.PostTypes
 ORDER BY 2
  
--Non-descriptive aliases or overly long aliases
SELECT TOP 10 *
  FROM dbo.PostLinks AS T1
  JOIN dbo.LinkTypes AS T2 ON T2.Id = T1.LinkTypeId

SELECT TOP 10 *
  FROM dbo.PostLinks AS TableAliasLongerThanTableName
  JOIN dbo.LinkTypes AS TableAliasLongerThanTableNameAgain ON TableAliasLongerThanTableNameAgain.Id = TableAliasLongerThanTableName.LinkTypeId

--Unnecessary square brackets
SELECT [Id]
     , [DisplayName]
  FROM [dbo].[Users]
 WHERE [DisplayName] LIKE '%Toole%'

--Naming conventions with prefixes
--Not naming constraints/keys
--Nested views
--SELECT DISTINCT