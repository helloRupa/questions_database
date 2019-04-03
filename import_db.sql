PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(250) NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_id INTEGER,
    author_id INTEGER NOT NULL,
    body TEXT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ('Arty', 'Archer'),
    ('Bartelby', 'Bunson'),
    ('Charlie', 'Cats');

INSERT INTO
    questions (title, body, author_id)
VALUES
    ('Arty Question?', 'This is Arty question body.', (SELECT id FROM users WHERE fname = 'Arty')),
    ('Bartelby Question?', 'This is Bartelby question body.', (SELECT id FROM users WHERE fname = 'Bartelby')),
    ('Charlie Question?', 'This is Charlie question body.', (SELECT id FROM users WHERE fname = 'Charlie')),
    ('Arty Question2?', 'This is Arty question2 body.', (SELECT id FROM users WHERE fname = 'Arty'));

INSERT INTO
    question_follows (question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE title = 'Arty Question?'), (SELECT id FROM users WHERE fname = 'Bartelby')),
    ((SELECT id FROM questions WHERE title = 'Bartelby Question?'), (SELECT id FROM users WHERE fname = 'Charlie')),
    ((SELECT id FROM questions WHERE title = 'Arty Question?'), (SELECT id FROM users WHERE fname = 'Charlie')),
    ((SELECT id FROM questions WHERE title = 'Charlie Question?'), (SELECT id FROM users WHERE fname = 'Arty')),
    ((SELECT id FROM questions WHERE title = 'Arty Question2?'), (SELECT id FROM users WHERE fname = 'Arty'));

INSERT INTO
    replies (question_id, parent_id, author_id, body)
VALUES
    ((SELECT id FROM questions WHERE title = 'Arty Question?'), NULL, (SELECT id FROM users WHERE fname = 'Bartelby'), 'Arty Q reply 1 from Bartelby.'),
    ((SELECT id FROM questions WHERE title = 'Arty Question?'), 1, (SELECT id FROM users WHERE fname = 'Charlie'), 'Arty Q reply 2 from Charlie.'),
    ((SELECT id FROM questions WHERE title = 'Bartelby Question?'), NULL, (SELECT id FROM users WHERE fname = 'Arty'), 'Bartelby Q reply 1 from Arty.');

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Arty'), (SELECT id FROM questions WHERE title = 'Charlie Question?')),
    ((SELECT id FROM users WHERE fname = 'Arty'), (SELECT id FROM questions WHERE title = 'Bartelby Question?')),
    ((SELECT id FROM users WHERE fname = 'Bartelby'), (SELECT id FROM questions WHERE title = 'Charlie Question?')),
    ((SELECT id FROM users WHERE fname = 'Charlie'), (SELECT id FROM questions WHERE title = 'Arty Question?'));
    