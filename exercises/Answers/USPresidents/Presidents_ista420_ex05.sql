DROP SCHEMA IF EXISTS USA;
DROP SCHEMA IF EXISTS UpdatedPresident
GO
DROP TABLE IF EXISTS Presidents;
DROP TABLE IF EXISTS Obama
GO

CREATE SCHEMA USA;
GO
CREATE SCHEMA UpdatedPresident;
GO

CREATE TABLE Presidents
(
ID varchar(20),
Last_Name varchar (50),
First_Name varchar (50),
Middle_Name varchar (50),
Order_of_Presidency varchar (50),
Date_of_Birth varchar (50),
Date_of_Death varchar (50),
Town_or_Country_of_Birth varchar (50),
State_of_Birth varchar (50),
Home_State varchar (50),
Party_Affliliation varchar (50),
Date_Took_Office varchar (50),
Date_Left_Office varchar (50),
Assassination_Attempt varchar (50),
Assassinated varchar (50),
Religous_Affliliation varchar (50),
Image_Path varchar (50),
);

BULK INSERT dbo.Presidents FROM 'C:\Users\silco\OneDrive\Documents\USP.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

ALTER TABLE dbo.Presidents DROP COLUMN Image_Path;
GO

DELETE TOP(1) dbo.Presidents
OUTPUT deleted.*

INSERT INTO dbo.Presidents
(
inserted.ID,
inserted.Last_Name,
inserted.First_Name,
inserted.Middle_Name,
inserted.Order_of_Presidency,
inserted.Date_of_Birth,
inserted.Date_of_Death,
inserted.Town_or_Country_of_Birth,
inserted.State_of_Birth,
inserted.Home_State,
inserted.Party_Affliliation,
inserted.Date_Took_Office,
inserted.Date_Left_Office,
inserted.Assassination_Attempt,
inserted.Assassinated,
inserted.Religous_Affliliation
)
VALUES
(
45,
'Trump',
'Donald',
'John',
45,
'6/14/1946',
NULL,
'Queens',
'New York',
'New York City',
'Republican',
'1/20/2017',
NULL,
NULL,
NULL,
'Unaffiliated'
);


UPDATE dbo.Presidents
SET Date_Left_Office = '1/20/2017'
WHERE Last_Name = 'Obama';



SELECT 
home_state, Party_Affliliation, COUNT(Party_Affliliation) as numberOfParties
From Presidents
group by Home_State, Party_Affliliation
Order by Home_State;


SELECT ID, Last_Name, First_Name, DATEDIFF(day, (SELECT CONVERT(DATE, Date_Took_Office, 101)), (SELECT CONVERT(DATE, Date_Left_Office, 101))) as DaysInOffice
From Presidents;


SELECT ID, Last_Name, First_Name, DATEDIFF(year, (SELECT CONVERT(DATE, Date_of_Birth, 101)), (SELECT CONVERT(DATE, Date_Took_Office, 101))) as AgeTookOffice
From Presidents;

SELECT  
Religous_Affliliation,
COUNT(Religous_Affliliation) as numberOfReligions
From Presidents
group by Religous_Affliliation

INTERSECT

SELECT 
Party_Affliliation,
COUNT(Party_Affliliation) as numberOfParties
From Presidents
GROUP BY Party_Affliliation




SELECT *
FROM Presidents;
GO