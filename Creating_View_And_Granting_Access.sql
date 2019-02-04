--- Creating view which has complete player details ---

USE BaseBall_Summer_2018
Go

Create VIEW ST638_Player_History (PlayerID
                                , Full_Name
								, HallofFamer
								, Avgerage_Salary
								, Total_Salary
								, Num_Teams
								, Years_Played
								, Last_College
								, Last_Year
								, Num_College
								, Num_Year
								, Career_Runs
								, Career_BA
								, Max_BA
								, Career_Wins
								, Career_Loss
								, Career_PHR
								, Avg_ERA
								, Max_ERA
								, Career_SO
								, High_SO
								, Player_Awards
								, Player_Shared
								, Last_played
								, Last_TeamID)
AS 
WITH player_data AS (Select  p.playerID
                           , (p.nameFirst + ' (' + p.nameGiven + ') ' + p.nameLast) as Full_Name
						   , (Select COUNT(*) From (Select playerID
						                                  , teamID
				                                    From Appearances
													Group by playerID, teamID) a	
				                                    Where p.playerID = a.playerID) as Num_Teams
						   , (Select MAX(yearID) - MIN(yearID) + 1
				              From Appearances a	
				              Where p.playerID = a.playerID) as Years_Played
				     From People p),

	 HOF as ( Select p.playerID,
			  case when p.playerId = hof.playerID then 'HallofFamer'
						 ELSE 'NotInducted' END AS HallofFamer
			  FROM People p Left join HallofFame hof on p.playerID = hof.playerID
			  ),

     salary_data AS (Select distinct s.playerID
	                                , SUM(s.salary) as Total_salary
									, AVG(s.salary) as Average_salary
				     From Salaries s
					 Group by playerID),

     college_data AS (Select distinct c.playerID
	                                 , s.name_full as Last_College
									 , cc.Last_Year
									 , cc.Num_Years
									 , (Select COUNT(*) 
				                        From (Select playerID, schoolID
				                              From CollegePlaying
											  Group By playerID, schoolID) x
				                              Where cc.playerID = x.playerID) as Num_Colleges
				      From CollegePlaying c
					                 , (Select c.playerID
					                          , MAX(c.yearID) as Last_Year
							                  , (MAX(c.yearID) - MIN(c.yearID) + 1) as Num_Years
				                        From CollegePlaying c
					                    Group by playerID) cc, Schools s
				      Where c.playerID = cc.playerID and
							s.schoolID = c.schoolID and
							c.yearID = cc.Last_Year),

	latest_team AS (SELECT Appearances.playerID, teamID AS Last_TeamID
						FROM Appearances
						INNER JOIN 
							(SELECT playerID, max(yearID) AS maxyear
							FROM Appearances
							GROUP BY playerID)max_year
						ON Appearances.playerID = max_year.playerID 
						AND Appearances.yearID = max_year.maxyear
					),

    career_data AS (Select distinct a.playerID
	                      , ss.Last_played
						  , t.teamID
					From Appearances a
					      , (Select a.playerID
					               , MAX(a.yearID) as Last_played
					         From Appearances a
					         Group by a.playerID) ss, Teams t
					Where a.playerID = ss.playerID and
						   a.teamID = t.teamID and
						   a.yearID = t.yearID and
						   a.lgID = t.lgID and
						   a.yearID = ss.Last_played),

	Batting_data AS (select b.playerid
						    , Max_BA
							, Career_BA
							, teamID as Highest_Bat_Avg_Team
							, max(yearid) as Highest_Bat_Avg_Yr
							, sum(hr) as Total_Home_Run
							
                     from batting b
			        , (select playerid , avg((batting.H*1.00)/batting.ab) AS Career_BA, max((batting.H*1.00/batting.ab)) as Max_BA
           					from Batting 
							where batting.ab> 0 and batting.stint = 1
	                group by playerid) a
				    where b.playerid = a.playerid and b.h*1.00/b.ab = Max_BA
	                         and b.ab > 0 
	                group by b.playerid,b.teamID, Max_BA, Career_BA),

	career_runs AS (select playerID, sum(HR) as Career_Runs
							from Batting
							where AB> 0
					group by playerID),

	pitching_data AS (SELECT playerID
							, sum(W) as Career_Wins
							, sum(L) as Career_Loss
							, sum(HR) as Career_PHR
							, avg(ERA) AS Avg_ERA
							, max(ERA) as Max_ERA
							, sum(SO) as Career_SO
							, max(SO) as High_SO
						from pitching
					  GROUP BY playerID),

	awards AS (select playerID
						, count(awardID) AS Player_Awards
					from AwardsPlayers 
			   group by playerID),

	awards_shared AS (select playerID
						, count(awardID) AS Player_Shared
					from AwardsSharePlayers
			  group by playerID)

(Select pd.playerID
       , pd.Full_Name
	   , hf.HallofFamer
	   , sd.Average_salary
	   , sd.Total_salary
	   , pd.Num_Teams
	   , pd.Years_Played
	   , cd.Last_College
	   , cd.Last_Year
	   , cd.Num_Colleges
	   , cd.Num_Years
	   , cr.Career_Runs
	   , bd.Career_BA
	   , bd.Max_BA
	   , ptd.Career_Wins
	   , ptd.Career_Loss
	   , ptd.Career_PHR
	   , ptd.Avg_ERA
	   , ptd.Max_ERA
	   , ptd.Career_SO
	   , ptd.High_SO
	   , awd.Player_Awards
	   , aws.Player_Shared
	   , cad.Last_played
	   , lt.Last_TeamID
From player_data pd left join salary_data sd on pd.playerID = sd.playerID 
					left join HOF hf on pd.playerID = hf.playerID 
				    left join college_data cd on pd.playerID = cd.playerID
					left join latest_team lt on pd.playerID = lt.playerID
					left join career_data cad on pd.playerID = cad.playerID
					left join career_runs cr on pd.playerID = cr.playerID
					left join Batting_data bd on pd.playerID = bd.playerID
					left join pitching_data ptd on pd.playerID = ptd.playerID
					left join awards awd on pd.playerID = awd.playerID
					left join awards_shared aws on pd.playerID = aws.playerID)
Go

--- Select query that retrieves all the data in the SQL ---
Select distinct *
From ST638_Player_History
Go

--- SQL to create a role that has read access to the view and no access to the salaries table ---
CREATE ROLE EDITOR;

GRANT SELECT ON dbo.ST638_Player_History TO EDITOR
DENY INSERT, UPDATE, DELETE, SELECT ON dbo.Salaries TO EDITOR