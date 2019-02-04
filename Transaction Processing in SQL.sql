Use BaseBall_Summer_2018;

--- 1. Adding 2 columns to the MASTER table. The columns are ST638_Total_Games_Played and ST638_Date_Last_Update ---
alter table People 
	add ST638_Total_Games_Played int default NULL,
		ST638_Date_Last_Update date default NULL

--- 2. Create an update cursor for all records the can be joined between the MASTER and APPEARANCES tables and where the date last update column created in #1 above is not equal to today. You need to include the yearid and lgid from the APPEARANCES table to the cursor to handle multiple records for a single player. ---
Print 'Transaction Update Command Start Time - ' + (CAST(convert(varchar, getdate(), 108) AS nvarchar(30)))
Set nocount Off;
Set Statistics Time Off;

/* Run Simple Update Query To Get Time Without Transaction Processing */
Declare		@today date
Set			@today = convert(date, getdate())
PRINT @today
Print 'SQL Update Command Start Time - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

--- Declaring Cursor ---
DECLARE ST638_update_cursor CURSOR STATIC FOR
        SELECT Appearances.playerID, Appearances.G_all, t.max_yearID
		FROM Appearances, People,
			(SELECT playerID, max(yearID) AS max_yearID From Appearances 
			Group by playerID ) t
        WHERE People.playerid = Appearances.playerid AND Appearances.playerID=t.playerID AND Appearances.yearID=t.max_yearID
              AND (ST638_Date_Last_Update <> @today or ST638_Date_Last_Update is Null)

Select @@CURSOR_ROWS as 'Number of Cursor Rows After Declare'
Print 'Declare Cursor Complete Time - ' + (CAST(convert(varchar, getdate(), 108) AS nvarchar(30)))

--- Declaring Variables ---
DECLARE     @updateCount bigint 
DECLARE     @yearID varchar(50)
DECLARE     @g_all INT
DECLARE     @playerID varchar(50)
DECLARE		@STOP int
DECLARE		@ERROR INT

	
-- Initialize the update count
set @updateCount = 0
set @stop = 0

--- Opening Cursor ---
OPEN ST638_update_cursor
Select @@CURSOR_ROWS as 'Number of Cursor Rows'

FETCH NEXT FROM ST638_update_cursor INTO @playerid, @g_all, @yearID 
    WHILE @@fetch_status = 0 AND @STOP = 0
    BEGIN

--- Begin Transaction for first record ---
if @updateCount = 0
    BEGIN 
      PRINT 'Begin Transaction At Record - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
      BEGIN TRANSACTION
    END

PRINT 'UPDATE People table for key = ' + @playerid
Update People
	set ST638_Date_Last_Update = @today,
		ST638_Total_Games_Played = @g_all
	where playerID = @PLayerid;

	set @updateCount = @updateCount + 1

IF @updateCount = 19105
     Begin
           set @STOP = 1
     End
IF @updateCount % 5000 = 0 
        BEGIN
            PRINT 'COMMIT TRANSACTION - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + 
                            (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

            COMMIT TRANSACTION
            BEGIN TRANSACTION
        END
    FETCH NEXT FROM ST638_update_cursor INTO @playerid, @g_all, @yearID
    END
    IF @stop <> 1
    BEGIN
            PRINT 'Final Commit Transaction For Record - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + 
                        (CAST(convert(varchar, getdate(), 108) AS nvarchar(30)))
            COMMIT TRANSACTION
    END

IF @stop = 1
    BEGIN
        PRINT 'Rollback started For Transaction at Record - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' +
                                    (CAST(convert(varchar, getdate(), 108) AS nvarchar(30)))
        Rollback TRANSACTION
    END
CLOSE ST638_update_cursor
DEALLOCATE ST638_update_cursor
Print 'Transaction Update Command End Time - ' + (CAST(convert(varchar, getdate(), 108) AS nvarchar(30))) + ' At - ' +
                                    (CAST(convert(varchar, getdate(), 108) AS nvarchar(30)))
set nocount off;