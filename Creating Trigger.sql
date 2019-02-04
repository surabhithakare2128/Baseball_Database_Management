USE BaseBall_Summer_2018

--- Write a trigger that updates the both of the columns you created in the PEOPLE table whenever there is a row inserted, updated or deleted from the salary table. ---
--- Creating columns for Total and Average Salary each ---
BEGIN
	Alter Table People ADD ST638_Total_Salary money,
				ST638_Average_Salary money
END;
GO

--- Populating the Columns ---
UPDATE People
	Set ST638_Total_Salary = (Select CASE When SUM(salary) is not NULL Then SUM(salary) Else 0 END
							  From Salaries s Where s.playerID = People.playerID),
		ST638_Average_Salary = (Select CASE When AVG(salary) is not NULL Then AVG(salary) Else 0 END
							  From Salaries s Where s.playerID = People.playerID);
GO

--- Creating Trigger ---
CREATE TRIGGER ST638_Trigger
	ON dbo.Salaries
	AFTER INSERT, UPDATE, DELETE
	AS 
BEGIN 

--- Update ---
IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
BEGIN
	UPDATE people
	SET people.ST638_Total_Salary = (ST638_Total_Salary + inserted.salary - deleted.salary)
		FROM inserted, deleted, Salaries
		WHERE people.playerID = inserted.playerID AND people.playerID = deleted.playerID
END

--- Insert ---
IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
	UPDATE people
	SET people.ST638_Total_Salary = (ST638_Total_Salary + inserted.salary)
		FROM inserted
		WHERE people.playerID = inserted.playerID
END

--- Delete ---
IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
BEGIN
	UPDATE people
	SET people.ST638_Total_Salary = (ST638_Total_Salary - deleted.salary)
		FROM deleted
		WHERE people.playerID = deleted.playerID
END

--- Updating Average Salary ---
UPDATE people
	SET ST638_Average_Salary = (SELECT p.ST638_Total_Salary FROM people p 
			WHERE p.playerID IN (Select playerID From inserted) OR p.playerID IN (Select playerID From deleted)) / 
			(SELECT COUNT(s.playerID) FROM Salaries s 
			WHERE s.playerID IN (Select playerID From inserted) OR s.playerID IN (Select playerID From deleted))
	WHERE people.playerID IN (Select playerID From inserted) OR People.playerID IN (Select playerID From deleted)
END
GO

--- Verifying Update ---
Select playerID, ST638_Total_Salary, ST638_Average_Salary FROM People WHERE playerID = 'abadijo01';
Select * FROM Salaries WHERE playerID = 'abadijo01';

--- Inserting Record for aaronha01---
INSERT INTO Salaries(yearID, teamID, lgID, playerID, salary) VALUES(2011, 'CIN', 'NL', 'abadijo01', 45000);

--- Verifying Update ---
Select playerID, ST638_Total_Salary, ST638_Average_Salary FROM People WHERE playerID = 'abadijo01';
Select * FROM Salaries WHERE playerID = 'abadijo01';

--- Another insert for same player ---
INSERT INTO Salaries(yearID, teamID, lgID, playerID, salary) VALUES (2011, 'CIN', 'NL', 'abadijo01', 55000);

--- Verifying Update ---
Select playerID, ST638_Total_Salary, ST638_Average_Salary FROM People WHERE playerID = 'abadijo01';
Select * FROM Salaries WHERE playerID = 'abadijo01';

--- Updating record of same player ---
UPDATE Salaries SET salary = salary * 2 WHERE playerID = 'abadijo01';

--- Verifying Update ---
Select playerID, ST638_Total_Salary, ST638_Average_Salary FROM People WHERE playerID = 'abadijo01';
Select * FROM Salaries WHERE playerID = 'abadijo01';

--- Deleting 1 record of same player from salaries ---
DELETE FROM Salaries WHERE playerID = 'abadijo01' AND salary=110000

--- Verifying Update ---
Select playerID, ST638_Total_Salary, ST638_Average_Salary FROM People WHERE playerID = 'abadijo01';
Select * FROM Salaries WHERE playerID = 'abadijo01';