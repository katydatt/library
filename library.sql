CREATE DATABASE library;

\c library

CREATE TABLE books(
  id SERIAL4 PRIMARY KEY,
  title VARCHAR(300),
  author VARCHAR(300),
  year VARCHAR(50),
  cover VARCHAR(2000),
  page_count INTEGER,
  notes VARCHAR(10000),
  isbn VARCHAR(50),
  department VARCHAR(50),
  ratings VARCHAR(50),
  category_id INTEGER
);

SELECT * FROM books;

CREATE TABLE categories(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

INSERT INTO categories (name) VALUES ('Arts & Disciplines');
INSERT INTO categories (name) VALUES ('Biography & Autobiography');
INSERT INTO categories (name) VALUES ('Business & Economics');
INSERT INTO categories (name) VALUES ('Juvenile Fiction');
INSERT INTO categories (name) VALUES ('Fiction');
INSERT INTO categories (name) VALUES ('History');
INSERT INTO categories (name) VALUES ('Nonfiction');
INSERT INTO categories (name) VALUES ('Drama');
INSERT INTO categories (name) VALUES ('Technology & Engineering');


CREATE TABLE users (
  id SERIAL4 PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  date_of_birth VARCHAR(50),
  address VARCHAR(50),
  city VARCHAR(50),
  email VARCHAR(50) NOT NULL,
  password_digest VARCHAR(400) NOT NULL
);


CREATE TABLE comments(
  id SERIAL4 PRIMARY KEY,
  body VARCHAR(1000) NOT NULL,
  book_id INTEGER,
  user_id INTEGER
);

CREATE TABLE likes(
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER,
  book_id INTEGER
);
