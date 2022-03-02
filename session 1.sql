

--________________________________________________________Database Creation

IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'UniversityDB'
)
CREATE DATABASE UniversityDB
GO

USE UniversityDB
GO


--________________________________________________________Tables Creation

CREATE TABLE dbo.department
(
    ID              VARCHAR(5) NOT NULL UNIQUE  ,
    dept_name		VARCHAR(20) NOT NULL, 
	building		VARCHAR(15), 
	budget		    NUMERIC(12,2) CHECK (budget > 0),
	PRIMARY KEY (ID)

);
GO


CREATE TABLE dbo.classroom
(
     building		VARCHAR(15) NOT NULL,
	 room_number	VARCHAR(7) NOT NULL,
	 capacity		NUMERIC(4,0),
	 PRIMARY KEY (building, room_number)
);
GO


CREATE TABLE dbo.courses
(
     ID		        VARCHAR(5) NOT NULL UNIQUE, 
	 Title			VARCHAR(50) NOT NULL, 
	 Credits		NUMERIC(2,0) CHECK (credits > 0),
     DepartmentID	VARCHAR(5),
	 PRIMARY KEY (ID),
	 FOREIGN KEY (DepartmentID) REFERENCES department  on delete set null
);
GO
 

CREATE TABLE dbo.instructor
(
     ID			    VARCHAR(5) NOT NULL UNIQUE, 
	 name			VARCHAR(20) NOT NULL, 
	 DepartmentID	VARCHAR(5), 
	 salary			NUMERIC(8,2),
	 PRIMARY KEY (ID),
	 FOREIGN KEY (DepartmentID) REFERENCES department on delete set null
);
GO


CREATE TABLE dbo.prerequisties
(
     course_id		VARCHAR(5)NOT NULL, 
	 prereq_id		VARCHAR(5)NOT NULL,
	 PRIMARY KEY (course_id, prereq_id),
	 FOREIGN KEY (course_id) REFERENCES courses on delete cascade,
	 FOREIGN KEY (prereq_id) REFERENCES courses
);
GO


CREATE TABLE dbo.section
(
     course_id		VARCHAR(5)NOT NULL, 
     sec_id			VARCHAR(5)UNIQUE NOT NULL,
	 semester		VARCHAR(6) NOT NULL CHECK (semester in ('fall', 'winter', 'spring', 'summer')), 
	 year			NUMERIC(4,0)NOT NULL CHECK (year > 1701 and year < 2100), 
	 building		VARCHAR(15),
	 room_number	VARCHAR(7),
	 time_slot_id	VARCHAR(5)NOT NULL,
	 PRIMARY KEY (course_id,sec_id,semester, year),
	 FOREIGN KEY (course_id) REFERENCES courses on delete cascade,
	 FOREIGN KEY (building, room_number) REFERENCES classroom on delete set null,
);
GO


CREATE TABLE dbo.time_slot
(
     time_slot_id	VARCHAR(5) NOT NULL UNIQUE,
	 day			VARCHAR(1)NOT NULL CHECK(day >= 1 and day < 8), --1: saturday  and so on
	 start_time		TIME(0)NOT NULL,
	 end_time		TIME(0),
	 PRIMARY KEY (time_slot_id, day, start_time)
);
GO


CREATE TABLE dbo.student
(
     ID		    	VARCHAR(5) NOT NULL UNIQUE, 
	 name		    VARCHAR(20) NOT NULL, 
	 DepartmentID	VARCHAR(5), 
	 tot_cred	    NUMERIC(3,0) CHECK (tot_cred >= 0),
     passed         NUMERIC(3,0) CHECK (passed >=0)
	 PRIMARY KEY (ID),
	 FOREIGN KEY (DepartmentID) REFERENCES department on delete set null
);
GO


CREATE TABLE dbo.advisor
(
     s_id		  VARCHAR(5) NOT NULL,
	 i_id		  VARCHAR(5),
	 PRIMARY KEY (s_id),
	 FOREIGN KEY (i_id) REFERENCES instructor (ID) on delete set null,
	 FOREIGN KEY (s_id) REFERENCES student (ID) on delete cascade
);
GO


CREATE TABLE dbo.teaches
(
     ID			VARCHAR(5) NOT NULL, 
	 course_id		VARCHAR(5) NOT NULL,
	 sec_id			VARCHAR(5) NOT NULL, 
	 semester		VARCHAR(6),
	 year			NUMERIC(4,0) CHECK (year > 1701 and year < 2100),
	 PRIMARY KEY  (ID, course_id, sec_id, semester, year),
     FOREIGN KEY  (ID) REFERENCES instructor on delete cascade,
     FOREIGN KEY  (course_id,sec_id, semester, year) REFERENCES section on delete cascade
);
GO

CREATE TABLE dbo.available_courses
(
    CourseID    VARCHAR(5)NOT NULL,
    Semester    VARCHAR(6) NOT NULL CHECK(semester in ('fall','spring')),
    SectionID   VARCHAR(5)NOT NULL,
    Year        NUMERIC (4,0) CHECK (year > 1701 and year < 2100),
    ID          VARCHAR(5)NOT NULL,
    TeacherID   VARCHAR(5)NOT NULL, 
    PRIMARY KEY (ID,SectionID),
    FOREIGN KEY (CourseID,ID,Semester,Year) REFERENCES section,
	FOREIGN KEY (TeacherID) REFERENCES instructor

);
GO


CREATE TABLE dbo.taken_courses
(
    StudentID   VARCHAR(5)NOT NULL,
    CourseID    VARCHAR(5)NOT NULL,
    Semester    VARCHAR(6),
    SectionID   VARCHAR(5),
    Year        NUMERIC(4,0) CHECK (year > 1701 and year < 2100),
    Grade       VARCHAR(2),
    FOREIGN KEY (StudentID) REFERENCES student,
    FOREIGN KEY (CourseID,SectionID,Semester,Year) REFERENCES section,


);
GO

-- CREATE TABLE dbo.takes
-- (
--      ID			    VARCHAR(5), 
-- 	 course_id		VARCHAR(5),
-- 	 sec_id			VARCHAR(5), 
-- 	 semester		VARCHAR(6),
-- 	 year			NUMERIC(4,0) CHECK (year > 1701 and year < 2100) ,
-- 	 grade		    VARCHAR(2),
-- 	 PRIMARY KEY   (ID, course_id, sec_id, semester, year),
--      FOREIGN KEY   (ID) REFERENCES instructor on delete cascade,
-- 	 FOREIGN KEY   (course_id,sec_id, semester, year) REFERENCES section on delete cascade,
-- 	 FOREIGN KEY (ID) REFERENCES student on delete cascade
-- );
-- GO



--________________________________________________________Sample Data Insertion


INSERT INTO department
( 
 [ID], [dept_name], [building],[budget]
)
VALUES
( 
 '1', 'Comp. Eng.', 'ECE' ,'1200000'
),
( 
 '2', 'Elec. Eng.', 'ECE' ,'1100000'
)

GO


INSERT INTO classroom
(
 [building], [room_number], [capacity]
)
VALUES
(
 'building1', '1', '30'
),
(
 'building2', '2', '40'
)

GO


INSERT INTO courses
( 
 [ID], [Title], [Credits],[DepartmentID]
)
VALUES
( 
 '1', 'DB1', '3','1'
),
( 
 '2', 'FPGA', '4','2'
)

GO


INSERT INTO instructor
( 
 [ID], [name], [DepartmentID],[salary]
)
VALUES
(
 '1','Basiri','1','10000'
),
(
 '2','Yazdian','2','10000'
)
GO


INSERT INTO time_slot
(
 [time_slot_id], [day], [start_time],[end_time]
)
VALUES
( 
 '1','1','8:15:30','9:20:10'
),
( 
 '2','2','9:15:30','10:20:10'
)

GO


INSERT INTO section
(
 [course_id], [sec_id], [semester], [year], [building], [room_number], [time_slot_id]
)
VALUES
(
 '1','1','fall','2017','building1','1','1'
),
( 
  '2','2','spring','2017','building2','2','1'
)

GO


INSERT INTO student
( 
	[ID],[name],[DepartmentID],[tot_cred],[passed]
)
VALUES
( 
 '1','El','1','100','100'
),
( 
 '2','Mo','2','101','101'
),
( 
 '123','Who','1','100','100'
)
GO


INSERT INTO advisor
( 
 [s_id], [i_id]
)
VALUES
(
 '1','2'
),
(
 '2','1'
)
GO


INSERT INTO teaches
( 
 [ID], [course_id], [sec_id],[semester],[year]
)
VALUES
(
 '1','1','1','fall','2017'
),
( 
 '2','2','2','spring','2017'
)
GO
 

INSERT INTO available_courses
(
 [CourseID], [Semester], [SectionID], [Year], [ID], [TeacherID]
)
VALUES
( 
 '1','fall','1','2017','1','1'
),
(
 '2','spring','2','2017','2','2'
)
GO


INSERT INTO taken_courses
( 
 [StudentID], [CourseID], [Semester], [SectionID], [Year], [Grade]
)
VALUES
( 
 '1','1','fall','1','2017','18'
),
(
 '2','1','fall','1','2017','19'
)
GO

INSERT INTO prerequisties
(
 [course_id], [prereq_id]
)
VALUES
( 
 '1', '2'
)
GO


--________________________________________________________Queries


SELECT  ID,dept_name,building,budget
FROM department
WHERE department.ID = (SELECT DepartmentID FROM student WHERE ID = '123')

--if we consider that each student can be a member of multiple departments for example CS and Math...
SELECT  ID,dept_name,building,budget
FROM department
WHERE department.ID in (SELECT DepartmentID FROM student WHERE ID = '123')





--1st solution
-- UPDATE taken_courses
-- SET
-- 	Grade= Grade+1	
-- GO

-- SELECT * From taken_courses
-- Go

--2nd solution
SELECT  StudentID,CourseID,Semester,SectionID,Year,Grade+1
FROM taken_courses 




--1
SELECT *
FROM student 
WHERE ID not in (SELECT StudentID FROM taken_courses  WHERE CourseID = (SELECT ID FROM courses WHERE Title='DB1'))
--2
