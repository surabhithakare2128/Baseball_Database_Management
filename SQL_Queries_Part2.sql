use BaseBall_Summer_2018;

--- 1. Write a query that lists the playerid, birthcity, birthstate, salary and batting average for all players born in New Jersey sorted by last name and year in ascending order. The joins must be made using the WHERE clause. Make sure values are properly formatted. ---
--- Note: your query should return 318 rows. ---
select P.playerId, birthcity, birthstate, FORMAT(salary, 'C', 'en-us') AS salary , CONVERT(DECIMAL(5,4), (H*1.0/AB)) AS [Batting Average] 
from People P, Salaries S, Batting B
where P.playerID = S.playerID
	AND B.AB > 0
	AND P.playerID = B.playerID
	AND S.salary > 0
	AND S.yearID = B.yearID
	AND S.teamID = B.teamID
	AND P.birthState = 'NJ'
ORDER BY P.nameLast, S.yearID

--- 2. Write the same query as #1 but you need to use JOIN clauses in the FROM clause to join the tables. Your answers and rows returned should be the same.  ---
select P.playerId, birthcity, birthstate, FORMAT(salary, 'C', 'en-us') AS salary , CONVERT(DECIMAL(5,4), (H*1.0/AB)) AS [Batting Average]
from People P
JOIN Salaries S ON P.playerID = S.playerID
JOIN Batting B ON  P.playerID = B.playerID AND S.yearID = B.yearID AND S.teamID = B.teamID
WHERE P.birthState = 'NJ' AND B.AB > 0 AND S.salary > 0
ORDER BY P.nameLast, S.yearID

---3. Write the same query as #2 but use a LEFT JOIN. ---
--- Note that 1897 rows will be returned and armstja01 will be the first player with a non-null salary. ---
--- Hint: Look at the data to see what needs to be done to get the correct number of rows ---
 
select P.playerId, birthcity, birthstate, FORMAT(salary, 'C', 'en-us') AS salary , CONVERT(DECIMAL(5,4), (H*1.0/AB)) AS [Batting Average]
from People P
LEFT JOIN Salaries S ON P.playerID = S.playerID 
LEFT JOIN Batting B ON  P.playerID = B.playerID AND S.yearID = B.yearID AND S.teamID = B.teamID
WHERE P.birthState = 'NJ' AND B.AB > 0  
ORDER BY P.nameLast, S.yearID

--- 4. Using a BETWEEN clause, find all players with a Batting Average between .0.300 and 0.3249. The query should return the Full Name (NameGiven (NameFirst) NameLast), YearID, Hits, At Bats and Batting Average sorted by descending batting average. ---
SELECT People.playerID, namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name], yearID, H AS Hits, AB as [At Bats], (H*1.0/AB) AS [Batting Average]
FROM People, Batting
WHERE AB > 0 AND (H*1.0/AB) BETWEEN 0.300 AND 0.3249 AND People.playerID = Batting.playerID
ORDER BY [Batting Average] DESC

--- 5. You get into a debate regarding the level of school that professional sports players attend. Your stance is that there are plenty of baseball players who attended Ivy League schools and were good batters in addition to being scholars. Write a query to support your argument using the People, CollegePlaying and Batting tables. You must use an IN clause in the WHERE clause to identify the Ivy League schools. You have also decided that a batting average less than .4 indicates a good batter. Sort you answer by Batting Average in descending order. Your answer should return 453 rows and contain the columns below.  ---
SELECT DISTINCT P.playerID, schoolID, B.yearID, (H*1.0/AB) AS [Batting Average]
FROM People P, CollegePlaying C, Batting B
WHERE P.playerID = C.playerID AND P.playerID = B.playerID
AND C.schoolID IN ('pennst', 'columbia', 'cornell', 'harvard' , 'princeton', 'brown', 'yale', 'dartmouth')
AND (H*1.0/AB) < 0.4 and AB > 0
ORDER BY [Batting Average] DESC

--- 6. Using the Appearances table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the same teams in 2007 and 2010. Your query only needs to return the playerid and teamids. The query should return 297 rows ---
(select playerID, teamID from Appearances where yearID=2007)
intersect
(select playerID, teamID from Appearances where yearID=2010)

--- 7. Using the Appearances table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the different teams in 2007 and 2010. Your query only needs to return the playerids and the 2007 teamid. The query should return 649 rows. ---
(select distinct playerID, teamID from Appearances where yearID=2007)
except
(select distinct playerID, teamID from Appearances where yearID=2008)

--- 8. Using the Salaries table, calculate the average and total salary for each player. Make sure the amounts are properly formatted. ---
SELECT playerId, FORMAT(avg(salary), 'C', 'en-us'), FORMAT(sum(salary), 'C', 'en-us') from Salaries
GROUP BY playerID

--- 9. Using the Batting table and a HAVING clause, write a query that lists the playerid and number of home runs (HR) for all players having more than 500 home runs. ---
SELECT playerId, sum(HR) as [Total Home Runs]
FROM Batting
GROUP BY playerID
HAVING sum(HR) > 500

--- 10.	Using a subquery along with an IN clause in the WHERE statement, write a query that identifies all the playerids, the players full name and the team names who in 2010 that were playing on teams that existed in 1910. You should use the appearances table to identify the players years and the TEAMS table to identify the team name. Sort your results by players last name. Your query should return 446 rows. ---
SELECT People.playerId, namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name], Teams.name
FROM People, Appearances, Teams
WHERE People.playerID = Appearances.playerID 
	AND Appearances.yearID = 2010 
	AND Appearances.teamID = Teams.teamID
	---AND Appearances.yearID = Teams.yearID
	AND Teams.yearID IN (1910)
ORDER BY nameLast

--- 11.	Using the Salaries table, find the players full name, average salary and the last year they played  for each team they played for during their career. Also find the difference between the players salary and the average team salary. You must use subqueries in the FROM statement to get the team and player average salaries and calculate the difference in the SELECT statement. Sort your answer by the playerid in ascending and last year in descending order ---
SELECT Person.playerID, [Full Name], t.teamID, [Last Year], format([Player Average], 'c'), 
	 format([Team Average], 'C') , format([Player Average]-[Team Average], 'C') as [Difference]
FROM (SELECT teamID, avg(salary) as [Team Average] from Salaries group by teamID) t,
	 (SELECT teamID, playerID, avg(salary) as [Player Average], max(yearId) AS [Last Year]
		from Salaries group by teamID, playerID) p,
	 (SELECT  playerID, namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name]
		 from People group by playerID, namegiven + ' (' + namefirst + ') ' + namelast ) Person
WHERE t.teamID = p.teamID
	  AND Person.playerID = p.playerID
ORDER BY playerId, [Last Year] DESC

--- 12.	Rewrite the query in #11 using a WITH statement for the subqueries instead of having the subqueries in the from statement. The answer will be the same. ---
With t as
	(SELECT teamID, avg(salary) as [Team Average] from Salaries group by teamID),
	p as
	(SELECT teamID, playerID, avg(salary) as [Player Average], max(yearId) AS [Last Year]
		from Salaries group by teamID, playerID),
	person as
	(SELECT  playerID, namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name]
		 from People group by playerID, namegiven + ' (' + namefirst + ') ' + namelast )
SELECT person.playerID, [Full Name], t.teamID, [Last Year], format([Player Average], 'c'), 
	 format([Team Average], 'C') , format([Player Average]-[Team Average], 'C') as [Difference]
FROM t, p, person
WHERE t.teamID = p.teamID
	  AND Person.playerID = p.playerID
ORDER BY playerId, [Last Year] DESC

--- 13.	Using a scalar queries in the SELECT statement and the salaries and people tables , write a query that shows the full Name, the average salary and the number of teams the player played. ---
SELECT nameGiven+' ' +CONCAT('(',nameFirst,')')+' '+nameLast AS [Full Name], FORMAT (avg(salary), 'C') AS [Average Salary] ,
	   (SELECT count(teamID) FROM Salaries S WHERE P.playerID = S.playerID) as [Total Teams]
FROM People P, Salaries S
WHERE S.playerID = P.playerID
GROUP BY P.playerID, nameGiven, nameLast, nameFirst

--- 14.	The player’s union has negotiated that players will start to have a 401K retirement plan. You have been asked to add a column to the SALARIES table called P401K Contribution and populate this column for each row by updating it to contain 6% of the salary in the row. You must use an ALTER TABLE statement to create the column and then an UPDATE query to fill in the amount. ---
--- Your query should also properly handle the circumstance where you are running this multiple times and handle if the column already exists. ---
ALTER TABLE Salaries
ADD P401K_Contribution [int]
GO

UPDATE Salaries SET P401K_Contribution = salary * 0.06 

--- 15.	Contract negotiations have proceeded and now the team owner will make a matching contribution to each players 401K each year. If the player’s salary is under $1 million, the team will contribute another 5%. If the salary is over $1 million, the team will contribute 2.5%. You now need to add a T401K Contribution column to the salary table and then write an UPDATE query to populate the team contribution with the correct amount. You must use a CASE clause in the UPDATE query to handle the different amounts contributed. ---
ALTER TABLE Salaries
ADD T401K_Contribution [int]
GO

UPDATE Salaries
SET T401K_Contribution = 
( CASE  
WHEN (salary < 1000000) THEN salary*0.05 
WHEN (salary >= 1000000) THEN salary*0.025
ELSE  (NULL)
END )

--- 16.	Write a query that shows the Playerid, yearid, Salary, Player contribution, Team Contribution and total 401K contribution each year for each player. Do not include players with no contributions. Sort your results by playerid. ---
SELECT playerID, yearID, salary, format(P401K_Contribution, 'C') AS Player_401K, format(T401K_Contribution, 'C')
		AS Team_401K, format(P401K_Contribution+T401K_Contribution, 'C') AS [401K Total]
FROM Salaries
WHERE P401K_Contribution+T401K_Contribution IS NOT NULL
ORDER BY playerID

--- 17.	You have now been asked to add columns to the PEOPLE table that contain the total number of HRs hit by the player and the highest Batting Average the player had during their career (Career BA). Write the SQL that creates the column using an ALTER TABLE statement and correctly populates the new column. ---

--- Adding New Columns---
ALTER TABLE People
ADD Total_HR int,
    Career_BA decimal(6,4)

--- Updating Total_HR ---
BEGIN TRAN
UPDATE People
	SET Total_HR =  (SELECT sum(HR) FROM Batting B WHERE B.playerID = P.playerID GROUP BY playerID)
		 FROM Batting B,People P 
		 WHERE P.playerID = B.playerID
COMMIT

--- Creating Temp_Table, Altering Column Career_BA and updating it ---
select playerID, max(H*1.0/AB) AS Career 
INTO Temp_Table 
from Batting
WHERE AB>0
GROUP BY playerID
Order by playerID

ALTER TABLE People
ALTER COLUMN Career_BA decimal(6,4)

UPDATE People
SET People.Career_BA = T.Career
FROM People P
INNER JOIN Temp_Table T
ON P.playerID = T.playerID;

--- 18.	Write a query that shows the playerid, Total HRs and Highest Batting Average for each player. The Batting Average must be formatted to only show 4 decimal places. Sort the results by playerid. ---
SELECT playerID, Total_HR, Career_BA FROM People
ORDER BY playerID

--- 19.	You have also been asked to create a column in the PEOPLE table that contains the total value of the 401 for each player.  Write the SQL that creates the column using an ALTER TABLE statement and correctly populates the new column. ---
BEGIN
    ALTER TABLE People
    ADD Total_401K int	
END

BEGIN TRAN
UPDATE People
	SET Total_401K =  (SELECT sum(T401K_Contribution)+sum(P401K_Contribution) FROM Salaries S 
		WHERE S.playerID = P.playerID GROUP BY playerID)
		 FROM Salaries S,People P 
		 WHERE P.playerID = S.playerID
COMMIT

--- 20.	Write a query that shows the playerid, the player full name and their 401K total from the people table. Only show players that have contributed to their 401Ks. Sort the results by playerid. ---
SELECT playerID, namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name], format(Total_401K, 'C')
FROM People
WHERE Total_401K IS NOT NULL
ORDER BY playerID

--- 21.	As with any job, players are given raises each year, write a query that calculates the increase each player received and calculate the % increase that raise makes. You will only need to use the SALARIES table. You answer should include the columns below. Include the players full name and sort your results by playerid and year. ---

--- Creating Temporary Table to Store All VAlues(including NUll) ---
Select People.playerID, 
	   namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name],
	   yearID,
       FORMAT(salary, 'C') as [Current Salary], 
	   FORMAT(lag(salary)  over (partition by Salaries.playerID order by yearID),'C') AS [Prior Salary],
       FORMAT(salary - lag(salary) over (partition by Salaries.playerID order by yearID),'C') AS [Salary Difference],
	   FORMAT((salary - lag(salary) over (partition by Salaries.playerID order by Salaries.playerID))/salary,'P')
			AS [Salary Increase]
INTO Temp_Table1
from Salaries, People
WHERE People.playerID = Salaries.playerID AND salary>0

--- Selecting Not Null Values from Temporary Table ---
SELECT * FROM Temp_Table1
WHERE [Prior Salary] IS NOT NULL
ORDER BY playerID