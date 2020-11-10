#!/usr/bin/env tarantool

local tap = require('tap')

local test = tap.test('gh-5231-box-execute-writes-in-ro')
local expected_err = "Can't modify data because this instance is in read-only mode."

box.cfg()
box.execute("CREATE TABLE TEST (A INT, B INT, PRIMARY KEY (A))")
local res, err = box.execute("INSERT INTO TEST (A, B) VALUES (3, 3)")
box.cfg{read_only = true}

test:plan(9)

res, err = box.execute("INSERT INTO TEST (A, B) VALUES (1, 1)")
test:is(
    tostring(err),
    expected_err,
    "insert should fail in read-only mode"
)
res, err = box.execute("DELETE FROM TEST")
test:is(
    tostring(err),
    expected_err,
    "delete should fail in read-only mode"
)
res, err = box.execute("REPLACE INTO TEST VALUES (1, 2)")
test:is(
    tostring(err),
    expected_err,
    "replace should fail in read-only mode"
)
res, err = box.execute("UPDATE TEST SET B=4 WHERE A=3")
test:is(
    tostring(err),
    expected_err,
    "update should fail in read-only mode"
)
res, err = box.execute("TRUNCATE TABLE TEST")
test:is(
    tostring(err), 
    expected_err,
    "truncate should fail in read-only mode"
)
box.execute("CREATE TABLE TEST2 (A INT, PRIMARY KEY (A))")
test:is(
    tostring(err),
    expected_err,
    "create should fail in read-only mode"
)
box.execute("ALTER TABLE TEST ADD CONSTRAINT 'uk' UNIQUE (B)")
test:is(
    tostring(err),
    expected_err,
    "add constraint should fail in read-only mode"
)
box.execute("ALTER TABLE TEST RENAME TO TEST2")
test:is(
    tostring(err),
    expected_err,
    "rename should fail in read-only mode"
)
res, err = box.execute("DROP TABLE TEST")
test:is(
    tostring(err),
    expected_err,
    "drop table should fail in read-only mode"
)

-- cleanup
box.cfg{read_only=false}
res, err = box.execute("DROP TABLE TEST")

os.exit(test:check() and 0 or 1)
