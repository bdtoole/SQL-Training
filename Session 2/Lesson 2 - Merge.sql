DROP TABLE IF EXISTS #Users
SELECT Id
     , DisplayName
     , Location
     , WebsiteUrl
  INTO #Users
  FROM dbo.Users
 WHERE Location LIKE '%Naperville%'
GO

DROP TABLE IF EXISTS #UsersNamedToole
SELECT Id
     , DisplayName
     , Location
     , WebsiteURL
  INTO #UsersNamedToole
  FROM dbo.Users
 WHERE DisplayName LIKE '%toole%'
GO

SELECT * FROM #Users --Target table
SELECT * FROM #UsersNamedToole --Source table

/*
 * Combine data from both tables into Target table, changing DisplayName of users that exist in both tables
 * ToDo:
 * 1. Update DisplayName of records that exist in both
 * 2. Insert data from Source table into Target table
 * 3. Delete data from Target table where not exists in Source table
 */
GO

BEGIN

    --SET IDENTITY_INSERT #Users ON

    MERGE #Users AS T--Merge Target
    USING #UsersNamedToole AS S--Using Source
       ON T.Id = S.Id
     WHEN MATCHED
          THEN UPDATE
           SET T.DisplayName = CONCAT('MATCHED: ',S.DisplayName)
     WHEN NOT MATCHED BY TARGET
          THEN INSERT( DisplayName
                     , Location
                     , WebsiteUrl
                     --, Id
                     )
               VALUES( CONCAT('INSERTED: ',S.DisplayName)
                     , S.Location
                     , S.WebsiteUrl
                     --, Id
                     )
     WHEN NOT MATCHED BY SOURCE
          THEN DELETE;

    --SET IDENTITY_INSERT #Users OFF
END
GO

SELECT * FROM #UsersNamedToole --Source table
SELECT * FROM #Users --Target table

    MERGE #Users AS T--Merge Target
    USING #UsersNamedToole AS S--Using Source
       ON T.Id = S.Id
     WHEN MATCHED AND T.Location = 'United States'
          THEN DELETE
     WHEN MATCHED AND T.Location = 'Naperville, IL'
          THEN UPDATE
           SET T.Location = CONCAT('MATCHED: ',S.Location);

SELECT * FROM #UsersNamedToole --Source table
SELECT * FROM #Users --Target table