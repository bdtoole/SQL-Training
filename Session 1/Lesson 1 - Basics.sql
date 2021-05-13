/* DDL - Data Definition Language */
--Used to create database objects (schemas, tables, procedures, users)

/* DML - Data Manipulation Language */
--Used to insert, update, delete data

--What about SELECT?


/* Construction of a SELECT statement */
  SELECT --Required - list of columns/expressions returned ("what")
DISTINCT --Optional - remove duplicates ("which")
     TOP --Optional - Further exclude results ("which/limit")
    FROM --"Optional" - source to pull the data from ("where")
    JOIN --"Optional" - source to pull the data from ("where")
   WHERE --Optional - filter criteria ("which")
GROUP BY --Optional - group data for aggregation ("which")
  HAVING --Optional - refining of groups ("which")
ORDER BY --Optional - Ordering of results ("how")

--What about the order of execution?