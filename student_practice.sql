/* ==========================================================================
   student_practice.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5d

   WHAT THIS FILE IS
   Your working file for Lab 5d. The first two statements are written for
   you. Everything from Step 1 down is yours to write, under the heading
   that is already there for each step.

   HOW TO USE IT
   Run one statement at a time. Put the cursor on it and press Ctrl + E
   twice, or right click and choose Run Current Query. Do not run the whole
   file in one go, because Step 8 creates a function and that step has to be
   run as a single block on its own.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The headings below are already numbered, so keep
   your work underneath the right one. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these two first, in this order
-- =================================================================

-- Every schema on this server. Look for cis_students_db afterwards.
show databases;

-- Make the schema for this lab. IF NOT EXISTS means it is safe to run
-- twice, and it will not complain if you already made it.
create database if not exists cis_students_db;


-- =================================================================
-- POINT YOURSELF AT THE NEW SCHEMA
-- =================================================================

-- Everything below has to land in cis_students_db, not in the schema you
-- connected to. This line switches the session over.
--
-- IMPORTANT: if your tables keep appearing in the wrong place, your tool
-- is opening a new connection for each statement and this line is being
-- forgotten. Step 3 of the lab tells you how to fix that for good by
-- adding a second SQLTools connection that points at cis_students_db.
use cis_students_db;


-- ######################################################################
-- YOUR WORK STARTS BELOW THIS LINE
--
-- You write the SQL for Steps 1 through 7 yourself. The handout gives you
-- the specification, the data and the result you should get.
--
-- Steps 8, 9 and 10 are printed in the handout for you to copy, because
-- you have not written a function or a trigger before.
--
-- STEPS 8 AND 10 ARE RUN AT THE COMMAND PROMPT, not in VS Code. They
-- start with DELIMITER, which is an instruction to the command prompt
-- program rather than SQL, so the server rejects it. The handout says
-- what to do. Everything else in this file runs in VS Code as usual.
-- ######################################################################


-- =================================================================
-- STEP 1. Create the students table, then describe it
-- =================================================================

-- your comment goes here
create table if not exists students (
   student_id INT auto_increment primary key,
   first_name varchar(40) not null,
   last_name varchar(40) not null,
   gpa float(4,2)
);
show full tables;
describe students; 

-- =================================================================
-- STEP 2. Insert four rows using NULL for student_id and gpa
-- =================================================================

-- your comment goes here
insert into students values 
(null, "Jenna", "Wilsion", null),
(null,"Robert", "Reese", null), 
(null, "Maria Elena", "Jimenez", null),
(null,"Inder", "Singh", null);

select * from students;


-- =================================================================
-- STEP 3. Insert two more rows, naming the columns first
-- =================================================================

-- your comment goes here
insert into students (first_name,last_name) values
("Rita", "Nunez"),
("James", "Thor")

select * from students; 


-- =================================================================
-- STEP 4. Delete James Toor
-- =================================================================

-- Delete James Toor student_id = 6 
delete from students where student_id = 6;


-- =================================================================
-- STEP 5. Create the test_scores table
-- =================================================================

-- Create new table scores_table using auto_increment
-- include the student(student_id) as the foreign key
create table if not exists test_scores (
   test_score_id INT auto_increment primary key,
   test_name varchar(20) not null, 
   student_id int not null,
   score float,
   foreign key (student_id) references students(student_id)

);
-- =================================================================
-- STEP 6. Insert the ten test score rows
-- =================================================================

-- insert rows into test_scores table
/*
insert into test_scores values
(null,"quiz1", 1, 90),
(null, "quiz2", 4, 91),
(null, "quiz1",  2, 85),
(null, "quiz3", 2, 95),
(null, "quiz1", 3, 95),
(null, "quiz3", 3, 94),
(null, "quiz2",  1, 80),
(null, "quiz3",  4, 74),
(null, "quiz2", 2, 72),
(null, "quiz2", 3, 88)
*/

select * from test_scores;


-- =================================================================
-- STEP 7. Create the student_scores view from a LEFT OUTER JOIN,
--         then query it twice
-- =================================================================

-- Build a view that combines student information with their test results
CREATE VIEW student_scores AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    t.test_name,
    t.score
FROM students AS s
LEFT OUTER JOIN test_scores AS t
    ON s.student_id = t.student_id;
-- Display all rows in the view
SELECT * FROM student_scores;
-- Show only the test results for student number 3
SELECT * FROM student_scores WHERE student_id = 3

-- =================================================================
-- STEP 8. Create the calculate_gpa function
--
-- Paste the block from the handout in here so it is part of what you
-- submit, then RUN IT AT THE COMMAND PROMPT, not in VS Code.
--
-- DELIMITER is an instruction to the mysql command prompt program. It is
-- not SQL. Run it here and the server rejects it with
--   ERROR 1064 ... near 'DELIMITER $$' at line 1
-- =================================================================

-- Create a function that calculates a student's average score
CREATE FUNCTION calculate_gpa(p_student_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_gpa DECIMAL(4,2);

    SELECT ROUND(AVG(score), 2)
    INTO v_gpa
    FROM test_scores
    WHERE student_id = p_student_id
      AND score IS NOT NULL;

    RETURN IFNULL(v_gpa, 0.00);
END;
-- Verify that the GPA function was created
SHOW CREATE FUNCTION calculate_gpa;

-- =================================================================
-- STEP 9. Run the function and fill in every gpa
-- =================================================================

-- Update the GPA for every student
UPDATE students
SET gpa = calculate_gpa(student_id);
-- Check the students table after updating the GPAs
SELECT * FROM students;
-- =================================================================
-- STEP 10. Create the triggers that recalculate the gpa
--
-- Same as Step 8. Paste the block in here, then run it at the command
-- prompt. Afterwards add a score or change one, back here in VS Code,
-- and check that the gpa moved on its own.
-- =================================================================

-- Recalculate the GPA when a new test score is added
CREATE TRIGGER trg_scores_after_insert
AFTER INSERT ON test_scores
FOR EACH ROW
BEGIN
    UPDATE students
    SET gpa = calculate_gpa(NEW.student_id)
    WHERE student_id = NEW.student_id;
END;


-- =================================================================
-- STEP 11. Push this file to GitHub
-- Nothing to write here. Follow the handout.
-- =================================================================
