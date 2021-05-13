DROP TABLE IF EXISTS Training.UserPostCombined
GO
CREATE TABLE Training.UserPostCombined
(
    OwnerId INT NOT NULL
  , AboutMe NVARCHAR(MAX)
  , CreationDate DATETIME NOT NULL CONSTRAINT CK_UserPostCombined_CreationDate CHECK(YEAR(CreationDate) > 2008)
  , DisplayName NVARCHAR(40) NOT NULL
  , DownVotes INT NOT NULL
  , Location NVARCHAR(100)
  , Reputation INT NOT NULL
  , UpVotes INT NOT NULL
  , Views INT NOT NULL
  , WebsiteUrl NVARCHAR(200) CONSTRAINT UC_UserPostCombined_WebsiteUrl UNIQUE
  , PostId INT NOT NULL
  , AcceptedAnswerId INT
  , AnswerCount INT
  , Body NVARCHAR(MAX)
  , CommentCount INT
  , PostDate DATETIME NOT NULL
  , FavoriteCount INT
  , ParentId INT
  , PostType NVARCHAR(50) NOT NULL
  , Score INT NOT NULL
  , Tags NVARCHAR(150) CONSTRAINT DF_UserPostCombined_Tags DEFAULT('')
  , Title NVARCHAR(250)
  , ViewCount INT NOT NULL
  , NetVotes AS UpVotes - DownVotes PERSISTED 
  , CONSTRAINT PK_UserPostCombined PRIMARY KEY CLUSTERED (OwnerId ASC, PostId ASC)
  , CONSTRAINT FK_UserPostCombined_OwnerId FOREIGN KEY (OwnerId) REFERENCES dbo.Users(Id)
  , CONSTRAINT FK_UserPostCombined_PostId FOREIGN KEY (PostId) REFERENCES dbo.Posts(Id)
)
GO

/*
    Make any changes necessary to the INSERT statement below so it properly inserts into the above table
    Do Not make any changes to the table definition itself
 */
INSERT INTO Training.UserPostCombined
(
    OwnerId
  , AboutMe
  , CreationDate
  , DisplayName
  , DownVotes
  , Location
  , Reputation
  , UpVotes
  , Views
  , WebsiteUrl
  , PostId
  , AcceptedAnswerId
  , AnswerCount
  , Body
  , CommentCount
  , PostDate
  , FavoriteCount
  , ParentId
  , PostType
  , Score
  , Tags
  , Title
  , ViewCount
  , NetVotes
)
SELECT U.Id AS OwnerID
     , U.AboutMe
     , U.CreationDate
     , U.DisplayName
     , U.DownVotes
     , U.Location
     , U.Reputation
     , U.UpVotes
     , U.Views
     , U.WebsiteUrl
     , P.Id AS PostID
     , P.AcceptedAnswerId
     , P.AnswerCount
     , P.Body
     , P.CommentCount
     , P.CreationDate AS PostDate
     , P.FavoriteCount
     , P.ParentId
     , P.PostTypeId
     , P.Score
     , P.Tags
     , P.Title
     , P.ViewCount
     , UpVotes - DownVotes
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.Id = U.Id --Keep this join as-is, even though we know the data is incorrect

/*
    Bonus:
    Make the below insert properly load data into the table without changing values being inserted or removing the constraint
 */
INSERT INTO Training.UserPostCombined
(
    OwnerId
  , AboutMe
  , CreationDate
  , DisplayName
  , DownVotes
  , Location
  , Reputation
  , UpVotes
  , Views
  , WebsiteUrl
  , PostId
  , AcceptedAnswerId
  , AnswerCount
  , Body
  , CommentCount
  , PostDate
  , FavoriteCount
  , ParentId
  , PostType
  , Score
  , Tags
  , Title
  , ViewCount
)
SELECT '100000000' AS OwnerID
     , U.AboutMe
     , U.CreationDate
     , U.DisplayName
     , U.DownVotes
     , U.Location
     , U.Reputation
     , U.UpVotes
     , U.Views
     , U.WebsiteUrl
     , P.Id AS PostID
     , P.AcceptedAnswerId
     , P.AnswerCount
     , P.Body
     , P.CommentCount
     , P.CreationDate AS PostDate
     , P.FavoriteCount
     , P.ParentId
     , P.PostTypeId
     , P.Score
     , P.Tags
     , P.Title
     , P.ViewCount
  FROM dbo.Users AS U
  JOIN dbo.Posts AS P ON P.OwnerUserId = U.Id
 WHERE U.Id = '10251164'