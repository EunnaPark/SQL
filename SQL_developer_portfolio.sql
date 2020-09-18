USE EXAM
GO
----------------------------------------------------------------------------------------------------------
--Totally, original tabls are so mess, they are include same primary key in whole tabls, and the data cannot identify to keep unique,
--As well as, all tables do not have any common information, so they do not relate each table which is required ForiegnKey
--Therefore, I will re-design to improve table structure.
----------------------------------------------------------------------------------------------------------

-- 1) the columns which have different purposes was combined, so I devided to 2 tables. 
-- new table will be composed BusinessEntityId, NationalID, OrganizationNd, OrganizationLevel, terrotiryId.
-- Also, BusinessEntityId is in all table as PK, and it is duplicated. 
-- As well as, BirthDate, MaritalStatus, Gender, these columns are close with person information
--, so I will move these information to person table which is managed personal information.
--SELECT * FROM [HumanResources].[Employee]
--GO

--2)Email table will connect with person table as parents level of person.
--SELECT * FROM [Person].[EmailAddress]
--GO

--3)Person table will be re-designed for person information.
--SELECT * FROM [Person].[Person]
--GO

--4)Sales Person table will be used changed purpose which is personal sales history.
--SELECT * FROM [Sales].[SalesPerson]
--GO


/* -------------------------- BACK UP---------------------------------------
SELECT * INTO [HumanResources].[Employee_bk] FROM [HumanResources].[Employee]
GO
SELECT * INTO [Person].[EmailAddress_bk] FROM [Person].[EmailAddress]
GO
SELECT * INTO [Person].[Person_bk] FROM [Person].[Person]
GO
SELECT * INTO [Sales].[SalesPerson_bk] FROM [Sales].[SalesPerson]
GO----------------------------------------------------------------------------*/

/* -----------------------drop original table-----------------------------------
--DROP VIEW Sales.view_person_sales_performance


/*------------------------------------------- DROP FK -------------------------------------------------
ALTER TABLE [Person].[Person]
DROP CONSTRAINT [FK_Person_EmailAddress_EmailAddressID]
GO
ALTER TABLE [HumanResources].[Employee]
DROP CONSTRAINT [FK_Employee_BusinessEntity_BusinessEntityID]
GO
ALTER TABLE [HumanResources].[Employee]
DROP CONSTRAINT [FK_Employee_Person_PersonID]
GO
ALTER TABLE [Sales].[SalesPerson]
DROP CONSTRAINT [FK_SalesPerson_Employee_LoginId]
------------------------------------------------ FINISH DROP FK --------------------------------*/

------------------- DELETE DATA--------------------------------
DELETE FROM [Person].[EmailAddress]
DELETE FROM [HumanResources].[Employee]
DELETE FROM [Person].[Person]
DELETE FROM [Sales].[SalesPerson]
DELETE FROM [HumanResources].[BusinessEntity]
----------------------------------------------------------------

TRUNCATE TABLE [Person].[Person];
TRUNCATE TABLE [Person].[EmailAddress];
TRUNCATE TABLE [HumanResources].[BusinessEntity];
TRUNCATE TABLE [HumanResources].[Employee];
TRUNCATE TABLE [Sales].[SalesPerson];
GO
DROP TABLE [Person].[Person]
DROP TABLE [Person].[EmailAddress]
DROP TABLE [Sales].[SalesPerson]
DROP TABLE [HumanResources].[BusinessEntity]
DROP TABLE [HumanResources].[Employee]
GO
-----------------------------------------------------------------------------*/

---------------------------------------CREATE ----------------------------------------------------------------
--Create new table for business information
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HumanResources].[BusinessEntity](
	[BusinessEntityID] [int] NOT NULL,     --PK
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[TerritoryID] [int] NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel]  AS ([OrganizationNode].[GetLevel]()),
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BusinessEntity_BusinessEntityID] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--Modify employee table 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HumanResources].[Employee](  --name change
	--[employeeId] [int] NOT NULL IDENTITY(1000,1),	-- PK
	[LoginID] [nvarchar](256) NOT NULL,	-- PK
	[BusinessEntityID] [int] NOT NULL,	-- FK
	[PersonID] [int] NOT NULL,		    -- FK
	[JobTitle] [nvarchar](50) NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] [dbo].[Flag] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Employee_LoginID] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--Motify EmailAddress table 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[EmailAddress](  --name change
	[EmailAddressID] [int] IDENTITY(1,1) NOT NULL, --PK to be parent
	[EmailAddress] [nvarchar](50) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EmailAddress_EmailAddressID] PRIMARY KEY CLUSTERED 
(
	[EmailAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--Motify person table 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Person](  --name change
	[PersonID] [int] NOT NULL,    --PK
	[PersonType] [nchar](2) NOT NULL,
	[NameStyle] [dbo].[NameStyle] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailAddressID][int] NOT NULL,      -- add from emailaddress table
	[BirthDate] [date] NOT NULL,		 -- add from employee table
	[MaritalStatus] [nchar](1) NOT NULL, -- add from employee table
	[Gender] [nchar](1) NOT NULL,	     -- add from employee table
	[EmailPromotion] [int] NOT NULL,
	[AdditionalContactInfo] [xml](CONTENT [Person].[AdditionalContactInfoSchemaCollection]) NULL,
	[Demographics] [xml](CONTENT [Person].[IndividualSurveySchemaCollection]) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Person_PersonID] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
--Motify personSales table 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sales].[SalesPerson](
	[SalesID][int] NOT NULL,			 --COMPOSIT KEY PK
	[LoginID] [nvarchar](256) NOT NULL, 	
	[SalesQuota] [money] NULL,
	[Bonus] [money] NOT NULL,
	[CommissionPct] [smallmoney] NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SalesPerson_BusinessEntityID] PRIMARY KEY CLUSTERED 
(
	[SalesID] ASC,
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
---------------------------------------FINISH CREATE TABLE----------------------------------------------------

---------------------------------------START INSERT ----------------------------------------------------------
-- insert data into [HumanResources].[BusinessEntity] 
-- dealing with hierarchyid and computed column
INSERT INTO [HumanResources].[BusinessEntity] values(1,	N'295847284',	NULL,	 NULL,		 GETDATE());
INSERT INTO [HumanResources].[BusinessEntity] values(2,	N'245797967',	NULL,    N'/1/',	 GETDATE());
INSERT INTO [HumanResources].[BusinessEntity] values(3,	N'509647174',	NULL,    N'/1/1/',	 GETDATE());
INSERT INTO [HumanResources].[BusinessEntity] values(4,	N'112457891',	NULL,    N'/1/1/1/', GETDATE());
GO

-- insert data into [Person].[EmailAddress]
SET IDENTITY_INSERT [Person].[EmailAddress] ON;
INSERT [Person].[EmailAddress] ([EmailAddressID], [EmailAddress], [rowguid], [ModifiedDate]) VALUES (1, NULL, N'8a1901e4-671b-431a-871c-eadb2942e9ee', GETDATE());
INSERT [Person].[EmailAddress] ([EmailAddressID], [EmailAddress], [rowguid], [ModifiedDate]) VALUES (2, N'terri0@poorly_db_design_Co.com', N'b5ff9efd-72a2-4f87-830b-f338fdd4d162', GETDATE());
INSERT [Person].[EmailAddress] ([EmailAddressID], [EmailAddress], [rowguid], [ModifiedDate]) VALUES (3, N'roberto0@poorly_db_design_Co.com', N'c8a51084-1c03-4c58-a8b3-55854ae7c499', GETDATE());
INSERT [Person].[EmailAddress] ([EmailAddressID], [EmailAddress], [rowguid], [ModifiedDate]) VALUES (4, N'rob0@poorly_db_design_Co.com', N'17703ed1-0031-4b4a-afd2-77487a556b3b', GETDATE());
SET IDENTITY_INSERT [Person].[EmailAddress] OFF; 
GO

--insert data into [Person].[SalesPerson]
--SET IDENTITY_INSERT [Sales].[SalesPerson] ON;
INSERT [Sales].[SalesPerson] ( [SalesID], [loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]) 
VALUES ( 1, 'ken0', NULL, 0.0000, 0.0000, 559697.5639, 0.0000, N'48754992-9ee0-4c0e-8c94-9451604e3e02', CAST(N'2010-12-28T00:00:00.000' AS DateTime));

INSERT [Sales].[SalesPerson] ([SalesID], [loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate])
VALUES ( 2, 'ken0', 300000.0000, 4100.0000, 0.0120, 3763178.1787, 1750406.4785, N'1e0a7274-3064-4f58-88ee-4c6586c87169', CAST(N'2011-05-24T00:00:00.000' AS DateTime));

INSERT [Sales].[SalesPerson] ( [SalesID], [loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]) 
VALUES ( 3,  'ken0', 250000.0000, 3500.0000, 0.0120, 1573012.9383, 1371635.3158, N'6bac15b2-8ffb-45a9-b6d5-040e16c2073f', CAST(N'2011-05-24T00:00:00.000' AS DateTime));

INSERT [Sales].[SalesPerson] ( [SalesID], [loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]) 
VALUES ( 4, 'roberto0', 300000.0000, 3900.0000, 0.0190, 1576562.1966, 0.0000, N'ac94ec04-a2dc-43e3-8654-dd0c546abc17', CAST(N'2012-09-23T00:00:00.000' AS DateTime));

INSERT [Sales].[SalesPerson] ( [SalesID], [loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]) 
VALUES ( 5, 'terri0', NULL, 0.0000, 0.0000, 172524.4512, 0.0000, N'cfdbef27-b1f7-4a56-a878-0221c73bae67', CAST(N'2013-03-07T00:00:00.000' AS DateTime));

INSERT [Sales].[SalesPerson] ( [SalesID],[loginId], [SalesQuota], [Bonus], [CommissionPct], [SalesYTD], [SalesLastYear], [rowguid], [ModifiedDate]) 
VALUES ( 6, 'rob0', NULL, 0.0000, 0.0000, 519905.9320, 0.0000, N'1dd1f689-df74-4149-8600-59555eef154b', CAST(N'2012-04-09T00:00:00.000' AS DateTime));
--SET IDENTITY_INSERT [Sales].[SalesPerson] OFF;
GO

--insert data into [Person].[Person]
--SET IDENTITY_INSERT [Person].[Person] ON;
INSERT [Person].[Person] ([PersonID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddressID], [BirthDate], [MaritalStatus], [Gender], [EmailPromotion], [AdditionalContactInfo], [Demographics], [rowguid], [ModifiedDate]) 
VALUES (1, N'EM', 0, NULL, N'Ovidiu', N'V', N'Cracium', NULL, 1, '1969-01-29', N'S', N'M', 0, NULL, N'<IndividualSurvey xmlns="http://schemas.poorly_db_design_Co.com/sqlserver/2004/07/poorly_db_design_Co/IndividualSurvey"><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>', N'd2cc2577-ef6b-4408-bd8c-747337fe5645', GETDATE());

INSERT [Person].[Person] ([PersonID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddressID], [BirthDate], [MaritalStatus], [Gender], [EmailPromotion], [AdditionalContactInfo], [Demographics], [rowguid], [ModifiedDate]) 
VALUES (2, N'EM', 0, NULL, N'Thierry', N'B', N'D''Hers', NULL, 2, '1971-08-01', N'S', N'F', 2, NULL, N'<IndividualSurvey xmlns="http://schemas.poorly_db_design_Co.com/sqlserver/2004/07/poorly_db_design_Co/IndividualSurvey"><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>', N'fa263c7f-600d-4e89-8dcd-0978f3530f5f', GETDATE());

INSERT [Person].[Person] ([PersonID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddressID], [BirthDate], [MaritalStatus], [Gender], [EmailPromotion], [AdditionalContactInfo], [Demographics], [rowguid], [ModifiedDate]) 
VALUES (3, N'EM', 0, N'Ms.', N'Janice', N'M', N'Galvin', NULL, 3, '1974-11-12', N'M', N'M', 2, NULL, N'<IndividualSurvey xmlns="http://schemas.poorly_db_design_Co.com/sqlserver/2004/07/poorly_db_design_Co/IndividualSurvey"><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>', N'34eb99e0-7042-4dc1-a2fd-bda290ff0e07', GETDATE());

INSERT [Person].[Person] ([PersonID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddressID], [BirthDate], [MaritalStatus], [Gender], [EmailPromotion], [AdditionalContactInfo], [Demographics], [rowguid], [ModifiedDate]) 
VALUES (4, N'EM', 0, NULL, N'Michael', N'I', N'Sullivan', NULL, 4, '1974-12-23', N'S', N'M', 2, NULL, N'<IndividualSurvey xmlns="http://schemas.poorly_db_design_Co.com/sqlserver/2004/07/poorly_db_design_Co/IndividualSurvey"><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>', N'9a7501de-5caf-4700-ab07-cc81102bb696',GETDATE());
--SET IDENTITY_INSERT [Person].[Person] OFF;
GO
-- insert data into [HumanResources].[Employee] 
INSERT INTO [HumanResources].[Employee] 
SELECT REPLACE([LoginID],'poorly_db_design_Co\','')
	, [BusinessEntityID]
	, 0
	, [JobTitle]
	, [HireDate]
	, [SalariedFlag]
	, [VacationHours]
	, [SickLeaveHours]
	, [CurrentFlag]
	, [rowguid]
	, GETDATE()
  FROM [HumanResources].[Employee_bk]
GO 
---------------------------------------FINISH INSERT ----------------------------------------------------------

-------------------------------------- Initialize data---------------------------------------------------------
UPDATE [HumanResources].[Employee] SET [PersonID] = 1 WHERE [LoginID]= 'ken0'
UPDATE [HumanResources].[Employee] SET [PersonID] = 2 WHERE [LoginID]= 'roberto0'
UPDATE [HumanResources].[Employee] SET [PersonID] = 3 WHERE [LoginID]= 'terri0'
UPDATE [HumanResources].[Employee] SET [PersonID] = 4 WHERE [LoginID]= 'rob0'
GO
-------------------------------------- FINISH Initialize data---------------------------------------------------------

-------------------------------------- set up relation between tables-------------------------------------------------
-- ADD FOREIGN KEY BusinessEntity and Employee
ALTER TABLE [HumanResources].[Employee]
--DROP CONSTRAINT [FK_Employee_BusinessEntity_BusinessEntityID]
ADD CONSTRAINT [FK_Employee_BusinessEntity_BusinessEntityID] FOREIGN KEY([BusinessEntityID])
    REFERENCES [HumanResources].[BusinessEntity]([BusinessEntityID])
GO
-- ADD FOREIGN KEY Person and Employee
ALTER TABLE [HumanResources].[Employee]
--DROP CONSTRAINT [FK_Employee_Person_PersonID]
ADD CONSTRAINT [FK_Employee_Person_PersonID] FOREIGN KEY([PersonID])
    REFERENCES [Person].[Person]([PersonID])
GO
-- ADD FOREIGN KEY EmailAddress and person
ALTER TABLE [Person].[Person]
--DROP CONSTRAINT [FK_Person_EmailAddress_EmailAddressID]
ADD CONSTRAINT [FK_Person_EmailAddress_EmailAddressID] FOREIGN KEY([EmailAddressID])
    REFERENCES [Person].[EmailAddress]([EmailAddressID])
GO
-- ADD FOREIGN KEY SalesPerson and Employee
ALTER TABLE [Sales].[SalesPerson]
--DROP CONSTRAINT [FK_SalesPerson_Employee_LoginId]
ADD CONSTRAINT [FK_SalesPerson_Employee_LoginId] FOREIGN KEY([LoginID])
	REFERENCES [HumanResources].[Employee]([LoginID])
GO
-------------------------------------- finishi to set up relation between tables--------------------------------

-----------------------------CHECK FK-----------------------------
SELECT	OBJECT_NAME(referenced_object_id) AS [PARENT],
		COUNT (OBJECT_NAME(referenced_object_id)) AS [HOW MANY CHILDREN] 
FROM sys.foreign_key_columns
GROUP BY OBJECT_NAME(referenced_object_id)
ORDER BY COUNT (OBJECT_NAME(referenced_object_id)) DESC;

SELECT OBJECT_NAME(constraint_object_id) AS [CONSTRAINT NAME],
OBJECT_NAME(parent_object_id) AS CHILD,
OBJECT_NAME(referenced_object_id) AS PARENT
FROM sys.foreign_key_columns
GO
-----------------------------CHECK FK-----------------------------



---------START QUESTION 2 -------------------------------------------------------------------------------
--1)HIREING MANAGER REQUEST INFORMATION ABOUT PERSONAL INFORMATION INCLUDE National Id, email address, and private information
CREATE OR ALTER VIEW [Person].[view_person_private_inform] WITH ENCRYPTION
AS 
SELECT B.NationalIDNumber
     , A.LoginID
	 , c.PersonID
	 , c.FirstName+' '+c.MiddleName+' '+c.LastName AS NAME
	 , CASE WHEN c.Gender = 'M' then 'Male' ELSE 'Female' END AS SEX
	 , CASE WHEN C.MaritalStatus = 'S' THEN 'SINGLE' ELSE 'MARRIED' END AS MARRIAGE
	 , C.Birthdate
	 , D.EmailAddress
 FROM [HumanResources].[Employee] A
INNER JOIN 
      [HumanResources].[BusinessEntity] B
   ON A.BusinessEntityID = B.BusinessEntityID
INNER JOIN 
       [Person].[Person] C
   ON A.PersonID = C.PersonID
INNER JOIN 
      [Person].[EmailAddress] D
   ON C.EmailAddressID = D.EmailAddressID
GO 

select *   from [Person].[view_person_private_inform]
SELECT  OBJECT_DEFINITION(OBJECT_ID('Person.view_person_private_infor')) [THE INNER CONTENT OF THE VIEW SYNTAX];
GO
----------------------------------------------------------------------------------------------------------------------------------
--2)HIREING MANAGER WANT TO KNOW OUTCOME OF EMPLOYEES SIMPLY IN SALES PART 
--DROP VIEW Sales.view_person_sales_performance
CREATE OR ALTER VIEW Sales.view_person_sales_performance WITH SCHEMABINDING
AS
SELECT A.LoginID AS EMPLOYEE_ID
     , MAX(A.HireDate)   AS HireDate
	 , SUM(ISNULL(B.SalesQuota,0)) AS SalesQuota
	 , SUM(B.BONUS) AS BONUS
	 , AVG(B.COMMISSIONpct) AS COMMISSIONpct
	 , SUM(B.SalesLastYear) AS SalesLastYear
  FROM [HumanResources].[Employee] A
  LEFT OUTER JOIN 
      [Sales].[SalesPerson] B
	ON A.LoginID = B.LoginID
GROUP BY A.LoginID
 WITH CHECK OPTION;

GO
select * from Sales.view_person_sales_performance;
SELECT  OBJECT_DEFINITION(OBJECT_ID('Sales.view_person_sales_performancer')) [THE INNER CONTENT OF THE VIEW SYNTAX];

GO
----------------------------------------------------------------------------------------------------------------------------------
--3)HIRE MANAGER WANT TO KNOW THE COUNT OF LOWER LEVEL BUSINESS ENTITY TO DISTRIBUTE HUMAN RESOURCES
CREATE OR ALTER VIEW HumanResources.veiw_businessentity_lowerlevel WITH ENCRYPTION
AS
WITH CTE_BUSINESS AS (
   SELECT * FROM [HumanResources].[BusinessEntity] 
)
SELECT TAB.CURRENT_LEVEL_BN
     , SUM(CASE WHEN TAB.LOWER_LEVEL_BN > 0 THEN 1 ELSE 0 END) LOWER_LEVEL_BISINESS_COUNT
	 , MAX(TAB.NATIONAL_ID) AS NATIONAL_ID
 FROM(
	SELECT A.BusinessEntityID					AS CURRENT_LEVEL_BN
		 , ISNULL(B.OrganizationLevel , 0)      AS LOWER_LEVEL_BN
		 , A.NationalIDNumber                   AS NATIONAL_ID
	  FROM [HumanResources].[BusinessEntity] A 
	  LEFT OUTER JOIN CTE_BUSINESS B
		ON A.BusinessEntityID = B.OrganizationLevel) tab
 GROUP BY  TAB.CURRENT_LEVEL_BN 
 ORDER BY TAB.CURRENT_LEVEL_BN ASC
 OFFSET 0 ROWS
 WITH CHECK OPTION
GO
SELECT * FROM HumanResources.veiw_businessentity_lowerlevel
GO
----------------------------------------------------------------------------------------------------------------------------------
--4)HIRE MANAGER WANT TO CALCULATE EMPLOYEES' VACATION AND SICKLEVEHOURS WITH PAID
--IF THE VACATION INCLUDING SICKLEAVE HOURS IS SUPPOSED 480 HOURS PER 1 YEAR.
--DEVELOPER IS REQUIRED THE CALCULATED HOURS BY EACH EMPLOYEES.

CREATE OR ALTER VIEW HumanResources.veiw_vacationhours_report WITH ENCRYPTION
AS
WITH PROVIDED_HOUR AS (
	SELECT 480 AS PROVIDED_HOUR
)
	SELECT A.LoginID
	     , B.PROVIDED_HOUR
		 , A.VacationHours
		 , A.SickLeaveHours
		 , A.VacationHours + A.SickLeaveHours AS USAGE_HOUR
		 , CAST(ROUND((A.VacationHours + A.SickLeaveHours) / CAST(B.PROVIDED_HOUR AS float) * 100 ,2) AS varchar)+ '%'  AS RATIO_USAGE
	  FROM [HumanResources].[Employee] A
	     ,  PROVIDED_HOUR B
GO 
SELECT * FROM HumanResources.veiw_vacationhours_report
SELECT  OBJECT_DEFINITION(OBJECT_ID('HumanResources.veiw_vacationhours_report')) [THE INNER CONTENT OF THE VIEW SYNTAX];

GO

---------START QUESTION 3 -------------------------------------------------------------------------------
-- I have already nomalized the tables ,which are matched between email and business Entity Id, and person name
-- so, I could use only join. 
CREATE OR ALTER PROC [Person].[usp_task1] 
(
	@BusinessentityID int,
	@emailAdress varchar(50) output,
	@employeename varchar(50) Output,	
	@return_value bit Output
)
AS
BEGIN
	SELECT @emailAdress      =  C.[EmailAddress]
	     , @employeename     =  B.FirstName+' '+B.MiddleName+' '+B.LastName 
	     , @BusinessentityID =  A.BusinessEntityID
	  FROM [HumanResources].[Employee] A
     INNER JOIN [Person].[Person] B
        ON A.PersonID = B.PersonID
     INNER JOIN [Person].[EmailAddress] C
        ON B.[EmailAddressID] = C.[EmailAddressID]
	 WHERE [BusinessEntityID] = @BusinessentityID

	IF @emailAdress IS NULL OR  @BusinessentityID IS NULL
		BEGIN
			PRINT '-----------------------------------------------'
			PRINT '| invalid EMAIL address OR business entity id |'
			PRINT '-----------------------------------------------'
		
			select @return_value = 0
		END 
	ELSE 
		select @return_value = 1	
END 
GO 

BEGIN
	DECLARE @rtn_emailaddress varchar(50)
	DECLARE @rtn_name varchar(50)
	DECLARE @rtn_value bit
	
	EXEC [Person].[usp_task1] 0 , @rtn_emailaddress OUTPUT, @rtn_name OUTPUT, @rtn_value OUTPUT
	PRINT '------------------------------------------'
	PRINT '| email address>> '   + ISNULL(@rtn_emailaddress, ' ')
	PRINT '| employee name>> '   + ISNULL(@rtn_name  	,' ')
	PRINT '| return value>> '    + CAST(@rtn_value AS VARCHAR(1)) 
	PRINT '------------------------------------------'
END
GO

-- after creating procedure, check the procedure with system query
SELECT SO.name AS [ObjectName],
	   SO.Type_Desc AS [ObjectType (UDF/SP)],
	   P.parameter_id AS [ParameterID],
	   P.name AS [ParameterName],
	   TYPE_NAME(P.user_type_id) AS [ParameterDataType],
	   P.max_length AS [ParameterMaxBytes],
	   P.is_output AS [IsOutPutParameter]
   FROM sys.objects AS SO
  INNER JOIN sys.parameters AS P
     ON SO.OBJECT_ID = P.OBJECT_ID
  WHERE SO.OBJECT_ID IN ( SELECT OBJECT_ID
   FROM sys.objects
  WHERE TYPE IN ('P','FN'))
 ORDER BY  SO.name, P.parameter_id
GO

USE _EXAM
GO

---------START QUESTION 1 -------------------------------------------------------------------------------
-- IT IS SHOWN SOME INFORMATION WHICH IS EMPLOYYEE ID, AND SOLE QUANTITY, AND SOLD AMOUNT
-- ACCORDING TO CONDITION SOLD AMOUNT.
CREATE OR ALTER PROC [Sales].[PROC_EP_EmpPerfrm] 
( 
	@inAmt   int  
)
AS
BEGIN			
  SELECT C.empid 
	   , SUM(B.Quantity)  AS SOLD_QTY
	   , SUM(B.UnitPrice * B.Quantity) AS SOLD_AMOUNT 	
	FROM [Sales].[ReOrders] A
	LEFT OUTER JOIN 
	     [Sales].[ReOrderDetail] B
	  ON A.[OrderId] = B.[OrderId]
   INNER JOIN 
		 [Sales].[ReEmployees] C
	  ON A.EmployeeID = C.empid
   GROUP BY C.empid
  HAVING SUM(B.UnitPrice * B.Quantity) > @inAmt
	-- CHECK INSERTED VALUE OF VARIABLE.		
	PRINT '-----------------------------------------------'
	PRINT '| INERT @inAmt    '+ CAST(@inAmt AS VARCHAR(100)) 
	PRINT '-----------------------------------------------'	
	
END 
GO 
-- EXCUTION WITH SALES AMOUNT
BEGIN
	EXEC [Sales].[PROC_EP_EmpPerfrm]  100	
END
GO
---------END QUESTION 1 -------------------------------------------------------------------------------

---------START QUESTION 2 -------------------------------------------------------------------------------
-- TO MAKE VERTUAL TABLE, USED CROSSTAB TABLE. AND CHANGED FROM HORIZENTAL DATA TO  VERTICAL WITH PIVOT
CREATE OR ALTER PROC [Sales].[PROC_EP_MonthSaleInfo] 
AS
BEGIN	
  WITH EP_MONTH AS (
	  SELECT 1 as m, 'jan' as n UNION  
	  SELECT 2 as m, 'feb' as n UNION
	  SELECT 3 as m, 'mar' as n UNION
	  SELECT 4 as m, 'apr' as n UNION
	  SELECT 5 as m, 'may' as n UNION
	  SELECT 6 as m, 'jun' as n UNION
	  SELECT 7 as m, 'jul' as n UNION
	  SELECT 8 as m, 'aug' as n UNION
	  SELECT 9 as m, 'sep' as n UNION
	  SELECT 10 as m, 'oct' as n UNION
	  SELECT 11 as m, 'nov' as n UNION  
	  SELECT 12 as m, 'dec' as n 
  )  
SELECT *
FROM (
	  SELECT (B.Quantity) AS QTY
			, D.n AS MON
			, (SELECT E.categoryname FROM [Sales].[ReCategories] E WHERE E.categoryid = C.CategoryId) AS NM
		FROM [Sales].[ReOrders] A
		LEFT OUTER JOIN 
				[Sales].[ReOrderDetail] B
			ON A.[OrderId] = B.[OrderId]
		INNER JOIN 
				[Sales].[ReProduct] C
			ON B.ReProductId = C.ReProductId
		INNER JOIN 
				EP_MONTH D
			ON D.m = MONTH(A.OrderDate)
	    ) TAB
PIVOT 
( SUM(QTY)
    FOR MON IN ([jan],[feb],[mar],[apr],[may],[jun],[jul],[aug],[sep],[oct],[nov],[dec])
) AS PV12
END
GO 

-- EXCUTION WITH SALES AMOUNT
BEGIN
	EXEC [Sales].[PROC_EP_MonthSaleInfo]
END
GO
---------END QUESTION 2 -------------------------------------------------------------------------------

---------START QUESTION 3 -------------------------------------------------------------------------------
-- BECAUSE SIMPLY SHOWN THE CATEGORY NAME AND SUPPLIER NAME, USED INNER TABLE.
CREATE OR ALTER PROC [Sales].[PROC_EP_PurchaseProd] 
AS
BEGIN	
	SELECT Suppier
	     , ISNULL([Device],0) AS Device
		 , ISNULL([Kindle],0) AS Kindle
		 , ISNULL([Automotive],0) AS Automotive
		 , ISNULL([Beauty],0) AS Beauty
		 , ISNULL([Books],0) AS Books
		 , ISNULL([Electronics],0) AS Electronics
	FROM (
		  SELECT (SELECT E.categoryname FROM [Sales].[ReCategories] E WHERE E.categoryid = C.CategoryId) AS CATEGORYNM
			   , 1 AS QTY
			   , (SELECT D.PersonName FROM [Sales].[ReContact] D WHERE  D.ReContactId = C.SuplierId) AS Suppier
			FROM  [Sales].[ReProduct] C
		) TAB
	PIVOT 
	( MAX(QTY) --RESULT WAS SHOWN ONLY 1 VALUE, SO I CONSIDERED THAT IS NOT IMPORTANT TO CALCLULATE VALUE, AND JUST NEED TO SHOW PURCHASED HISTORY.
		FOR CATEGORYNM IN ([Device],[Kindle],[Automotive],[Beauty],[Books],[Electronics])
	) AS PV1
END
GO 

-- EXCUTION WITH SALES AMOUNT
BEGIN
	EXEC [Sales].[PROC_EP_PurchaseProd]
END
GO

---------END QUESTION 3 -------------------------------------------------------------------------------

---------START QUESTION 4 -- TRIGGER-------------------------------------------------------------------------------
-- WHILE INSERTING IF EMPLOYEE IS OVER 18 YEARS OLD, IF UNDER 18 YEARS OLD OF NEW EMPLOYEE, SHOW THE ERROR 
DROP TRIGGER IF EXISTS [Sales].[TRG_EP_EMPAGE]
GO
CREATE OR ALTER TRIGGER [Sales].[TRG_EP_EMPAGE] ON [Sales].[ReEmployees]
AFTER INSERT
AS

    BEGIN
       DECLARE @ep_empid INT, @ep_lastname VARCHAR(50)
	   DECLARE @ep_firstname  VARCHAR(50), @ep_birthdate DATETIME
	   DECLARE @AGE INT -- to calulate the age . from current date
	  
	   SELECT @ep_empid = INSERTED.empid
					, @ep_lastname = INSERTED.lastname
					, @ep_firstname = INSERTED.firstname
					, @ep_birthdate = INSERTED.birthdate
				FROM INSERTED
			
	   -- CALCULATE BRD OF NEW EMPLOYEE,
	   SELECT @AGE = FLOOR(CAST(DATEDIFF(DAY,@ep_birthdate,GETDATE()) AS INTEGER)/365.2422)
	   	
	   IF FLOOR(CAST(DATEDIFF(DAY,@ep_birthdate,GETDATE()) AS INTEGER)/365.2422) < 19  
		  BEGIN
	        PRINT '-------------------------------------------------------------------------------------'	
			PRINT '[Sales].[ReEmployees] inserting is failed. the reason is below.'
		    PRINT  CAST(@ep_empid AS VARCHAR(100))+':'+ @ep_firstname +' '+ @ep_lastname + 'is under 18'
			PRINT '-------------------------------------------------------------------------------------'

			DELETE  [Sales].[ReEmployees] WHERE empid = @ep_empid
          END	     
		ELSE
			BEGIN
				PRINT '-------------------------------------------------------------------------------------'	
				PRINT '[Sales].[ReEmployees] inserting is SUCCESS.'				
				PRINT 'NEW EMPLOYEE IS '+CAST(@AGE AS VARCHAR(10))+'----------------------------------------'	   
				PRINT '-------------------------------------------------------------------------------------'		
			END
    END   
GO

DELETE  [Sales].[ReEmployees] WHERE EMPID > 5
GO 

SET IDENTITY_INSERT [Sales].[ReEmployees] ON
INSERT INTO [Sales].[ReEmployees]([empid],[lastname],[firstname],[title],[titleofcourtesy],[birthdate],[hiredate],[ReAddressId],[phone])
VALUES(6, 'Lim', 'Haseung', 'ADULT Employee', 'BB', CONVERT(DATETIME, '2000-05-18', 102)
				      , CONVERT(DATETIME, '2020-04-22', 102), 1, '226-977-2928')


INSERT INTO [Sales].[ReEmployees]([empid],[lastname],[firstname],[title],[titleofcourtesy],[birthdate],[hiredate],[ReAddressId],[phone])
VALUES(7, 'Lim', 'Haseung', 'Toddler Employee', 'BB', CONVERT(DATETIME, '2017-05-18', 102)
				      , CONVERT(DATETIME, '2020-04-22', 102), 1, '226-977-2928')
SET IDENTITY_INSERT [Sales].[ReEmployees] OFF
GO

SELECT * FROM  [Sales].[ReEmployees]
GO 
---------END QUESTION 4 -------------------------------------------------------------------------------

---------START QUESTION 5 -- TRIGGER-------------------------------------------------------------------------------
-- TRIGGER FOR UPDATE, inserted data setup the discontinue column. also, under average rows
DROP TRIGGER IF EXISTS [Sales].TRG_EP_PRODUCTS
GO
CREATE OR ALTER TRIGGER [Sales].TRG_EP_PRODUCTS ON [Sales].[ReProduct]
AFTER INSERT
AS 
BEGIN
	DECLARE @PROD_ID INT
	PRINT '--------------------START TRIGGER-----------------------------------------------------------'
	PRINT '--------------------UPDATE INSERTED PRODUCTS------------------------------------------------'	
	SELECT @PROD_ID = inserted.[ReProductId] FROM inserted
	PRINT 'INSERTED' + CAST(@PROD_ID AS VARCHAR(100))	
	
	UPDATE [Sales].[ReProduct]
	  SET [Sales].[ReProduct].[Discontinued] = 1
	FROM inserted	
	WHERE [Sales].[ReProduct].[ReProductId] = inserted.[ReProductId];

	PRINT '--------------------UPDATE UNDER AVERAGE AMOUNT PRODUCTS-------------------------------------'
	UPDATE [Sales].[ReProduct]
	  SET [Sales].[ReProduct].[Discontinued] = 1
	WHERE [Sales].[ReProduct].[UnitPrice] < (SELECT AVG([UnitPrice]) FROM [Sales].[ReProduct])
	PRINT '--------------------END TRIGGER--------------------------------------------------------------'
	
END
GO


-- DROP FOR TEST NEW DATA
DELETE FROM  [Sales].[ReProduct] WHERE [ReProductId] = 12
GO
UPDATE  [Sales].[ReProduct] SET Discontinued = 0
GO
-- TEST NEW DATA
INSERT INTO [Sales].[ReProduct] ([ReProductId],[ReProductName],[UnitPrice])  VALUES(12,'REPRODUCT 1', (SELECT AVG([UnitPrice]) FROM [Sales].[ReProduct]))
GO
-- CHECK
SELECT * FROM [Sales].[ReProduct]
GO 

-- CHECK MY TRIGGER
SELECT  
    sys.TABLES.name,  
    sys.TRIGGERS.name,  
    sys.TRIGGER_EVENTS.type,  
    sys.TRIGGER_EVENTS.TYPE_DESC,  
    IS_FIRST,  
    IS_LAST,  
    sys.TRIGGERS.CREATE_DATE,  
    sys.TRIGGERS.MODIFY_DATE  
FROM sys.TRIGGERS  
INNER JOIN sys.TRIGGER_EVENTS  
    ON sys.TRIGGER_EVENTS.object_id = sys.TRIGGERS.object_id  
INNER JOIN sys.TABLES  
    ON sys.TABLES.object_id = sys.TRIGGERS.PARENT_ID  
ORDER BY MODIFY_DATE 


