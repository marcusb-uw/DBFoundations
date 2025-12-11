--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: Marcus Bradlee
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, and stored procedures
-- Change Log: When,Who,What
-- 2025-11-26,RRoot,Created File
--***********************************************************************************************--

--Create Database
Begin Try
	Use Master;
	
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_MBradlee')
	Begin 
		Alter Database [ITFnd130FinalDB_MBradlee] set Single_user With Rollback Immediate;
		Drop Database ITFnd130FinalDB_MBradlee;
	End
	
	Create Database ITFnd130FinalDB_MBradlee;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go

Use ITFnd130FinalDB_MBradlee;

--< Create Tables (Review Module 01)>-- 
--Create Courses Table
Create Table Courses
(
	CourseID int IDENTITY(1, 1) NOT NULL --Primary Key
	,CourseName nvarchar(100) NOT NULL --Unique
	,CourseStartDate date NULL
	,CourseEndDate date NULL
	,CourseStartTime time NULL
	,CourseEndTime time NULL
	,CourseDaysOfWeek nvarchar(100) NULL
	,CourseCurrentPrice money NULL
);

--Create Students Table
Create Table Students
(
	StudentID int IDENTITY (1, 1) NOT NULL --Primary Key
	,StudentNumber nvarchar(100) NOT NULL --Unique
	,StudentFirstName nvarchar(100) NOT NULL
	,StudentLastName nvarchar(100) NOT NULL
	,StudentEmail nvarchar(100) NOT NULL
	,StudentPhone nvarchar(100) NOT NULL
	,StudentAddress1 nvarchar(100) NOT NULL
	,StudentAddress2 nvarchar(100) NULL
	,StudentCity nvarchar(100) NOT NULL
	,StudentStateCode nvarchar(2) NOT NULL
	,StudentZipCode nvarchar(10) NOT NULL
);

--Create Enrollments Table
Create Table Enrollments
(
	EnrollmentID int IDENTITY (1, 1) NOT NULL --Primary Key
	,StudentID int NOT NULL --Foreign Key
	,CourseID int NOT NULL --Foreign Key
	,EnrollmentDateTime datetime NOT NULL
	,EnrollmentPrice money NOT NULL
);

--< Add Constraints (Review Module 02) >-- 
--Courses Constraints
Alter Table Courses
	Add Constraint pkCourseID Primary Key(CourseID)
Go
Alter Table Courses
	Add Constraint uqCourseName Unique(CourseName)
Go
Alter Table Courses
	Add Constraint ckDateContinuity Check(CourseStartDate < CourseEndDate)
Go

--Students Constraints
Alter Table Students
	Add Constraint pkStudentID Primary Key(StudentID)
Go
Alter Table Students
	Add Constraint uqStudentNumber Unique(StudentNumber)
Go

--Enrollments Constraints
Alter Table Enrollments
	Add Constraint pkEnrollmentID Primary Key(EnrollmentID)
Go
Alter Table Enrollments
	Add Constraint dfEnrollmentDateTime Default GetDate() For EnrollmentDateTime
Go
Alter Table Enrollments
	Add Constraint fkEnrollmentsToCourses 
	Foreign Key (CourseID) References Courses(CourseID)
Go
Alter Table Enrollments
	Add Constraint fkEnrollmentsToStudents 
	Foreign Key (StudentID) References Students(StudentID)
Go

--< Add Views (Review Module 03 and 06) >--
--Courses Base View
Create View vCourses With SchemaBinding
As Select
	CourseID
	,CourseName
	,CourseStartDate
	,CourseEndDate
	,CourseStartTime
	,CourseEndTime
	,CourseDaysOfWeek
	,CourseCurrentPrice
From dbo.Courses
Go

--Students Base View
Create View vStudents With SchemaBinding
As Select
	StudentID
	,StudentNumber
	,StudentFirstName
	,StudentLastName
	,StudentEmail
	,StudentPhone
	,StudentAddress1
	,StudentAddress2
	,StudentCity
	,StudentStateCode
	,StudentZipCode
From dbo.Students
Go

--Enrollments Base View
Create View vEnrollments With SchemaBinding
As Select
	EnrollmentID
	,StudentID
	,CourseID
	,EnrollmentDateTime
	,EnrollmentPrice
From dbo.Enrollments
Go

--Reporting View for All Data
Create View vMaster With SchemaBinding
As Select
	c.CourseID
	,c.CourseName
	,c.CourseStartDate
	,c.CourseEndDate
	,c.CourseStartDate As [Session]
	,c.CourseDaysOfWeek
	,c.CourseStartTime
	,c.CourseEndTime
	,c.CourseCurrentPrice
	,s.StudentID
	,s.StudentNumber
	,s.StudentFirstName
	,s.StudentLastName
	,s.StudentEmail
	,s.StudentPhone
	,s.StudentAddress1
	,s.StudentAddress2
	,s.StudentStateCode
	,s.StudentZipCode
	,e.EnrollmentDateTime
	,e.EnrollmentPrice
From dbo.vEnrollments e
Join dbo.vCourses c On e.CourseID = c.CourseID
Join dbo.vStudents s On e.StudentID = s.StudentID
Go

--< Test Tables by adding Sample Data >--  
--Courses Test Data Manual Insert
Begin Try
Begin Transaction
Insert Into Courses(
	CourseName
	,CourseStartDate
	,CourseEndDate
	,CourseStartTime
	,CourseEndTime
	,CourseDaysOfWeek
	,CourseCurrentPrice
)
Values 
	('SQL1', '2017-01-10', '2017-01-24', '18:00:00', '20:50:00', 'Tue', 399)
	,('SQL2', '2017-01-31', '2017-02-14', '18:00:00', '20:50:00', 'Thu', 249)
	,('ITFDN130', '2025-10-01', '2025-12-10', '18:00:00', '19:00:00', 'Wed', 599)
Commit Transaction
End Try
Begin Catch
	Rollback Transaction
	Print ERROR_MESSAGE()
End Catch
Go

Select * From vCourses
Go

--Students Test Data Manual Insert
Begin Try
Begin Transaction
Insert Into Students(
	StudentNumber
	,StudentFirstName
	,StudentLastName
	,StudentEmail
	,StudentPhone
	,StudentAddress1
	,StudentAddress2
	,StudentCity
	,StudentStateCode
	,StudentZipCode
)
Values
	('B-Smith-071', 'Bob', 'Smith', 'bsmith@hipmail.com', '206-111-2222', '123 Main St.', NULL, 'Seattle', 'WA', '98001')
	,('S-Jones-003', 'Sue', 'Jones', 'suejones@yayou.com', '206-123-4567', '333 1st Ave', NULL, 'Seattle', 'WA', '98104')
	,('M-Bradlee-001', 'Marcus', 'Bradlee', 'marcusb@gmail.com', '206-303-8967', '5064 Harold Pl NE', NULL, 'Seattle', 'WA', '98105')
Commit Transaction
End Try
Begin Catch
	Rollback Transaction
	Print ERROR_MESSAGE()
End Catch
Go

Select * From vStudents
Go

--Enrollments Test Data Manual Insert
Begin Try
Begin Transaction
Insert Into Enrollments(
	StudentID
	,CourseID
	,EnrollmentDateTime
	,EnrollmentPrice
)
Values
	(1, 1, '2017-01-03', 399)
	,(2, 1, '2016-12-14', 399)
	,(1, 2, '2017-01-12', 249)
	,(2, 2, '2017-01-25', 249)
	,(3, 3, '2025-09-30', 599)
Commit Transaction
End Try
Begin Catch
	Rollback Transaction
	Print ERROR_MESSAGE()
End Catch
Go

Select * From vEnrollments
Go

Select * From vMaster
Go

--< Add Stored Procedures (Review Module 04 and 08) >--
--Courses Insert, Update, Delete Sprocs
Create Procedure spInsertCourse (
	@CourseName nvarchar(100)
	,@CourseStartDate date
	,@CourseEndDate date
	,@CourseStartTime time
	,@CourseEndTime time
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice money
)
As
Begin
	Begin Try
	Begin Transaction
	Insert Into Courses(
		CourseName
		,CourseStartDate
		,CourseEndDate
		,CourseStartTime
		,CourseEndTime
		,CourseDaysOfWeek
		,CourseCurrentPrice
	)
	Values 
		(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseDaysOfWeek, @CourseCurrentPrice)
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spUpdateCourse (
	@CourseID int
	,@CourseStartDate date
	,@CourseEndDate date
	,@CourseStartTime time
	,@CourseEndTime time
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice money
)
As
Begin
	Begin Try
	Begin Transaction
		Update Courses Set
			CourseStartDate = @CourseStartDate
			,CourseEndDate = @CourseEndDate
			,CourseStartTime = @CourseStartTime
			,CourseEndTime = @CourseEndTime
			,CourseDaysOfWeek = @CourseDaysOfWeek
			,CourseCurrentPrice = @CourseCurrentPrice
		Where CourseID = @CourseID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spDeleteCourse (
	@CourseID int
)
As
Begin
	Begin Try
	Begin Transaction
		Delete From Courses 
		Where CourseID = @CourseID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

--Students Insert, Update, Delete Sprocs
Create Procedure spInsertStudent (
	@StudentNumber nvarchar(100)
	,@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@StudentPhone nvarchar(100)
	,@StudentAddress1 nvarchar(100)
	,@StudentAddress2 nvarchar(100)
	,@StudentCity nvarchar(100)
	,@StudentStateCode nvarchar(2)
	,@StudentZipCode nvarchar(10)
)
As
Begin
	Begin Try
	Begin Transaction
	Insert Into Students(
		StudentNumber
		,StudentFirstName
		,StudentLastName
		,StudentEmail
		,StudentPhone
		,StudentAddress1
		,StudentAddress2
		,StudentCity
		,StudentStateCode
		,StudentZipCode
	)
	Values 
		(@StudentNumber, @StudentFirstName, @StudentLastName, @StudentEmail, @StudentPhone, @StudentAddress1, @StudentAddress2, @StudentCity, @StudentStateCode, @StudentZipCode)
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spUpdateStudent (
	@StudentID int
	,@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@StudentPhone nvarchar(100)
	,@StudentAddress1 nvarchar(100)
	,@StudentAddress2 nvarchar(100)
	,@StudentCity nvarchar(100)
	,@StudentStateCode nvarchar(2)
	,@StudentZipCode nvarchar(10)
)
As
Begin
	Begin Try
	Begin Transaction
		Update Students Set
			StudentFirstName = @StudentFirstName
			,StudentLastName = @StudentLastName
			,StudentEmail = @StudentEmail
			,StudentPhone = @StudentPhone
			,StudentAddress1 = @StudentAddress1
			,StudentAddress2 = @StudentAddress2
			,StudentCity = @StudentCity
			,StudentStateCode = @StudentStateCode
			,StudentZipCode = @StudentZipCode
		Where StudentID = @StudentID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spDeleteStudent (
	@StudentID int
)
As
Begin
	Begin Try
	Begin Transaction
		Delete From Students 
		Where StudentID = @StudentID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

--Enrollments Insert, Update, Delete Sprocs
Create Procedure spInsertEnrollment (
	@StudentID int
	,@CourseID int
	,@EnrollmentDateTime datetime
	,@EnrollmentPrice money
)
As
Begin
	Begin Try
	Begin Transaction
	Insert Into Enrollments(
		StudentID
		,CourseID
		,EnrollmentDateTime
		,EnrollmentPrice
	)
	Values 
		(@StudentID, @CourseID, @EnrollmentDateTime, @EnrollmentPrice)
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spUpdateEnrollment (
	@EnrollmentID int
	,@StudentID int
	,@CourseID int
	,@EnrollmentDateTime datetime
	,@EnrollmentPrice money
)
As
Begin
	Begin Try
	Begin Transaction
		Update Enrollments Set
			StudentID = @StudentID
			,CourseID = @CourseID
			,EnrollmentDateTime = @EnrollmentDateTime
			,EnrollmentPrice = @EnrollmentPrice
		Where EnrollmentID = @EnrollmentID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

Create Procedure spDeleteEnrollment (
	@EnrollmentID int
)
As
Begin
	Begin Try
	Begin Transaction
		Delete From Enrollments 
		Where EnrollmentID = @EnrollmentID
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print ERROR_MESSAGE()
	End Catch
End
Go

--< Set Permissions >--
--Course Table Permissions
Deny
	Select
	,Insert
	,Update
	,Delete
On Courses To Public
Grant Select On vCourses To Public
Grant Execute On spInsertCourse To Public
Grant Execute On spUpdateCourse To Public
Grant Execute On spDeleteCourse To Public

--Student Table Permissions
Deny
	Select
	,Insert
	,Update
	,Delete
On Students To Public
Grant Select On vStudents To Public
Grant Execute On spInsertStudent To Public
Grant Execute On spUpdateStudent To Public
Grant Execute On spDeleteStudent To Public

--Enrollment Table Permissions
Deny
	Select
	,Insert
	,Update
	,Delete
On Enrollments To Public
Grant Select On vEnrollments To Public
Grant Execute On spInsertEnrollment To Public
Grant Execute On spUpdateEnrollment To Public
Grant Execute On spDeleteEnrollment To Public

--< Test Sprocs >-- 
--Course Sprocs
Exec spInsertCourse 
	@CourseName = 'ITFDN220'
	,@CourseStartDate = '2026-01-01'
	,@CourseEndDate = '2026-3-11'
	,@CourseStartTime = '19:00:00'
	,@CourseEndTime = '20:00:00'
	,@CourseDaysOfWeek = 'Mon'
	,@CourseCurrentPrice = 599
Go

Exec spUpdateCourse 
	@CourseID = 4
	,@CourseStartDate = '2026-01-01'
	,@CourseEndDate = '2026-3-11'
	,@CourseStartTime = '19:00:00'
	,@CourseEndTime = '20:00:00'
	,@CourseDaysOfWeek = 'Mon'
	,@CourseCurrentPrice = 499
Go

/*
Exec spDeleteCourse 
	@CourseID = 4
Go
*/

--Student Sprocs
Exec spInsertStudent
	@StudentNumber = 'D-Bradlee-000'
	,@StudentFirstName = 'Dave'
	,@StudentLastName = 'Bradlee'
	,@StudentEmail = 'daveb@gmail.com'
	,@StudentPhone = '206-465-7208'
	,@StudentAddress1 = '5061 Harold Pl NE'
	,@StudentAddress2 = NULL
	,@StudentCity = 'Seattle'
	,@StudentStateCode = 'WA'
	,@StudentZipCode = '98105'
Go

Exec spUpdateStudent
	@StudentID = 4
	,@StudentFirstName = 'Dave'
	,@StudentLastName = 'Bradlee'
	,@StudentEmail = 'dbradlee@gmail.com'
	,@StudentPhone = '206-465-7208'
	,@StudentAddress1 = '5061 Harold Pl NE'
	,@StudentAddress2 = NULL
	,@StudentCity = 'Seattle'
	,@StudentStateCode = 'WA'
	,@StudentZipCode = '98105'
Go

/*
Exec spDeleteStudent 
	@StudentID = 4
Go
*/

--Enrollment Sprocs
Exec spInsertEnrollment
	@StudentID = 4
	,@CourseID = 4
	,@EnrollmentDateTime = '2025-09-30'
	,@EnrollmentPrice = '599'
Go

Exec spUpdateEnrollment
	@EnrollmentID = 6
	,@StudentID = 4
	,@CourseID = 4
	,@EnrollmentDateTime = '2025-09-30'
	,@EnrollmentPrice = '499'
Go

/*
Exec spDeleteEnrollment 
	@EnrollmentID = 6
Go
*/

Select * From vCourses
Select * From vStudents
Select * From vEnrollments
Select * From vMaster
  
/**************************************************************************************************/