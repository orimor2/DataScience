

## On Windows, using the R-DBI package we connect to the DSN and import the "College" db:
library(DBI)
con <- dbConnect(odbc::odbc(), DSN="College;Trusted_Connection=yes;")

## Geting the whole tables:
students <- dbReadTable(con, "students")
teachers <- dbReadTable(con, "teachers")
classroom <- dbReadTable(con, "classroom")
courses <- dbReadTable(con, "courses")
departments <- dbReadTable(con, "departments")
## Very important to disconnect 
dbDisconnect(con)

library(dplyr)

## Questions

#########################################################
## Q1. Count the number of students on each department ##
#########################################################


Sum_student_by_depart <- (classroom %>% 
                            left_join(courses, by = "Course_id") %>%  ##### joining courses + classroom 
                            left_join(departments, by = "Department_id")) %>%   ##### joining courses + classroom + departments
  group_by(Department_id, Department_name) %>%   ##### grouping and counting  the sum students by departments
  summarise(sum_student=n_distinct(Student_id))

##################################################################################
## Q2. How many students have each course of the English department and the ######
##     total number of students in the department?                          ######
##################################################################################

Sum_student_english <- (courses %>%   
                          left_join(classroom, by = "Course_id")%>%   ##### joining courses + classroom
                          left_join(departments, by = "Department_id")) %>%  ##### joining courses + classroom + departments
  filter(Department_id == "1") %>%   ##### selecting the English department
  group_by(Department_id, Course_id, Course_name) %>%  ##### grouping and counting  the sum students by english courses
  summarise(Students_In_English_Courses=(count=n()))
                      

Sum_English <- (courses %>%   
                  left_join(classroom, by = "Course_id")%>%   ##### joining courses + classroom
                  left_join(departments, by = "Department_id")) %>%  ##### joining courses + classroom + departments
  filter(Department_id == "1") %>%  ##### selecting the English department
  summarise(Students_In_English=n_distinct(Student_id)) ##### counting the total students

##################################################################################
## Q3. How many small (<22 students) and large (22+ students) classrooms are #####
##     needed for the Science department?                                    #####
##################################################################################

courses_classify <- (courses %>% 
                       left_join(classroom, by = "Course_id")) %>%   ##### joining courses + classroom 
  group_by(Course_id,Course_name) %>%  ##### grouping the data by courses
  filter(Department_id == 2) %>%   ##### selecting the science department
  summarise(Students_Num=n_distinct(Student_id))%>%   ##### counting the number of student in each course
  mutate(Classification = ifelse(Students_Num>21,"Big",    ##### classify the classes by their size
                                 ifelse(Students_Num<22, "Small"))) %>%
  group_by(Classification)%>%  ##### grouping by "big" / "small"
  summarise(count=n()) ##### counting the num of big vs. small classes


##################################################################################
## Q4. A feminist student claims that there are more male than female in the  ####
##     College. Justify if the argument is correct                            ####
##################################################################################


Students_Gender <- students %>% 
  group_by(Gender) %>% ##### grouping by Gender
  summarise(count=n())  ##### counting F vs. M


##################################################################################
## Q5. For which courses the percentage of male/female students is over 70%?  ####
##################################################################################


Classes_by_Gender <- (courses %>% 
                        inner_join(classroom, by = "Course_id") %>%  ##### joining the tables
                        inner_join(students, by = "Student_id")) %>%
  group_by(Course_id, Course_name, Gender) %>%  #####grouping 
  summarise(Sum_Gender=n()) %>%  ##### cointing the number of each gender     
  mutate(Percent = Sum_Gender/sum(Sum_Gender)*100) %>% ##### creating a new column of the precent
  group_by(Course_id, Course_name, Percent)  %>%  #####grouping by the course and the percent 
  filter(Percent > 70) ####selecting the classes over 70%


##################################################################################
## Q6. For each department, how many students passed with a grades over 80?  #####
##################################################################################


Department_Degree80 <- (classroom %>%
                          left_join(courses, by = "Course_id") %>% ##### joining tables
                          left_join(departments, by = "Department_id")) %>% 
  filter(Degree > 80) %>%  ##### selecting only the degree over 80
  group_by(Department_id, Department_name) %>%  ##### grouping
  summarise(Sum_student_over_80=n_distinct(Student_id)) ##### summing the students with degree over 80

##################################################################################
## Q7. For each department, how many students passed with a grades under 60?  ####
##################################################################################



Department_Degree60 <- (classroom %>%
                          left_join(courses, by = "Course_id") %>% ##### joining tables
                          left_join(departments, by = "Department_id")) %>% 
  filter(Degree <60) %>% ##### selecting only the degree under 60
  group_by(Department_id, Department_name) %>%  ##### grouping
  summarise(Sum_student_under_60=n_distinct(Student_id)) ##### summing the students with degree under 60


##################################################################################
## Q8. Rate the teachers by their average student's grades (in desc order) #######
##################################################################################



Teachers_degree <- (classroom %>% 
                      left_join(courses, by = "Course_id") %>%  ##### joining tables
                      left_join(teachers, by = "Teacher_id")) %>%
  group_by(Teacher_id, First_name, Last_name) %>% #####grouping 
  summarise(Teacher_mean_degree=mean(Degree, na.rm = T)) %>% ##### calculating the mean degree
  arrange(desc(Teacher_mean_degree)) ##### ordering by descending


########################################################################################
## Q9. Create a dataframe showing the courses, departments they are associated with, 
##     the teacher in each course, and the number of students enrolled in the course 
##     (for each course, department and teacher show the names).
########################################################################################


df <- (classroom %>% 
          left_join(courses, by = "Course_id") %>% ##### joining tables
          left_join(teachers, by = "Teacher_id") %>%
          left_join(departments, by = "Department_id")) %>%
  group_by(Course_id, Course_name, Department_id, Department_name, First_name, Last_name) %>% 
  summarise(Sum_student_in_class=n_distinct(Student_id))  ##### counting the students in classes


########################################################################################
## Q10. Create a dataframe showing the students, the number of courses they take, 
##      the average of the grades per class, and their overall average (for each student 
##      show the student name).
########################################################################################



df1 <- (students %>% 
          inner_join(classroom, by = "Student_id") %>%  #####joining tables
          inner_join(courses, by = "Course_id")) %>%
  group_by(Student_id, First_name, Last_name) %>%  ##### grouping
  summarise(Sum_courses=n(),Total_mean=mean(Degree, na.rm = T))  ##### calculating the sum and totla mean of each student

  
df2 <- (students %>% 
          inner_join(classroom, by = "Student_id") %>% #####joining tables
          inner_join(courses, by = "Course_id") %>%
          inner_join(departments, by = "Department_id")) %>% 
  group_by(Student_id, First_name, Last_name, Department_name) %>% ##### grouping
  summarise(Class_mean=mean(Degree, na.rm = T))  ##### calculating mean of each department

library(tidyr) ##### running the library in order to change columns into rows

df3 <- (df1 %>%    #####joining table df1 + df2
          inner_join(df2, by = c("Student_id","First_name","Last_name"))) %>%
  group_by (Student_id, First_name, Last_name, Sum_courses, Total_mean) %>% ##### grouping all the columns that do not change when we convert the table
  spread(key = Department_name, value = Class_mean) ##### using "spread" we convert the table. 

  
  