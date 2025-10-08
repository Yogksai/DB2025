

-- Part 1
-- 1.1
SELECT first_name || ' ' || last_name AS full_name, department, salary FROM employees;

-- 1.2
SELECT DISTINCT department FROM employees;

-- 1.3
SELECT project_name, budget,
  CASE
    WHEN budget > 150000 THEN 'Large'
    WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
    ELSE 'Small'
  END AS budget_category
FROM projects;

-- 1.4
SELECT first_name || ' ' || last_name AS full_name,
       COALESCE(email, 'No email provided') AS email
FROM employees;

-- Part 2
-- 2.1
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- 2.2
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- 2.3
SELECT first_name, last_name
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

-- 2.4
SELECT first_name, last_name, manager_id, department
FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

-- Part 3
-- 3.1
SELECT UPPER(first_name || ' ' || last_name) AS full_name_upper,
       LENGTH(last_name) AS last_name_length,
       SUBSTRING(COALESCE(email, '') FROM 1 FOR 3) AS email_prefix
FROM employees;

-- 3.2
SELECT first_name || ' ' || last_name AS full_name,
       salary AS annual_salary,
       ROUND(salary / 12, 2) AS monthly_salary,
       ROUND(salary * 0.10, 2) AS raise_amount
FROM employees;

-- 3.3
SELECT format('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_info
FROM projects;

-- 3.4
SELECT first_name || ' ' || last_name AS full_name,
       DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;

-- Part 4
-- 4.1
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department;

-- 4.2
SELECT p.project_name, SUM(a.hours_worked) AS total_hours
FROM projects p
LEFT JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name;

-- 4.3
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- 4.4
SELECT MAX(salary) AS max_salary,
       MIN(salary) AS min_salary,
       SUM(salary) AS total_payroll
FROM employees;

-- Part 5
-- 5.1
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000
UNION
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- 5.2
SELECT employee_id, first_name, last_name, department, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name, last_name, department, salary
FROM employees
WHERE salary > 65000;

-- 5.3
SELECT employee_id, first_name || ' ' || last_name AS full_name
FROM employees
EXCEPT
SELECT e.employee_id, e.first_name || ' ' || e.last_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;

-- Part 6
-- 6.1
SELECT e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
  SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id
);

-- 6.2
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
WHERE e.employee_id IN (
  SELECT a.employee_id
  FROM assignments a
  JOIN projects p ON a.project_id = p.project_id
  WHERE p.status = 'Active'
);

-- 6.3
SELECT first_name, last_name, salary
FROM employees
WHERE salary > ANY (
  SELECT salary FROM employees WHERE department = 'Sales'
);

-- Part 7
-- 7.1
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.department,
       ROUND(AVG(a.hours_worked), 2) AS avg_hours,
       RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS rank_in_dept
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary;

-- 7.2
SELECT p.project_name,
       SUM(a.hours_worked) AS total_hours,
       COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;

-- 7.3
WITH dept_stats AS (
  SELECT department,
         COUNT(*) AS total_employees,
         ROUND(AVG(salary), 2) AS avg_salary,
         MAX(salary) AS max_salary
  FROM employees
  GROUP BY department
),
highest_paid AS (
  SELECT DISTINCT ON (department)
    department,
    first_name || ' ' || last_name AS highest_paid_name,
    salary
  FROM employees
  ORDER BY department, salary DESC
)
SELECT d.department,
       d.total_employees,
       d.avg_salary,
       h.highest_paid_name,
       GREATEST(d.avg_salary, d.max_salary) AS greatest_value,
       LEAST(d.avg_salary, d.max_salary) AS least_value
FROM dept_stats d
LEFT JOIN highest_paid h ON d.department = h.department;
