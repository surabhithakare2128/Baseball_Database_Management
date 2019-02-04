use BaseBall_Summer_2018;

---1. Select yearid, lgid, teamid, playerid and the number of home runs (HR) from the BATTING table.---
SELECT yearID, lgID, teamID, playerID, HR FROM Batting

---2. Modify the query in #1 so it also shows the number of hits that were for “extra bases” and the batting average (H/AB). The Extra Bases column must be calculated by adding the following columns together (2B, 3B and HR).  Rename the derived column Extra Base Hits.---
SELECT yearID, lgID, teamID, playerID, HR, (B2+B3+HR) AS [Extra Bases], (H*1.0/AB) AS [Batting Average] 
FROM Batting
WHERE AB <> 0

---3. Using the Batting table, create a list of all the players who played for more than 1 team in any season. This would be indicated there being rows where stint >1. Make sure all playerids are listed only one.---
SELECT distinct (playerID) FROM Batting
WHERE stint > 1
order by playerID

---4. Select the yearid, lgid, Teamid, PlayerID and HR from the Batting table for all players who hit 20 or more home runs (HR) in 2015 or 2016 and played on the New York Yankees. Hint: Use teamid NYA in your where statement---
SELECT yearID, lgID, teamID, playerID, HR FROM Batting
WHERE HR > 20 AND (yearID = 2015 OR yearID = 2016) AND teamID='NYA'

---5. Using the SALARIES table, write a query that selects the yearid, teamid, playerid and salary (formatted with $ and . ) for everyone who played for the Boston Red Sox (teamid = BOS) in 2016---
SELECT yearID, teamID, playerID, FORMAT(salary, 'C', 'en-us') AS salary 
FROM Salaries
WHERE teamID='BOS' AND yearID=2016

---6. Modify the query in #5 to include the players first and last name (namefirst and namelast) from the PEOPLE table---
SELECT yearID, teamID, Salaries.playerID, nameFirst, nameLast, FORMAT(salary, 'C', 'en-us') AS salary 
FROM Salaries, People
WHERE teamID='BOS' AND yearID=2016 AND People.playerID = Salaries.playerID

---7. Modify the query in #6 to also include the # of home runs (HR) from the batting table and the positions each player played (POS column from the FIELDING table) for the first team the player played for in 2016  (stint = 1). Note the correct answer returns 33 rows (see message tab in SSMS). In this problem, you must use the WHERE clause to perform the joins between the tables---
SELECT Batting.yearID, Batting.teamID, Salaries.playerID, nameFirst, nameLast, FORMAT(salary, 'C', 'en-us') AS salary, HR AS [Home Runs], POS, Batting.stint
FROM Salaries, People, Batting, Fielding
WHERE Salaries.teamID='BOS' AND Salaries.yearID=2016 AND People.playerID = Salaries.playerID AND Batting.stint = 1
		AND People.playerID = Batting.playerID
		AND Batting.playerID = Fielding.playerID
		AND Fielding.playerID = Salaries.playerID
		AND Batting.yearID  = Fielding.yearID
		AND Fielding.yearID = Salaries.yearID
		AND Batting.stint = Fielding.stint

---8. Rewrite #7 using join clause to perform the joins instead of the where clause. The result set and number of rows returned will be the same.---
SELECT Batting.yearID, Batting.teamID, Salaries.playerID, nameFirst, nameLast, FORMAT(salary, 'C', 'en-us') AS salary, HR AS [Home Runs], POS, Batting.stint
FROM People 
JOIN Salaries ON People.playerID = Salaries.playerID
JOIN Fielding ON Fielding.yearID = Salaries.yearID AND Fielding.playerID = Salaries.playerID 
JOIN Batting ON Batting.yearID  = Fielding.yearID AND Batting.playerID = Fielding.playerID AND People.playerID = Batting.playerID AND Batting.stint = Fielding.stint
WHERE Salaries.teamID = 'BOS' AND Salaries.yearID=2016 AND Batting.stint = 1

---9. Concatenate the 3 name columns in the people table in the following format: namegiven (namefirst) namelast and rename the result column to Full Name. Only include players who use their initials as their namefirst. This would be indicated by namefirst containing a period (.).---
SELECT namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name]
FROM people 
WHERE nameFirst like '%.%'

---10. Repeat the query in #9, by sort in reverse order by namefirst---
SELECT namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name]
FROM people 
WHERE nameFirst like '%.%'
ORDER BY nameFirst DESC

---11. Modify the query in #9 by showing the players who played a position in the infield (POS = 1B, 2B, 3B or SS) for the National League ( lgid = NL) from the Fielding table.---
SELECT namegiven + ' (' + namefirst + ') ' + namelast AS [Full Name], Fielding.yearID, Fielding.teamID, POS
FROM people, Fielding
WHERE nameFirst like '%.%' AND lgID='NL' AND POS IN ('1B', '2B', '3B', 'SS') AND People.playerID = Fielding.playerID

---12. Modify the query in #11 to only include the years where the player’s team had a win percent greater than .500 using the information on the games in the teams table. Format the Percent Win to have 4 decimal places using a CONVERT clause. ---
SELECT NameGiven + ' ( ' + namefirst + ' ) ' + nameLast AS [Full Name], teams.yearID, teams.teamID, POS,W AS Wins, L AS Losses, CONVERT(DECIMAL(5,4), (W*1.0/teams.G)) AS [Percent Won] 
FROM People, Fielding, Teams 
WHERE nameFirst like '%.%' 
		AND teams.lgID='NL'
		AND POS in ('1B', '2B','3B', 'SS') 
		AND People.playerID=Fielding.playerID 
		AND Teams.yearID=Fielding.yearID 
		AND Teams.teamID=Fielding.teamID 
		AND Teams.lgID=Fielding.lgID 
		AND (W*1.0/teams.G)>.5

--13. Add the Name, City and State of the teams Park (from the park table) to the query for #12. ---
SELECT nameGiven + ' ( ' + namefirst + ' ) ' + nameLast AS [Full Name], teams.yearID, teams.teamID, POS,W AS Wins, L AS Losses, CONVERT(DECIMAL(5,4), (W*1.0/teams.G)) AS [Percent Won], park, city, state
FROM People, Fielding, Teams, Parks
WHERE nameFirst like '%.%' 
		AND teams.lgID='NL'
		AND POS in ('1B', '2B','3B', 'SS') 
		AND People.playerID=Fielding.playerID 
		AND Teams.yearID=Fielding.yearID 
		AND Teams.teamID=Fielding.teamID 
		AND Teams.lgID=Fielding.lgID 
		AND (W*1.0/teams.G)>.5
		AND Parks.park_name=Teams.park 
