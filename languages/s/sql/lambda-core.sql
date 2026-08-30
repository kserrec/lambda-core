.bail on
.headers off
.mode list

PRAGMA foreign_keys = ON;

-- SQLite has no first-class functions. A Church boolean is represented by the
-- branch it selects, and the views below implement the same selection rules as
-- the lambda terms.
CREATE TEMP TABLE church_boolean (
    name TEXT PRIMARY KEY,
    selected_branch TEXT NOT NULL
        CHECK (selected_branch IN ('first', 'second'))
);

-- TRUE = λx.λy.x; FALSE = λx.λy.y
INSERT INTO church_boolean (name, selected_branch) VALUES
    ('TRUE', 'first'),
    ('FALSE', 'second');

-- NOT = λb.b FALSE TRUE
CREATE TEMP VIEW church_not AS
SELECT
    name AS input_name,
    CASE selected_branch
        WHEN 'first' THEN 'second'
        ELSE 'first'
    END AS selected_branch
FROM church_boolean;

-- AND = λp.λq.p q FALSE
CREATE TEMP VIEW church_and AS
SELECT
    left_boolean.name AS left_name,
    right_boolean.name AS right_name,
    CASE left_boolean.selected_branch
        WHEN 'first' THEN right_boolean.selected_branch
        ELSE 'second'
    END AS selected_branch
FROM church_boolean AS left_boolean
CROSS JOIN church_boolean AS right_boolean;

-- OR = λp.λq.p TRUE q
CREATE TEMP VIEW church_or AS
SELECT
    left_boolean.name AS left_name,
    right_boolean.name AS right_name,
    CASE left_boolean.selected_branch
        WHEN 'first' THEN 'first'
        ELSE right_boolean.selected_branch
    END AS selected_branch
FROM church_boolean AS left_boolean
CROSS JOIN church_boolean AS right_boolean;

-- The CHECK constraint turns every displayed example into an assertion.
CREATE TEMP TABLE boolean_result (
    label TEXT PRIMARY KEY,
    display_order INTEGER NOT NULL UNIQUE,
    actual_branch TEXT NOT NULL,
    expected_branch TEXT NOT NULL,
    CHECK (actual_branch = expected_branch)
);

INSERT INTO boolean_result
SELECT 'TRUE', 1, selected_branch, 'first'
FROM church_boolean WHERE name = 'TRUE';

INSERT INTO boolean_result
SELECT 'FALSE', 2, selected_branch, 'second'
FROM church_boolean WHERE name = 'FALSE';

INSERT INTO boolean_result
SELECT 'NOT TRUE', 3, selected_branch, 'second'
FROM church_not WHERE input_name = 'TRUE';

INSERT INTO boolean_result
SELECT 'NOT FALSE', 4, selected_branch, 'first'
FROM church_not WHERE input_name = 'FALSE';

INSERT INTO boolean_result
SELECT left_name || ' AND ' || right_name,
       CASE left_name || ':' || right_name
           WHEN 'FALSE:FALSE' THEN 5
           WHEN 'FALSE:TRUE' THEN 6
           WHEN 'TRUE:FALSE' THEN 7
           ELSE 8
       END,
       selected_branch,
       CASE
           WHEN left_name = 'TRUE' AND right_name = 'TRUE' THEN 'first'
           ELSE 'second'
       END
FROM church_and;

INSERT INTO boolean_result
SELECT left_name || ' OR ' || right_name,
       CASE left_name || ':' || right_name
           WHEN 'FALSE:FALSE' THEN 9
           WHEN 'FALSE:TRUE' THEN 10
           WHEN 'TRUE:FALSE' THEN 11
           ELSE 12
       END,
       selected_branch,
       CASE
           WHEN left_name = 'FALSE' AND right_name = 'FALSE' THEN 'second'
           ELSE 'first'
       END
FROM church_or;

-- A Church numeral applies its function n times. SQL represents that repeated
-- application as n related rows; ZERO therefore has no application rows.
CREATE TEMP TABLE church_numeral (
    name TEXT PRIMARY KEY
);

CREATE TEMP TABLE church_application (
    numeral_name TEXT NOT NULL REFERENCES church_numeral(name),
    ordinal INTEGER NOT NULL CHECK (ordinal > 0),
    PRIMARY KEY (numeral_name, ordinal)
);

-- SUCC copies an input application chain and appends one application.
CREATE TEMP TABLE successor_request (
    input_name TEXT NOT NULL REFERENCES church_numeral(name),
    output_name TEXT NOT NULL UNIQUE
);

CREATE TEMP TRIGGER apply_successor
AFTER INSERT ON successor_request
BEGIN
    INSERT INTO church_numeral (name) VALUES (NEW.output_name);

    INSERT INTO church_application (numeral_name, ordinal)
    SELECT NEW.output_name, ordinal
    FROM church_application
    WHERE numeral_name = NEW.input_name;

    INSERT INTO church_application (numeral_name, ordinal)
    SELECT NEW.output_name, COALESCE(MAX(ordinal), 0) + 1
    FROM church_application
    WHERE numeral_name = NEW.input_name;
END;

-- PRED copies every application except the final one. For ZERO, there are no
-- rows to copy, so the result remains ZERO as required.
CREATE TEMP TABLE predecessor_request (
    input_name TEXT NOT NULL REFERENCES church_numeral(name),
    output_name TEXT NOT NULL UNIQUE
);

CREATE TEMP TRIGGER apply_predecessor
AFTER INSERT ON predecessor_request
BEGIN
    INSERT INTO church_numeral (name) VALUES (NEW.output_name);

    INSERT INTO church_application (numeral_name, ordinal)
    SELECT NEW.output_name, ordinal
    FROM church_application
    WHERE numeral_name = NEW.input_name
      AND ordinal < COALESCE(
          (SELECT MAX(last.ordinal)
           FROM church_application AS last
           WHERE last.numeral_name = NEW.input_name),
          0
      );
END;

-- ZERO = λf.λx.x; ONE = SUCC ZERO
INSERT INTO church_numeral (name) VALUES ('ZERO');
INSERT INTO successor_request VALUES ('ZERO', 'ONE');
INSERT INTO successor_request VALUES ('ONE', 'TWO');
INSERT INTO successor_request VALUES ('TWO', 'THREE');

INSERT INTO predecessor_request VALUES ('ZERO', 'PRED ZERO');
INSERT INTO predecessor_request VALUES ('ONE', 'PRED ONE');
INSERT INTO predecessor_request VALUES ('TWO', 'PRED TWO');
INSERT INTO predecessor_request VALUES ('THREE', 'PRED THREE');

CREATE TEMP VIEW church_to_integer AS
SELECT numeral.name, COUNT(application.ordinal) AS native_value
FROM church_numeral AS numeral
LEFT JOIN church_application AS application
    ON application.numeral_name = numeral.name
GROUP BY numeral.name;

CREATE TEMP TABLE numeral_result (
    label TEXT PRIMARY KEY,
    display_order INTEGER NOT NULL UNIQUE,
    actual_value INTEGER NOT NULL,
    expected_value INTEGER NOT NULL,
    CHECK (actual_value = expected_value)
);

INSERT INTO numeral_result
SELECT 'ZERO', 1, native_value, 0
FROM church_to_integer WHERE name = 'ZERO';

INSERT INTO numeral_result
SELECT 'ONE', 2, native_value, 1
FROM church_to_integer WHERE name = 'ONE';

INSERT INTO numeral_result
SELECT 'SUCC ONE', 3, native_value, 2
FROM church_to_integer WHERE name = 'TWO';

INSERT INTO numeral_result
SELECT 'SUCC (SUCC ONE)', 4, native_value, 3
FROM church_to_integer WHERE name = 'THREE';

INSERT INTO numeral_result
SELECT 'PRED ZERO', 5, native_value, 0
FROM church_to_integer WHERE name = 'PRED ZERO';

INSERT INTO numeral_result
SELECT 'PRED ONE', 6, native_value, 0
FROM church_to_integer WHERE name = 'PRED ONE';

INSERT INTO numeral_result
SELECT 'PRED (SUCC ONE)', 7, native_value, 1
FROM church_to_integer WHERE name = 'PRED TWO';

INSERT INTO numeral_result
SELECT 'PRED (SUCC (SUCC ONE))', 8, native_value, 2
FROM church_to_integer WHERE name = 'PRED THREE';

.print CHURCH BOOLEANS
SELECT label || ': ' ||
       CASE actual_branch WHEN 'first' THEN 'true' ELSE 'false' END
FROM boolean_result
ORDER BY display_order;

.print CHURCH NUMERALS
SELECT label || ': ' || actual_value
FROM numeral_result
ORDER BY display_order;
