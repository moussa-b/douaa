-- SQL Export
-- Created by Querious (402014)
-- Created: 13 February 2026 at 23:41:28 CET
-- Encoding: Unicode (UTF-8)


PRAGMA foreign_keys = OFF;

PRAGMA ignore_check_constraints = OFF;





CREATE TABLE "category" (
  "id" INTEGER NOT NULL PRIMARY KEY,
  "name" TEXT
);


CREATE TABLE "sub_category" (
  "id" INTEGER NOT NULL PRIMARY KEY,
  "name" TEXT
);


CREATE TABLE "douaa" (
  "id" INTEGER NOT NULL PRIMARY KEY,
  "category_id" INTEGER DEFAULT NULL,
  "sub_category_id" INTEGER DEFAULT NULL,
  "douaa_ar" TEXT DEFAULT NULL,
  "douaa_fr" TEXT DEFAULT NULL,
  "reference" TEXT DEFAULT NULL,
  "tags" TEXT DEFAULT NULL, is_favorite INTEGER DEFAULT 0,
  FOREIGN KEY ("category_id") REFERENCES "category" ("id"),
  FOREIGN KEY ("sub_category_id") REFERENCES "sub_category" ("id")
);






PRAGMA foreign_keys = ON;

PRAGMA ignore_check_constraints = ON;



--  Export Finished: 13 February 2026 at 23:41:28 CET
