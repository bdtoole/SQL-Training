;WITH [1] AS(SELECT [l].Id [1], [l].DisplayName [l] FROM Users [l] WHERE [l].DisplayName LIKE '%toole%')
, [l] AS(SELECT [1].Id [1], [1].DisplayName [l] FROM Users [1] WHERE [1].DisplayName LIKE '%eric fr%')
SELECT [1][0],[l][O] FROM [1] UNION SELECT [1],[l] FROM [l] ORDER BY 2,1