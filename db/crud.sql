-- Create table "students"
CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    age INTEGER
);

-- Insert data into "students" table
INSERT INTO students (name, age) VALUES ('John', 20);
INSERT INTO students (name, age) VALUES ('Jane', 22);

-- Select all rows from "students" table
SELECT * FROM students;

-- Update age of a student
UPDATE students SET age = 25 WHERE id = 1;

-- Select all rows from "students" table again
SELECT * FROM students;

-- Delete a student
DELETE FROM students WHERE id = 2;

-- Select all rows from "students" table once more
SELECT * FROM students;
