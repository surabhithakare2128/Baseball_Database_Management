USE BaseBall_Summer_2018;

--- 1. Using the view you created in Chapter 4, write a query that uses the RANK function to rank the careerBA column where the careerBA < 0.40. Your results must show the playerid, Full Name, CareerBA and the rank for the players  ---
SELECT DISTINCT PlayerID, 
		Full_Name, 
		CONVERT(DECIMAL(5,4), Career_BA) AS Career_BA, 
		RANK() OVER (ORDER BY Career_BA DESC) AS BA_Rank
FROM ST638_Player_History
WHERE Career_BA > 0.00 AND Career_BA < 0.40
ORDER BY Career_BA DESC

--- 2. Write the same query as #2 but eliminate any gaps in the ranking  ---
SELECT DISTINCT PlayerID, 
		Full_Name, 
		CONVERT(DECIMAL(5,4), Career_BA) AS Career_BA, 
		DENSE_RANK() OVER (ORDER BY Career_BA DESC) AS BA_Rank
FROM ST638_Player_History
WHERE Career_BA > 0.00 AND Career_BA < 0.40
ORDER BY Career_BA DESC

--- 3. Write the same query as #1, but find the ranking within the last year played by the player starting with the most current year and working backwards. Also eliminate any player where the career batting average is = 0. ---
SELECT PlayerID, 
		Full_Name, 
		Last_played, 
		CONVERT(DECIMAL(5,4), Career_BA) AS Career_BA, 
		DENSE_RANK() OVER (PARTITION BY Last_played ORDER BY Career_BA DESC) AS BA_Rank
FROM ST638_Player_History
WHERE Career_BA > 0.00 AND Career_BA < 0.40
ORDER BY Last_played DESC

--- 4. Write the same query as #3, but show the ranking by quartile ( use the NTILE(4) parmeter) ---
SELECT PlayerID, 
		Full_Name, 
		Last_played, 
		CONVERT(DECIMAL(5,4), Career_BA) AS Career_BA, 
		NTILE(4) OVER (ORDER BY Career_BA DESC) AS Ntile
FROM ST638_Player_History
WHERE Career_BA > 0.00 AND Career_BA < 0.40
ORDER BY Last_played DESC

--- 5. Using the Salaries table, write a query that compares the averages salary by team and year with the windowed average of the 3 prior years and the 1 year after the current year. ---
--- Note: You will need to use multiple subqueries to get the answer. ---
SELECT s.teamID, 
		s.yearID, 
		FORMAT(s.AvgSal,'C') AS Year_Average, 
		FORMAT(AVG(s.AvgSal) OVER (PARTITION BY teamID ORDER BY yearID ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING),'C') AS Windowed_Salary
From (Select teamID, yearID, AVG(salary) AS AvgSal 
From Salaries Group by teamID, yearID) s

--- 6. Write a query that shows that teamid, playerid, Player Full Name, total hits, total at bats, total batting average (calculated by using sum(H)*1.0/sum(AB) as the formula) and show the players rank within the team and the rank within all players. Only include players that have a minimum of 150 career hits. ---
SELECT b.teamID, 
		b.playerID, 
		full_name, 
		sum(H) Total_Hits, 
		sum(AB) Total_At_Bats, 
		(sum(H)*1.0/sum(AB)) Total_BA,
		DENSE_RANK() OVER (PARTITION BY teamID ORDER BY (sum(H)*1.0/sum(AB)) DESC) AS Team_Batting_Rank,
		DENSE_RANK() OVER (ORDER BY (sum(H)*1.0/sum(AB)) DESC) AS All_Batting_Rank
FROM Batting b, ST638_Player_History v
WHERE b.playerID=v.PlayerID AND AB > 0 
GROUP BY teamID, b.playerID,Full_Name
HAVING  sum(AB) >= 150 AND (sum(H)*1.0/sum(AB)) > 0
ORDER BY teamID, Total_BA DESC

