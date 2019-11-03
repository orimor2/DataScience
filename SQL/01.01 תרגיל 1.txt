---Exercise 2a

---Join of table dsuser1.departmetn1 + dsuser1.classroom1 + dsuser1.courses1  
SELECT a.Course_id, b.Department_name, c.Student_id 
INTO dsuser1.joinCourse_id_Department_name_Student_id  
FROM dbo.courses AS a
INNER JOIN dbo.departments AS b ON a.Department = b.Department_id
INNER JOIN dbo.classroom AS c ON a.Course_id = c.Course_id
SELECT * FROM dsuser1.joinCourse_id_Department_name_Student_id  

---Counting number of student in each department
SELECT Department_name, COUNT(DISTINCT Student_id) AS Total_Student_indepartment
FROM dsuser1.joinCourse_id_Department_name_Student_id 
GROUP BY Department_name
ORDER BY Total_Student_indepartment



---Exercise 2b
---Creating Table base on dbo.classroom
CREATE TABLE [dsuser1].[engliah_class](
			Course_id int NOT NULL,
			Student_id int NOT NULL	
	);    
		
		
---Insert data from dbo.classroom
		INSERT INTO [dsuser1].[engliah_class]
		SELECT Course_id, Student_id 
		FROM dbo.classroom
		WHERE (Course_id <=3)

---Creating table based on dbo.courses
CREATE TABLE [dsuser1].[courses_classify](
			Course_id int NOT NULL,
			Course_name VARCHAR (20) 
);
	
		INSERT INTO [dsuser1].[courses_classify]
		SELECT Course_id, Course_name
		FROM dbo.courses
		WHERE (Course_id <=3)
 

---Join table [dsuser1].[engliah_class] + [dsuser1].[courses_classify]
SELECT b.Course_name, a.Student_id
INTO [dsuser1].[joinCourse_name_Student_id]
FROM [dsuser1].[engliah_class] AS a
INNER JOIN [dsuser1].[courses_classify] AS b ON a. Course_id = b. Course_id 


---Counting nuber of student in each english class 
SELECT Course_name, COUNT (Student_id) AS Student_num_in_english_class
FROM [dsuser1].[joinCourse_name_Student_id]
GROUP BY Course_name 

---Counting nuber of student in total english class
SELECT COUNT (DISTINCT Student_id) AS Total_Student_num_in_english
FROM [dsuser1].[engliah_class]


---Exercise 2c
---Join of table dsuser1.departmetn1 + dsuser1.classroom1 + dsuser1.courses1 
SELECT Course_id, Department_name, Student_id 
INTO dsuser1.joinCourse_id_Department_name_Student_id2  
FROM dsuser1.joinCourse_id_Department_name_Student_id
WHERE (Course_id > 3) AND (Course_id < 20)

SELECT * FROM dsuser1.joinCourse_id_Department_name_Student_id2


SELECT Course_id, COUNT (Student_id) AS Studentperclass
INTO dsuser1.science_class_size
FROM dsuser1.joinCourse_id_Department_name_Student_id2
GROUP BY Course_id 
SELECT * FROM dsuser1.science_class_size



ALTER TABLE dsuser1.science_class_size ADD Big_vs_Small VARCHAR (20) 


	UPDATE dsuser1.science_class_size SET Big_vs_Small = 
	CASE
		WHEN (Studentperclass <22) THEN ('Small')
		ELSE ('Big')
	END

---Counting small and big classes
	SELECT Big_vs_Small , COUNT (Big_vs_Small) AS Total_Class
	FROM dsuser1.science_class_size
	GROUP BY Big_vs_Small


---Exercise 2d
---CREATE TABLE dsuser1.student_gender based on dbo.students
SELECT * 
INTO dsuser1.student_gneder
FROM dbo.students

---Counting student F vs. M in all classes

SELECT Gender, COUNT(Student_id) AS Student_by_gender
FROM dsuser1.student_gneder
GROUP BY Gender 

---The Feminist girl was wrong

---Exercise 2e
---join tables dbo.classroom + dbo.students + dbo.courses
SELECT a.Student_id, a.Course_id, b.Gender, c.Course_name
INTO dsuser1.student_gneder_percent
FROM dbo.classroom AS a
INNER JOIN dbo.students AS b ON a.Student_id = b.Student_id
INNER JOIN dbo.courses AS c ON a.Course_id = c.Course_id


---Creating tabel of Total F By Course_name
SELECT Course_name, Gender, COUNT (Gender) AS TotalF
INTO dsuser1.F
FROM dsuser1.student_gneder_percent
WHERE (Gender = 'F')
GROUP BY Course_name, Gender


---Creating tabel of Total M By Course_name
SELECT Course_name, Gender, COUNT (Gender) AS TotalM
INTO dsuser1.M
FROM dsuser1.student_gneder_percent
WHERE (Gender = 'M')
GROUP BY Course_name, Gender

 
---Counting total student Group By Course_name
SELECT Course_name, COUNT(Student_id) as Total_gender
INTO dsuser1.total_gen
FROM dsuser1.student_gneder_percent
GROUP BY Course_name


---Join tabel TotalF + TotalM + Total_gender
SELECT a.Course_name, a.Total_gender, b.TotalM, c.TotalF
INTO dsuser1.joinCourse_name_Total_gender
FROM dsuser1.total_gen AS a 
INNER JOIN dsuser1.M AS b on a.Course_name = b.Course_name
INNER JOIN dsuser1.F AS c on a.Course_name = c.Course_name


---Calculate % of M in each class
SELECT Course_name, 
(((TotalM * 1.0)/(Total_gender * 1.0)) * 100.0) AS M_precent
INTO dsuser1.male_percent
FROM dsuser1.joinCourse_name_Total_gender


---Calculate % of F in each class
SELECT Course_name, 
(((TotalF * 1.0)/(Total_gender * 1.0)) * 100.0) AS F_precent
INTO dsuser1.female_percent
FROM dsuser1.joinCourse_name_Total_gender


---Join dsuser1.male_percent + dsuser1.female_percent 
SELECT a.Course_name, a.M_precent, b.F_precent
INTO dsuser1.sum_percent_of_F_M
FROM dsuser1.male_percent AS a
INNER JOIN dsuser1.female_percent AS b ON a.Course_name = b.Course_name


---Selecting the courses in 70% of M 
SELECT Course_name
INTO dsuser1.Course_name_M_over70
FROM dsuser1.sum_percent_of_F_M
WHERE M_precent >70

------Selecting the courses in 70% of F
SELECT Course_name
INTO dsuser1.Course_name_F_over70
FROM dsuser1.sum_percent_of_F_M
WHERE F_precent >70 

---No classes with M>70% !!!
---2 classes with F>70%  - Tenis, Sculpture

---Exercise 2f
---Join table dbo.classroom + dbo.courses + dbo.departments
SELECT a.Student_id, a.Degree, c.Department_name
INTO dsuser1.joinStudent_id_Degree_Department_Department_name
FROM dbo.classroom AS a
INNER JOIN dbo.courses AS b ON a.Course_id = b.Course_id
INNER JOIN dbo.departments AS c ON b.Department = c.Department_id
 
---Counting number of good student (degee over 80)
SELECT Department_name, COUNT (Degree)AS Good_student_number,
100.0* COUNT (Degree)/SUM (COUNT(*)) OVER() AS Good_student_percent	
FROM dsuser1.joinStudent_id_Degree_Department_Department_name
WHERE Degree>80
GROUP BY Department_name


---Exercise 2g
---Selecting Joined table dsuser1.joinStudent_id_Degree_Department_Department_name
SELECT * 
INTO dsuser1.joinStudent_id_Degree_Department_Department_name2
FROM dsuser1.joinStudent_id_Degree_Department_Department_name


---Counting number of not good student (degee under 60)
SELECT Department_name, COUNT (Degree) AS Not_Good_student_number,
100.0* COUNT (Degree)/SUM (COUNT(*)) OVER() AS Not_Good_student_percent	
FROM dsuser1.joinStudent_id_Degree_Department_Department_name2
WHERE Degree<60
GROUP BY Department_name

---Exercise 2h
---Jiontable dbo.teachers + dbo.courses + dbo.classroom 
SELECT a.First_name, a.Last_name, c.Degree
INTO dsuser1.joinFirst_name_Last_name_Degree
FROM dbo.teachers AS a
INNER JOIN dbo.courses AS b ON a.Teacher_id = b.Teacher_id
INNER JOIN dbo.classroom AS c ON b.Course_id = c.Course_id

---AVG degree by teachers
SELECT First_name, Last_name, AVG (Degree) AS Average
INTO dsuser1.teacher_degree
FROM dsuser1.joinFirst_name_Last_name_Degree
GROUP BY First_name, Last_name

---Ordering by degree average
SELECT * FROM   dsuser1.teacher_degree
ORDER BY Average DESC


---Exercise 3a
---join table dbo.departments + dbo.teachers + dbo.courses + dbo.classroom
SELECT a.Department_name, b.Course_name, c.First_name AS Teacher_Firstname, c.Last_name AS Teacher_Lastname, Student_id
INTO dsuser1.vDepartment_name_Course_name_First_name_Last_name_Student_id
FROM dbo.departments AS a
INNER JOIN dbo.courses AS b ON a.Department_id = b.Department
INNER JOIN dbo.teachers AS c ON b.Teacher_id = c.Teacher_id
INNER JOIN dbo.classroom AS d ON b.Course_id = d.Course_id


---Creating view based on dsuser1.vDepartment_name_Course_name_First_name_Last_name_Student_id
CREATE VIEW Department_student_classification 
AS 
SELECT Department_name, Course_name, Teacher_Firstname, Teacher_Lastname, COUNT (Student_id) AS Total_student
FROM dsuser1.vDepartment_name_Course_name_First_name_Last_name_Student_id
GROUP BY Department_name, Course_name, Teacher_Firstname,Teacher_Lastname 

---Exercise 3b
---Total_Courses_for_Student
SELECT Student_id, COUNT(Course_id) AS Total_Courses_for_Student
INTO dsuser1.Total_Courses
FROM dbo.classroom
GROUP BY Student_id
SELECT * FROM dsuser1.Total_Courses

---Total_AVG_for_Student
SELECT Student_id, AVG (Degree) AS Total_AVG_for_Student
INTO dsuser1.Total_AVG
FROM dbo.classroom
GROUP BY Student_id
SELECT * FROM dsuser1.Total_AVG

--- AVG_in_dep
SELECT Student_id, Department_name, AVG (Degree) AS AVG_in_dep
INTO dsuser1.AVG_in_dep
FROM dsuser1.joinStudent_id_Degree_Department_Department_name
Group by Student_id, Department_name
SELECT * FROM dsuser1.AVG_in_dep

---Join Tables
SELECT a.First_name, a.Last_name, b.Total_Courses_for_Student, c.Total_AVG_for_Student, d.Department_name, d.AVG_in_dep
INTO dsuser1.degree_avg_of_each_student
FROM dbo.students AS a 
INNER JOIN dsuser1.Total_Courses AS b ON a.Student_id = b.Student_id
INNER JOIN dsuser1.Total_AVG AS c ON b.Student_id = c.Student_id
INNER JOIN dsuser1.AVG_in_dep AS d ON b.Student_id = d.Student_id

---Creating view
CREATE VIEW vdegree_avg_of_each_student
AS
SELECT * FROM  dsuser1.degree_avg_of_each_student


