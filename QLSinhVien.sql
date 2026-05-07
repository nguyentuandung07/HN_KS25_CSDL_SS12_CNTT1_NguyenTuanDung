CREATE DATABASE StudentDB;

DROP DATABASE StudentDB;

USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course (CourseID, CourseName, Credits) VALUES
('CS101', 'Introduction to Programming', 3),
('DB201', 'Database Systems', 4),
('MGT11', 'Principles of Management', 3),
('ACC01', 'Financial Accounting', 3),
('MAT01', 'Advanced Mathematics', 3);

INSERT INTO Enrollment (StudentID, CourseID, Score) VALUES
('S00001', 'CS101', 8.5),
('S00001', 'DB201', 7.0),
('S00002', 'CS101', 9.0),
('S00002', 'MAT01', 6.5),
('S00005', 'CS101', 7.5),
('S00005', 'DB201', 9.5),
('S00008', 'MAT01', 8.0),
('S00003', 'MGT11', 8.0),
('S00003', 'MAT01', 7.5),
('S00006', 'MGT11', 5.5),
('S00006', 'ACC01', 6.0),
('S00004', 'ACC01', 9.0),
('S00004', 'MAT01', 4.5),
('S00007', 'ACC01', 7.0),
('S00007', 'MGT11', 8.5);

-- PHẦN A – CƠ BẢN (4đ)
-- Câu 1
CREATE VIEW ViewStudentBasic AS (
    SELECT S.StudentID, S.FullName, D.DeptName 
    FROM Student AS S 
    JOIN Department AS D
    ON S.DeptID = D.DeptID
);

SELECT * FROM ViewStudentBasic;

-- Câu 2
CREATE INDEX idxFullName ON Student(FullName);

-- Câu 3
DELIMITER //
CREATE PROCEDURE GetStudentsIT()
BEGIN
    SELECT S.* , D.DeptName 
    FROM Student AS S 
    JOIN Department AS D
    ON S.DeptID = D.DeptID
    WHERE D.DeptName = "Information Technology";
END
// DELIMITER;

CALL GetStudentsIT();

-- PHẦN B – KHÁ (3đ)
-- Câu 4
CREATE VIEW ViewStudentCountByDept AS (
    SELECT D.DeptName , COUNT(*) AS TotalStudents
    FROM Department AS D
    JOIN Student AS S
    ON S.DeptID = D.DeptID
    GROUP BY D.DeptName
);

SELECT * FROM ViewStudentCountByDept ORDER BY TotalStudents DESC LIMIT 1;

-- Câu 5
DELIMITER //
CREATE PROCEDURE GetTopScoreStudent(
    IN varCourseID VARCHAR(6)
)
BEGIN
    SELECT MAX(E.Score) AS MaxScore 
    FROM Enrollment AS E
    JOIN Student AS S ON S.StudentID = E.StudentID
    JOIN Course AS C ON C.CourseID = E.CourseID
    WHERE C.CourseID = varCourseID;
END
// DELIMITER;

CALL GetTopScoreStudent("DB201");

-- PHẦN C – GIỎI (3đ)
-- Câu 6:
-- a)
CREATE VIEW ViewITEnrollmentDB AS (
    SELECT E.StudentID, E.CourseID, E.Score
    FROM Enrollment AS E
    JOIN Student AS S ON S.StudentID = E.StudentID 
    JOIN Department AS D ON S.DeptID = D.DeptID
    WHERE D.DeptID = "IT" AND E.CourseID = "DB201"
) WITH CHECK OPTION;

-- b)
DELIMITER //
CREATE PROCEDURE UpdateScoreITDB (
    IN varStudentID VARCHAR(6),
    INOUT inoutNewScore DECIMAL(4,2)
)
BEGIN
    IF inoutNewScore > 10 THEN
        SET inoutNewScore = 10;
    END IF;
    
    UPDATE ViewITEnrollmentDB 
    SET Score = inoutNewScore
    WHERE StudentID = varStudentID;
END
// DELIMITER;

-- c) 
SET @newScore = 12.5;
CALL UpdateScoreITDB("S00001", @newScore);
SELECT @newScore AS UpdatedScore;

SELECT * FROM ViewITEnrollmentDB;
