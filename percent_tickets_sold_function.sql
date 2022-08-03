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
