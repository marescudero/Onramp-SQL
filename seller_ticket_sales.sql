/*
Creates 2 CTEs (one based on ticket listings and another on ticket sales) so outputs can be joined and you can identify the percent of tickets sold (helps determine how successful a seller was in selling tickets and the total profit they generated)

*/



--aggregated view showing total tickets listed by seller

WITH seller_ticket_listings AS (

    SELECT sellerid
        ,MIN(CAST(listtime AS date)) AS first_list_date
  		,MAX(CAST(listtime AS date)) AS last_list_date
        ,COUNT(DISTINCT eventid) AS total_events_listed
  		,SUM(numtickets) AS total_tickets_listed
        ,SUM(totalprice) AS total_ticket_price
    FROM dev.public.listing
    GROUP BY sellerid
    ORDER BY sellerid
        
  
 ),
 
 
--aggregated view showing total tickets sold by seller
seller_ticket_sales AS (
  
    SELECT sellerid
      ,MIN(CAST(saletime AS date)) AS first_sale_date
      ,MAX(CAST(saletime AS date)) AS last_sale_date
      ,COUNT(DISTINCT eventid) as total_events_sold
      ,SUM(qtysold) AS total_tickets_sold
      ,SUM(pricepaid) AS total_sales
      ,SUM(commission) AS total_commission
      ,SUM(pricepaid) - SUM(commission) AS seller_profit --total commission is what the business collects from the sale, seller receives the remaining
    FROM dev.public.sales
    GROUP BY sellerid
  
)


SELECT L.sellerid
	,total_tickets_listed
    ,COALESCE(total_tickets_sold,0) AS total_tickets_sold --if no tickets were sold record would be NULL, coalesce replaces null with 0
    ,ROUND(COALESCE(total_tickets_sold,0) / CAST (total_tickets_listed AS FLOAT),4) AS per_tickets_sold --casts denominator as float to get result as decimal
    ,total_ticket_price
    ,COALESCE(total_sales,0) AS total_sales
    ,COALESCE(seller_profit,0) AS seller_profit
  	,total_ticket_price / total_tickets_listed AS avg_ticket_price
    ,COALESCE((seller_profit / total_tickets_sold),0) AS avg_ticket_profit
FROM seller_ticket_listings L
LEFT JOIN seller_ticket_sales S ON S.sellerid = L.sellerid --perform left join so that records of tickets listings that do not have sales are NOT dropped
