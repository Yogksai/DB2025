
-- Part A: Database and Table Setup


-- 1. 
CREATE DATABASE advanced_lab;
\c advanced_lab;

--
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'General',
    salary INT DEFAULT 40000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

-- 
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

-- 
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    start_date DATE,
    end_date DATE,
    budget INT
);


-- Part B: Advanced INSERT Operations


-- 2. 
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Yerassyl', 'Kadyrzhan', 'KBTU');

-- 3. 
INSERT INTO employees (first_name, last_name, hire_date)
VALUES ('Yerassyl', 'Kadyrzhan', CURRENT_DATE);

-- 4. 
INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('KBTU', 50000, 1),
       ('Dep1', 100000, 2),
       ('Dep2', 150000, 3);

-- 5. 
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Yerassyl', 'Kadyrzhan', 'KBTU', 50000 * 1.1, CURRENT_DATE);

-- 6. 
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';


-- Part C: Complex UPDATE Operations


-- 7.
UPDATE employees SET salary = salary * 1.1;

-- 8.
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. 
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10.
UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';

-- 11.
UPDATE departments d
SET budget = (SELECT AVG(salary) * 1.2 FROM employees e WHERE e.department = d.dept_name);

-- 12. 
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- Part D: Advanced DELETE Operations
-- 13.
DELETE FROM employees WHERE status = 'Terminated';

-- 14.
DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- 15.
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT department FROM employees WHERE department IS NOT NULL
);

-- 16. 
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E: Operations with NULL Values


-- 17. 
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('NullUser', 'Test', NULL, NULL);

-- 18.
UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;

-- 19. 
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;


-- Part F: RETURNING Clause Operations


-- 20.
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Era', 'Madi', 'Nurik', 55000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21. 
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- 22.
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G: Advanced DML Patterns


-- 23. 
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Yerassyl', 'Kadyrzhan', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Yerassyl' AND last_name = 'Kadyrzham'
);

-- 24.
UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
    THEN salary * 1.1
    ELSE salary * 1.05
END;

-- 25.
INSERT INTO employees (first_name, last_name, department, salary, hire_date) VALUES
('Emp1','Test','Sales',45000,CURRENT_DATE),
('Emp2','Test','Sales',46000,CURRENT_DATE),
('Emp3','Test','Sales',47000,CURRENT_DATE),
('Emp4','Test','Sales',48000,CURRENT_DATE),
('Emp5','Test','Sales',49000,CURRENT_DATE);

UPDATE employees SET salary = salary * 1.1
WHERE last_name = 'Test';

-- 26.
CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;

INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';

-- 27. 
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (SELECT COUNT(*) FROM employees e WHERE e.department = p.dept_id) > 3;
