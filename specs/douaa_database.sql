-- SQL Export
-- Created by Querious (402014)
-- Created: 18 February 2026 at 10:18:11 CET
-- Encoding: Unicode (UTF-8)

PRAGMA
foreign_keys = OFF;

PRAGMA
ignore_check_constraints = OFF;

CREATE TABLE "category"
(
    "id"         INTEGER NOT NULL DEFAULT 0,
    "name"       TEXT             DEFAULT NULL,
    "sort_order" INTEGER          DEFAULT NULL
);

CREATE TABLE "sub_category"
(
    "id"        INTEGER NOT NULL PRIMARY KEY,
    "name"      TEXT,
    category_id INTEGER REFERENCES category (id)
);

CREATE TABLE "douaa"
(
    "id"              INTEGER NOT NULL PRIMARY KEY,
    "category_id"     INTEGER DEFAULT NULL,
    "sub_category_id" INTEGER DEFAULT NULL,
    "douaa_ar"        TEXT    DEFAULT NULL,
    "douaa_fr"        TEXT    DEFAULT NULL,
    "reference"       TEXT    DEFAULT NULL,
    "tags"            TEXT    DEFAULT NULL,
    is_favorite       INTEGER DEFAULT 0,
    "read_count"      INTEGER DEFAULT 0,
    FOREIGN KEY ("category_id") REFERENCES "category" ("id"),
    FOREIGN KEY ("sub_category_id") REFERENCES "sub_category" ("id")
);

PRAGMA
foreign_keys = ON;

PRAGMA
ignore_check_constraints = ON;

--  Export Finished: 18 February 2026 at 10:18:11 CET
