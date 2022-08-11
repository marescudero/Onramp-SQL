WITH date_formatted AS (
  --formats date to YYYY-MM-DD
  SELECT date_added
  	,CASE WHEN TRIM(date_added) = '' THEN NULL
  		ELSE TO_DATE(
          			(year || 
                      '-' || 
                      CASE WHEN LEN(month) = 1 THEN 0 || month ELSE month END || -- adds leading 0 to single digits
                      '-' || 
                      CASE WHEN LEN(day) = 1 THEN 0 || day ELSE day END -- adds leading 0 to single digits
                      )
          ,'YYYY-MM-DD') 
       END AS formatted_date
  
  FROM (
      	SELECT DISTINCT date_added
    		,SPLIT_PART(date_added, '/', 1) AS month
            ,SPLIT_PART(date_added, '/', 2) AS day
            ,SPLIT_PART(date_added, '/', 3) AS year
          FROM "dev"."public"."k_jobs"
    )
),

location_formatted AS (
 --only cleanses and splits records into 3 fields that follow the city, state zip format (must have all 3)
  SELECT DISTINCT location 
    ,TRIM(REPLACE(SPLIT_PART(location, ',', 1),'Address', '')) AS city
  	,SUBSTRING(location, POSITION(',' IN location) + 2, 2) AS state
  	,REGEXP_SUBSTR(location,'([0-9][0-9][0-9][0-9][0-9])') AS zip
  FROM "dev"."public"."k_jobs" 
  WHERE location LIKE '%,%' 
    AND LEN(location) > 13 
    AND LEN(location) < 36
    AND zip != ''
),

salary_formatted AS (
  --splits salary into 4 fields min & max hrly/salary and removes anything that is not # or . and replaces blanks with NULLS
  SELECT salary 
  	,CAST(RTRIM(REGEXP_REPLACE(min_hrly_rate, '([^0-9\.]+)', '', 1, 'p'),'.') AS NUMERIC(9,2)) AS min_hrly_rate
  	,CAST(CASE WHEN max_hrly_rate  = '' THEN  NULL ELSE RTRIM(regexp_replace(max_hrly_rate, '([^0-9\.]+)', '', 1, 'p'), '.') END AS NUMERIC(9,2)) AS max_hrly_rate
  	,CAST(RTRIM(REGEXP_REPLACE(min_salary, '([^0-9\.]+)', '', 1, 'p'),'.') AS NUMERIC(9,2)) AS min_salary
    ,CAST((
      		CASE WHEN max_salary = '' THEN NULL 
  				WHEN RTRIM(regexp_replace(max_salary, '([^0-9\.]+)', '', 1, 'p'), '.') = '' THEN NULL 
        		ELSE RTRIM(regexp_replace(max_salary, '([^0-9\.]+)', '', 1, 'p'), '.')
        	END
      	) AS NUMERIC(9,2)) 
        AS max_salary
  FROM ( 
        SELECT DISTINCT salary
          ,SPLIT_PART((CASE WHEN salary LIKE '%/hour%' THEN salary END), '-', 1) AS min_hrly_rate
          ,SPLIT_PART((CASE WHEN salary LIKE '%/hour%' THEN salary END), '-', 2) AS max_hrly_rate
          ,SPLIT_PART((CASE WHEN salary LIKE '%/year%' THEN salary END), '-', 1) AS min_salary
          ,SPLIT_PART(SPLIT_PART((CASE WHEN salary LIKE '%/year%' THEN salary END), '-', 2),'/year',1) AS max_salary
        FROM "dev"."public"."k_jobs"
        WHERE min_hrly_rate IS NOT NULL OR min_salary IS NOT NULL
        )
  )

SELECT country
	,country_code
    ,d.formatted_date as date_added
	,has_expired
    ,job_board
    ,job_description
    ,CASE WHEN LEN(TRIM((SPLIT_PART(job_title, 'Job', 1)))) > 45 THEN TRIM(SPLIT_PART(SPLIT_PART(job_title, 'Job', 1), '-', 1)) 
  		WHEN TRIM((SPLIT_PART(job_title, 'Job', 1))) = '' THEN NULL
  		ELSE TRIM((SPLIT_PART(job_title, 'Job', 1)))
  	END AS job_title
  ,CASE WHEN job_type LIKE '%Part%' THEN 'Part Time'
  		WHEN job_type LIKE '%Full%' THEN 'Full Time'
  		WHEN job_type LIKE '%Per Diem%' THEN 'Per Diem'
  		ELSE NULL
  	END AS job_type
    ,city
    ,state
    ,zip
    ,CASE WHEN organization LIKE '%,%' OR organization = '' THEN NULL ELSE organization END AS organization
    ,page_url
    ,min_hrly_rate 
    ,max_hrly_rate
    ,min_salary
    ,max_salary
    ,CASE WHEN LEN(sector) > 150 THEN NULL
  		WHEN sector LIKE '%:%' THEN SPLIT_PART(sector, ':', 2)
  		WHEN sector = '' THEN NULL
		ELSE sector
  	END AS sector
    ,uniq_id
FROM "dev"."public"."k_jobs" j
LEFT JOIN date_formatted d ON d.date_added = j.date_added
LEFT JOIN location_formatted l on l.location = j.location
LEFT JOIN salary_formatted s on s.salary = j.salary;
