--- Foreign Key 1 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : AllstarFull ---
ALTER TABLE AllstarFull ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 2 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : CollegePlaying ---
ALTER TABLE CollegePlaying ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 3 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : AllstarFull ---

--- Making Columns Not Null ---
ALTER TABLE Teams ALTER COLUMN yearID INT not null
ALTER TABLE Teams ALTER COLUMN lgID VARCHAR(255) not null
ALTER TABLE Teams ALTER COLUMN teamID VARCHAR(255) not null

--- Creating Composite Primary Key on Teams Table ---
ALTER TABLE Teams ADD CONSTRAINT Teams_Primary_Key PRIMARY KEY(yearID,lgID,teamID)

--- Creating Foreign Key ---
ALTER TABLE AllstarFull ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 4 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : Batting ---
ALTER TABLE Batting ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 5 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : Fielding ---
ALTER TABLE Fielding ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 6 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : Pitching ---
ALTER TABLE Pitching ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 7 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : Salaries ---
ALTER TABLE Salaries ADD FOREIGN KEY(playerID) REFERENCES People (playerID) --- Gives Error ---

--- Finding Uncommon Rows (Output: 8 Uncommon playerID) ---
--- pierza.01, harriwi10, dicker.01, rosajo01, willima10, castiru02, montafr02, sabatc.01 ---
SELECT playerID from Salaries
WHERE playerID NOT IN
(SELECT playerID from People)

--- Finding Errors ---
Select * from Salaries
where playerID IN 
	('pierza.01', 'harriwi10', 'dicker.01', 'rosajo01', 'willima10', 'castiru02', 'montafr02', 'sabatc.01')

select playerID from Appearances 
where playerID like 'pierza%' and teamID='ATL' and lgID='NL' --- Output: pierzaj01 ---

select playerID from Appearances 
where playerID like 'harriwi%' and teamID='HOU' and lgID='AL' --- Output: harriwi02 ---

select playerID from Appearances 
where playerID like 'dicker%' and teamID='TOR' and lgID='AL' --- Output: dickera01 ---

select playerID from Appearances 
where playerID like 'rosa%01' and teamID='COL' and lgID='NL' --- Output: rosarwi01 ---

select playerID from Appearances 
where playerID like 'willi%m%' and teamID='NYA' and lgID='AL' --- Output: willima07 ---

select playerID from Appearances 
where playerID like 'casti%' and teamID='BOS' and lgID='AL' AND yearID = 2016 --- Output: castiru01 ---

select playerID from Appearances 
where playerID like 'm%' and teamID='LAN' and lgID='NL' AND yearID = 2016
order by playerID --- Unclear Output(So decided to delete this record) ---

select playerID from Appearances 
where playerID like 'saba%' and teamID='NYA' and lgID='AL' AND yearID = 2016 --- Output: sabatcc01 ---

--- Fixing Data from Salaries table---

UPDATE Salaries 
SET playerID = 'pierzaj01'
WHERE playerID = 'pierza.01'

UPDATE Salaries 
SET playerID = 'castiru01'
WHERE playerID = 'castiru02'

UPDATE Salaries 
SET playerID = 'rosarwi01'
WHERE playerID = 'rosajo01'

UPDATE Salaries 
SET playerID = 'harriwi02'
WHERE playerID = 'harriwi10'

UPDATE Salaries 
SET playerID = 'sabatcc01'
WHERE playerID = 'sabatc.01'

UPDATE Salaries 
SET playerID = 'willima07'
WHERE playerID = 'willima10'

UPDATE Salaries 
SET playerID = 'dickera01'
WHERE playerID = 'dicker.01'

DELETE FROM Salaries
WHERE playerID = 'montafr02'

 --- Adding Foreign Key ---
ALTER TABLE Salaries ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 8 ---
--- column name : lgID ---
--- primary key table : Teams ---
--- foreign key table : League ---
USE BaseBall_Summer_2018

CREATE TABLE League(
	lgID VARCHAR(255), 
	teamID VARCHAR(255),
	yearID INT,
PRIMARY KEY (lgID) 
)

--- Finding Distinct LgID ---
select distinct(lgid) from teams

--- Inserting LgID into League Table ---
INSERT INTO League (lgID)
VALUES ('UA'),('NA'),('AL'),('AA'),('NL'),('FL'),('PL')

--- Creating Foreign Key ---
ALTER TABLE Teams ADD FOREIGN KEY(lgID) REFERENCES League(lgID);

--- Foreign Key 9 ---
--- Column name : playerID ---
--- Primary key table : People ---
--- Foreign key table : Appearances ---
ALTER TABLE Appearances ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 10 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Salaries ---
ALTER TABLE Salaries ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 11 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Managers ---
ALTER TABLE Managers ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 12 ---
--- Column name : playerID ---
--- Primary key table : People ---
--- Foreign key table : AwardsManager ---
ALTER TABLE AwardsManagers ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 13 ---
--- Column name : lgID ---
--- Primary key table : League ---
--- Foreign key table : AwardsManagers ---

--- Finding Errors (Output: ML) ---
select * from AwardsManagers
	WHERE lgID NOT IN
	(SELECT lgID from League)

--- Fixing Errors ---
INSERT INTO League (lgID)
VALUES ('ML')

--- Creating Foreign Key ---
ALTER TABLE AwardsManagers ADD FOREIGN KEY(lgID) REFERENCES League (lgID)

--- Foreign Key 14 ---
--- Column name : park_key ---
--- Primary key table : Parks ---
--- Foreign key table : HomeGames ---

--- Fixing Parks Table and making park_key Primary key ---
ALTER TABLE Parks ALTER COLUMN park_key VARCHAR(255) not null
ALTER TABLE Parks ADD CONSTRAINT Parks_Primary_Key PRIMARY KEY (park_key)

--- Creating Foreign Key ---
ALTER TABLE HomeGames ADD FOREIGN KEY(parkID) REFERENCES Parks(park_key)

--- Foreign Key 15 ---
--- Column name : schoolID ---
--- Primary key table : Schools ---
--- Foreign key table : CollegePlaying ---

--- Fixing Schools Table and making park_key Primary key ---
ALTER TABLE Schools ALTER COLUMN schoolID VARCHAR(255) not null
ALTER TABLE Schools ADD CONSTRAINT Schools_Primary_Key PRIMARY KEY(schoolID)

--- Fixing data to create foreign key ---
Select schoolID from CollegePlaying
	WHERE schoolID NOT IN
(SELECT schoolID from Schools)

delete from CollegePlaying where schoolID = 'ctpostu' 
delete from CollegePlaying where schoolID = 'txutper' 
delete from CollegePlaying where schoolID = 'caallia' 
delete from CollegePlaying where schoolID = 'txrange' 

--- Creating Foreign Key ---
ALTER TABLE CollegePlaying ADD FOREIGN KEY(schoolID) REFERENCES Schools(schoolID)

--- Foreign Key 16 ---
--- Column name : franchID ---
--- Primary key table : teamsFranchies ---
--- Foreign key table : Teams ---

--- Fixing teamsFranchies Table and making park_key Primary key ---
ALTER TABLE teamsFranchises ALTER COLUMN franchID VARCHAR(255) not null
ALTER TABLE teamsFranchises ADD CONSTRAINT tf_Primary_Key PRIMARY KEY(franchID)

--- Creating Foreign Key ---
ALTER TABLE teams ADD FOREIGN KEY(franchID) REFERENCES teamsFranchises(franchID)

--- Foreign Key 17 ---
--- Column name : lgID ---
--- Primary key table : League ---
--- Foreign key table : Teams ---

ALTER TABLE Teams ADD FOREIGN KEY(lgID) REFERENCES League(lgID)

--- Foreign Key 18 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Batting ---

ALTER TABLE Batting ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 19 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Appearances ---

ALTER TABLE Appearances ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 20 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Salaries ---

ALTER TABLE Salaries ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

--- Foreign Key 21 ---
--- column name : playerID ---
--- primary key table : People ---
--- foreign key table : Managers ---
ALTER TABLE Managers ADD FOREIGN KEY(playerID) REFERENCES People (playerID)

--- Foreign Key 22 ---
--- column names : yearID, lgID, teamID ---
--- primary key table : Teams ---
--- foreign key table : Managers ---

ALTER TABLE Managers ADD FOREIGN KEY(yearID, lgID, teamID) REFERENCES Teams (yearID, lgID, teamID)

