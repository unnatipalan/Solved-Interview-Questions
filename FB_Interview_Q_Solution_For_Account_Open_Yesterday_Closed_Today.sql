/* 
Interview Question from (https://towardsdatascience.com/the-facebook-data-analyst-interview-6bcc8bde7e71):

Given a table of account statuses, write a query to get the number of accounts  
that closed today but were open yesterday.

*/ 
-- create account table  
DECLARE @accounts TABLE 
  ( 
     [account_id] INT, 
     [status]     INT, 
     [date]       DATE 
  ) 

INSERT INTO @accounts 
VALUES      (1, 
             0, 
             Getdate() - 1), 
            (1, 
             0, 
             Getdate()), 
            (2, 
             1, 
             Getdate() - 1), 
            (2, 
             0, 
             Getdate()), 
            (3, 
             1, 
             Getdate() - 1), 
            (3, 
             1, 
             Getdate()), 
            (4, 
             1, 
             Getdate() - 1), 
            (4, 
             1, 
             Getdate()), 
            (5, 
             1, 
             Getdate() - 1), 
            (5, 
             0, 
             Getdate()); 

WITH cte 
     AS (SELECT account_id, 
                [status], 
                [date], 
                Previous_Day_Account_Status = Lag([status]) --The LAG function helps us fetch yesterday's account status
                                                OVER ( 
                                                  partition BY account_id -- The partition by clause helps us reset the counter for every account_id
                                                  ORDER BY [date]), 
                Today_Account_Status = CASE 
                                         WHEN [date] = Cast (Getdate() AS DATE) --filtering out today's account status
                                       THEN 
                                         [status] 
                                         ELSE 0 
                                       END 
         FROM   @accounts) 

SELECT Count(*) Total_Accounts_Open_Yesterday_Closed_Today
FROM   cte 
WHERE  today_account_status = 0 
       AND previous_day_account_status = 1 