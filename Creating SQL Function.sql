USE BaseBall_Summer_2018

CREATE FUNCTION player_fullname(@id varchar(255))
RETURNS VARCHAR(255) 
BEGIN
RETURN
  (SELECT namegiven + ' (' + namefirst + ') ' + namelast AS Full_Name
  FROM People p
  WHERE p.playerID = @id)
END

SELECT b.teamID, 
		b.playerID,
		dbo.player_fullname(b.playerID) AS FullName,
		sum(H) Total_Hits, 
		sum(AB) Total_At_Bats, 
		(sum(H)*1.0/sum(AB)) Total_BA, 
		DENSE_RANK() OVER (PARTITION BY teamID ORDER BY (sum(H)*1.0/sum(AB)) DESC) AS Team_Batting_Rank,
		DENSE_RANK() OVER (ORDER BY (sum(H)*1.0/sum(AB)) DESC) AS All_Batting_Rank
FROM Batting b, People p
WHERE b.playerID=p.PlayerID AND AB > 0 
GROUP BY teamID, b.playerID
HAVING  sum(AB) >= 150 AND (sum(H)*1.0/sum(AB)) > 0
ORDER BY teamID, Total_BA DESC
GO

