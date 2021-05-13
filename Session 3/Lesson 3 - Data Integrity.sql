/* INDEXES */

--CLUSTERED INDEX - Logical ordering of rows in a table
--NONCLUSTERED INDEX - Separate structure that points to table to quickly locate rows

--Table without Clustered Index? - Heap!
GO

/* DATA INTEGRITY */
--Ways to enforce Data Integrity?
--KEYS
    --PRIMARY KEY (Surrogate, Composite)
    --FOREIGN KEY
--UNIQUE
--DEFAULT
--NULL/NOT NULL
--CHECK
--COMPUTED COLUMNS

DROP TABLE IF EXISTS Training.UserPostCombined
GO
CREATE TABLE Training.UserPostCombined
(
    OwnerId INT NOT NULL
  , AboutMe NVARCHAR(MAX)
  --, AboutMe NVARCHAR(MAX) CONSTRAINT UC_UserPostCombined_AboutMe UNIQUE
  , CreationDate DATETIME NOT NULL
  --, CreationDate DATETIME NOT NULL CONSTRAINT CK_UserPostCombined_CreationDate CHECK(YEAR(CreationDate) > 2008)
  , DisplayName NVARCHAR(40) NOT NULL
  , DownVotes INT NOT NULL
  , Location NVARCHAR(100)
  , Reputation INT NOT NULL
  , UpVotes INT NOT NULL
  , Views INT NOT NULL
  , WebsiteUrl NVARCHAR(200)
  --, WebsiteUrl NVARCHAR(200) CONSTRAINT UC_UserPostCombined_WebsiteUrl UNIQUE
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
  , Tags NVARCHAR(150)
  --, Tags NVARCHAR(150) CONSTRAINT DF_UserPostCombined_Tags DEFAULT('')
  , Title NVARCHAR(250)
  , ViewCount INT NOT NULL
  --, NetVotes AS UpVotes - DownVotes PERSISTED 
  , CONSTRAINT PK_UserPostCombined PRIMARY KEY CLUSTERED (OwnerId ASC, PostId ASC)
  , CONSTRAINT FK_UserPostCombined_OwnerId FOREIGN KEY (OwnerId) REFERENCES dbo.Users(Id)
  , CONSTRAINT FK_UserPostCombined_PostId FOREIGN KEY (PostId) REFERENCES dbo.Posts(Id)
)
GO

ALTER TABLE Training.UserPostCombined DROP CONSTRAINT PK_UserPostCombined
ALTER TABLE Training.UserPostCombined ADD CONSTRAINT PK_UserPostCombined_Alter PRIMARY KEY CLUSTERED (OwnerId ASC, PostId ASC)
ALTER TABLE Training.UserPostCombined DROP CONSTRAINT FK_UserPostCombined_OwnerId
ALTER TABLE Training.UserPostCombined ADD CONSTRAINT FK_UserPostCombined_OwnerId_Alter FOREIGN KEY(OwnerId) REFERENCES dbo.Users(Id)
ALTER TABLE Training.UserPostCombined DROP CONSTRAINT FK_UserPostCombined_PostId
ALTER TABLE Training.UserPostCombined ADD CONSTRAINT FK_UserPostCombined_PostId_Alter FOREIGN KEY(OwnerId) REFERENCES dbo.Users(Id)
GO