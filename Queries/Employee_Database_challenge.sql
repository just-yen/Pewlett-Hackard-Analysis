-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL, 
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
); 

-- Creating tables for employees
CREATE TABLE employees (
	 emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN key (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (dept_no, emp_no)
);

CREATE TABLE Titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN key (emp_no) REFERENCES salaries (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

SELECT *  FROM departments;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name 
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

SELECT first_name, last_name 
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1955-12-31';

-- Retirement Eligibility 
-- Which conditions are being selected 
SELECT first_name, last_name 
-- Which table data is being queried 
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31'); 

-- Number of Employees retiring 
-- Count function pulls the #
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Creating a New Table for retirement_info
SELECT first_name, last_name
-- Tells Postgres to save data into a table named reitrement_info 
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Syntax to pull the table
SELECT * FROM retirement_info;

-- New table for retirement employees sorted by department 
-- Dropping retirement_info table. No CASCADE needed since the table has no connections.
DROP TABLE retirement_info; 
SELECT emp_no, first_name, last_name 
INTO retirement_info 
FROM employees 
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check table 
SELECT * FROM retirement_info; 

---- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
-- to shorten the syntax we can assign nicknames using the as statements in this part of the code
-- ex. departments as d 
FROM departments as d
INNER JOIN dept_manager as dm 
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no, 
	ri.first_name, 
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de 
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
-- Check table 
SELECT * FROM current_emp

-- Joining current_emp and dept_emp tables 
SELECT COUNT(ce.emp_no), de.dept_no 
INTO retirement_employee_departments
FROM current_emp as ce 
-- We used left join query we wanted all employee numbers from Table 1 to be included in the returned data 
LEFT Join dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
-- Orders the groups by department #
ORDER BY de.dept_no;
-- Table check
SELECT * FROM retirement_employee_departments

-- Check Salary 
SELECT * FROM salaries
--DESC is descending 
ORDER BY to_date DESC;

-- List 1: Employee Information 
SELECT e.emp_no,
e.first_name, 
e.last_name, 
e.gender, 
s.salary, 
de.to_date   
-- INTO emp_info
FROM employees as e
-- inner join returns data from both tables 
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de 
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List 2: Management 
SELECT dm.dept_no, d.dept_name, dm.emp_no, ce.last_name, ce.first_name , dm.from_date, dm.to_date
-- INTO manager_info 
FROM dept_manager as dm
INNER JOIN departments as d 
ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp as ce 
ON (dm.emp_no = ce.emp_no);

-- List 3: Department Retirees 
SELECT ce.emp_no, ce.first_name, ce.last_name, d.dept_name 
-- INTO dept_info
FROM current_emp as ce 
INNER JOIN dept_emp as de 
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d 
ON (de.dept_no = d.dept_no); 

-- 7.3.6 Tailored list 

-- List for Sales Team 
SELECT ce.emp_no, ce.first_name, ce.last_name, d.dept_name 
-- INTO sales_team
FROM current_emp as ce 
INNER JOIN dept_emp as de 
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d 
ON (de.dept_no = d.dept_no)
WHERE d.dept_name = ('Sales');

--List for Sales + Development teams: 
SELECT ce.emp_no, ce.first_name, ce.last_name, d.dept_name 
-- INTO sales_developement_teams_list 
FROM current_emp as ce 
INNER JOIN dept_emp as de 
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d 
ON (de.dept_no = d.dept_no)
-- IN statement used to look for multiple conditions at once 
WHERE d.dept_name IN ('Sales','Development');

-- Deliverable 1 --
SELECT e.emp_no, e.first_name, e.last_name, ti.title, ti.from_date, ti.to_date
INTO retirement_titles 
FROM employees as e 
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no) 
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
ORDER BY e.emp_no;
-- Check Table --
SELECT * FROM retirement_titles

-- Unique Titles --
SELECT DISTINCT ON (rt.emp_no) rt.emp_no, rt.first_name, rt.last_name, rt.title
INTO unique_titles	
FROM retirement_titles as rt
ORDER BY rt.emp_no ASC,rt.to_date DESC;

-- Retiring Titles -- 
SELECT COUNT(ut.title), ut.title 
INTO retiring_titles 
FROM unique_titles as ut
GROUP BY ut.title 
ORDER BY COUNT DESC;

-- Deliverable 2 --
-- Use Dictinct with Orderby to remove duplicate rows

SELECT DISTINCT ON (e.emp_no) e.emp_no, e.first_name, e.last_name, e.birth_date, 
de.from_date, de.to_date, ti.title
INTO mentorship_eligibility 
FROM employees as e 
JOIN dept_emp as de 
ON (e.emp_no = de.emp_no)
JOIN titles as ti 
ON (ti.emp_no = e.emp_no )
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no, de.to_date DESC;
-- Check Table --
SELECT * FROM mentorship_eligibility 