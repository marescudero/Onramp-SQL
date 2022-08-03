/*

Function that labels interval group based on % of tickets sold (14% intervals for records with greater than 10% of tickets sold)

drop function f_per_tickets_small_bin(float) ....can be used to drop existing function
 
 */
 

CREATE FUNCTION f_per_tickets_small_bin (float)
 	RETURNS varchar
STABLE 
 
 AS $$
 
       SELECT
          CASE WHEN $1 = 0 THEN '0% Sold'
             WHEN $1 < .10 THEN '<10% Sold'
             WHEN $1 BETWEEN .10 AND .24 THEN '10%-24% Sold'
             WHEN $1 BETWEEN .25 AND .39 THEN '25%-39% Sold'
             WHEN $1 BETWEEN .40 AND .54 THEN '40%-54% Sold'
             WHEN $1 BETWEEN .55 AND .69 THEN '55%-69% Sold'
             WHEN $1 BETWEEN .70 AND .84 THEN '70%-84% Sold'
             WHEN $1 >= .85 THEN '>85% Sold'
             ELSE 'N/A'
        END 
 
 $$ LANGUAGE SQL;
 
 
 

/*

Function that labels interval group based on % of tickets sold (24% intervals)
 
 */


CREATE FUNCTION f_per_tickets_large_bin (float)
 	RETURNS varchar
STABLE 
 
 AS $$
 
       SELECT
          CASE WHEN $1 <.25 THEN '<25% Sold'
             WHEN $1 BETWEEN .25 AND .49 THEN '25%-49% Sold'
             WHEN $1 BETWEEN .50 AND .74 THEN '50%-74% Sold'
             WHEN $1 >=.75 THEN '>75% Sold'
             ELSE 'N/A'
        END 
 
 $$ LANGUAGE SQL;
