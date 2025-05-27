--- 65. Show the position of letter 'n' in the insulin_metformnin column.Replace blank values to Unknown.
----    List only distinct values.Hint:'n' is not case sensitive
SELECT DISTINCT
	-- Replace empty strings with 'Unknown', otherwise return the original value
	COALESCE(NULLIF(INSULIN_METFORMNIN, ''), 'Unknown') AS INSULIN_METFORMNIN_CLEANED,

	-- Find the position of the letter 'n' (case-insensitive) in the cleaned value
	POSITION(
		'n' IN LOWER(
			COALESCE(NULLIF(INSULIN_METFORMNIN, ''), 'Unknown')  -- Same logic used above
		)
	) AS N_POSITION

FROM
	GLUCOSE_TESTS;

----66.Create a function to load data from an existing table into a new table, inserting records in batches of 100.
DROP TABLE demo_temptable1

CREATE TABLE IF NOT EXISTS demo_temptable1 AS
SELECT * FROM demographics LIMIT 0;
-------Create a function to insert data into table

CREATE OR REPLACE FUNCTION load_data_in_batches()
RETURNS void 
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size INTEGER := 100;         -- Number of rows to insert in each batch
    last_id INTEGER := 0;              -- Tracks the last participant_id inserted
    rows_inserted INTEGER := 0;        -- Tracks how many rows were inserted in the last batch
BEGIN
    LOOP
        -- Use a Common Table Expression (CTE) to insert a batch of rows and return inserted IDs
        WITH ins AS (
            INSERT INTO demo_temptable1
            SELECT * 
            FROM demographics
            WHERE participant_id > last_id         -- Get only rows not yet inserted
            ORDER BY participant_id
            LIMIT batch_size                       -- Limit the number of rows per batch
            RETURNING participant_id               -- Return inserted IDs so we can track progress
        )
        
        -- Count how many rows were inserted and get the highest participant_id from this batch
        SELECT 
            COUNT(*), 
            COALESCE(MAX(participant_id), last_id)  -- If nothing was inserted, keep last_id unchanged
        INTO 
            rows_inserted, 
            last_id
        FROM ins;

        -- Exit the loop if no more rows were inserted
        EXIT WHEN rows_inserted = 0;
    END LOOP;
END;
$$;


--- call function
SELECT load_data_in_batches();

select * from demo_temptable1;

----67.Compare the average change in hemoglobin levels based on ethnicity using window function. 

SELECT 
    d.ethnicity,                            
    b.hb_change_percent,                                                         
    AVG(b.hb_change_percent) 
        OVER (PARTITION BY d.ethnicity)    -- Window function to compute average per ethnicity
        AS avg_hb_change_by_ethnicity
FROM 
    demographics d                        
INNER JOIN 
    biomarkers b                           
    ON d.participant_id = b.participant_id;

	
---68. List all the participants whose expected Delivery Date  is Weekend.
SELECT
	EDD_V1,
	TO_CHAR(EDD_V1, 'day') AS WEEKDAY  ---returns name of the day
FROM
	PREGNANCY_INFO
WHERE     
	LOWER(TRIM(TO_CHAR(EDD_V1, 'Day'))) IN ('saturday', 'sunday');  

---69.Calculate the percentage of GDM patients using only insulin medication
SELECT
	ROUND(AVG(
		CASE
			WHEN INSULIN_METFORMNIN = 'Insulin' THEN 1     --calculate avg using insulin of gdm patients
			ELSE 0
		END
	) * 100,2) AS INSULIN_PERCENTAGE
FROM
	GLUCOSE_TESTS
	WHERE diagnosed_gdm = 1;
	
---70.Compare Ultrasound delivery date and edd by Lmp and Graph the Stacked Line chart.	
SELECT
	P.PARTICIPANT_ID,
	P.EDD_V1,
	D."US EDD" AS ULTRASOUND_DATE,
	P.EDD_CONSISTENT_WITH_LMP,
	 (P.EDD_V1 -"US EDD" ) AS DATE_DIFFERENCE
	FROM
	PREGNANCY_INFO P
	JOIN DOCUMENTATION_TRACK D ON P.PARTICIPANT_ID = D.PARTICIPANT_ID
ORDER BY
	P.PARTICIPANT_ID;

---71. What proportion of participants diagnosed with gestational diabetes mellitus (GDM) have a family or their own previous history of the condition ?

WITH diagnosed AS (
  SELECT
    gt.participant_id,
    COALESCE(s.previous_gdm, 0) AS previous_gdm,
    COALESCE(dm.family_history, 0) AS family_history
  FROM glucose_tests gt
  LEFT JOIN screening s ON gt.participant_id = s.participant_id
  LEFT JOIN demographics dm ON gt.participant_id = dm.participant_id
  WHERE gt.diagnosed_gdm = 1
)
SELECT
  COUNT(*) AS total_diagnosed,
  COUNT(*) FILTER (
    WHERE previous_gdm = 1 OR family_history = 1
  ) AS with_previous_history,
  ROUND(
    COUNT(*) FILTER (
      WHERE previous_gdm = 1 OR family_history = 1
    ) * 100.0 / COUNT(*),
    2
  ) AS percentage_with_history
FROM diagnosed;


/*72)....1. Create a backup of the demographic table that is accessible only for the current session..
2. In a new session ,display the name of the  schema name and backup table ,created (Attach Both the screen shots)*/
 ------create temporary table
CREATE TEMP TABLE demographic_backup AS
SELECT * FROM demographics;
-----get schemaname and table name -----
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename = 'demographic_backup'; 	

----73.What percentage of participants diagnosed with gestational diabetes mellitus (GDM) are using insulin, 
-----insulin & metformin and no-medication?

select 
CASE 
WHEN insulin_metformnin = 'Insulin' THEN 'insulin'
WHEN insulin_metformnin = 'MetforminInsulin' Then 'insulin & metformin'
WHEN insulin_metformnin = 'No'  THEN 'no-medication'
ELSE 'other'
END,
count(*) as no_of_pepole,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage,
insulin_metformnin from glucose_tests
where diagnosed_gdm = 1 
group by insulin_metformnin;

---74.What are the ways to optimize  below Query.
select * from 
public.pregnancy_info p, public.demographics d
where extract (year from edd_v1)='2015'
and p.participant_id=d.participant_id and d.ethnicity='White' ;

---using joins and between 
select p.participant_id, p.edd_v1, d.ethnicity from 
pregnancy_info p 
JOIN demographics d ON p.participant_id=d.participant_id
Where  extract (year from edd_v1)='2015' AND d.ethnicity='White';

select p.participant_id, p.edd_v1, d.ethnicity from 
pregnancy_info p 
JOIN demographics d ON p.participant_id=d.participant_id
WHERE p.edd_v1 >= '2015-01-01' AND p.edd_v1 < '2016-01-01'
  AND d.ethnicity = 'White';


select p.participant_id, p.edd_v1, d.ethnicity from 
pregnancy_info p 
JOIN demographics d ON p.participant_id=d.participant_id 
WHERE d.ethnicity = 'White'AND
edd_v1 BETWEEN '2015-01-01' AND '2015-12-31';

----75. Display preeclampsia occurrence across different gestational hypertension statuses using cross tab
---the crosstab function is used to create pivot tables, to access crosstab need to create tablefunc extention
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab(
    $$
    SELECT 
        s.ghp, 
        COALESCE(m."Pre-eclampsia"::TEXT, 'null') AS preeclampsia_status, 
        COUNT(*) 
    FROM screening s
    JOIN maternal_health_info m ON s.participant_id = m.participant_id
    GROUP BY s.ghp, preeclampsia_status
    ORDER BY 1, 2
    $$,
    $$VALUES ('1'), ('0'), ('null')$$
) AS ct (
    gestational_hypertension TEXT,
    preeclampsia_1 INT,
    preeclampsia_0 INT,
    preeclampsia_null INT
);
----76. Postgres supports extensibility for JSON querying. Prove it.

-----converting INFANT_OUTCOMES table to json ---
SELECT 
PARTICIPANT_ID,
json_build_object(
'weight' , birth_weight,
'apgar_1_min' , apgar_1_min,
'apgar_3_min', apgar_1_min,
'fracture', birth_injury_fracture)
As IO_JSON
FROM INFANT_OUTCOMES;
-------- using JSONB to convert table to JSON format ----
SELECT
	PARTICIPANT_ID,
	TO_JSONB(INFANT_OUTCOMES) AS IO_JSON
FROM
	INFANT_OUTCOMES;
------extracting json data using filters ------
SELECT
sample_data ->> 'name'  as name,
birth_weight
FROM
	INFANT_OUTCOMES 
WHERE birth_weight = '3.52'
AND sample_data ->> 'name' is not null;	

------- we can add json column in to table --- 
ALTER TABLE INFANT_OUTCOMES
ADD COLUMN sample_data JSON;

-----Inserting json data in to table ---
INSERT INTO INFANT_OUTCOMES( participant_id, apgar_1_min, birth_weight, sample_data)
VALUES('66', 9 , '3.52' , ' {"name": "new", "mom": "XYZ1", "notes": "healthy"}')

-----77.Display participants whose Vitamin D levels decreased by more than 50% between visit 1 and visit 3.
SELECT
	"25 OHD_V1" as VitaminD_v1,
	"25 OHD_V3" as VitaminD_v3
FROM
	BIOMARKERS
WHERE
	"25 OHD_V1" IS NOT NULL
	AND "25 OHD_V3" IS NOT NULL
	AND (("25 OHD_V1" - "25 OHD_V3") / "25 OHD_V1") > 0.5;

---78. Among participants with elevated OGTT results, what are the highest, lowest, average HbA1c values at visit 3 ?

SELECT
	MAX(HBA1C_V3) as Highest_HBA1C_V3,
	MIN(HBA1C_V3) as lowest_HBA1C_V3,
	AVG(HBA1C_V3)  as avarage_HBA1C_V3
FROM
	GLUCOSE_TESTS
WHERE
	OGTT_HIGH_10 = 1
AND	HBA1C_V3 IS NOT NULL;

----79. Create a stored procedure to fetch past and current GDM status and their birth outcome.
----Call the procedure recursively. If the participant GDM is 'Yes'.

DROP PROCEDURE  IF EXISTS gdm_status_cursor

CREATE OR REPLACE PROCEDURE gdm_status_cursor()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor to fetch all participants with diagnosed_gdm = 1
    gdm_cursor CURSOR FOR
        SELECT 
            p.participant_id, 
            p."Still-birth", 
            g.diagnosed_gdm, 
            s.previous_gdm
        FROM pregnancy_info p 
        JOIN glucose_tests g ON p.participant_id = g.participant_id 
        JOIN screening s ON p.participant_id = s.participant_id
        WHERE g.diagnosed_gdm = 1
		ORDER BY  p.participant_id;

    -- Variables to hold each row's values
    v_participant_id INT;
    v_still_birth TEXT;
    v_diagnosed_gdm INT;
    v_previous_gdm INT;
BEGIN
    OPEN gdm_cursor;

    LOOP
        FETCH gdm_cursor INTO v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
        EXIT WHEN NOT FOUND;
        -- Process each participant here (e.g., print/log values)
        RAISE NOTICE 'Participant: %, Still-birth: %, GDM: %, Previous GDM: %',
            v_participant_id, v_still_birth, v_diagnosed_gdm, v_previous_gdm;
    END LOOP;
	
    CLOSE gdm_cursor;
END;
$$;
----- call stored procedure ----
CALL gdm_status_cursor();

----80. Generate Pie chart to display patient count  with GDM ,Non GDM 
SELECT 
Case 
WHEN diagnosed_gdm = 1 THEN 'with_GDM'
WHEN diagnosed_gdm = 0 THEN  'Non_GDM'
END AS GDM_Status,
COUNT(*) AS patient_count
FROM glucose_tests
Where diagnosed_gdm is not null
Group By GDM_Status ;


