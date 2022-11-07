CREATE or REPLACE FUNCTION DCUA166.fGETNextRunNumber
RETURN INTEGER
-- Function to get next incremental RUN Number from Result Set table

AS

nextRunNumber INTEGER;
maxRunNumber INTEGER;

BEGIN

   SELECT MAX(RUN_NUMBER) INTO maxRunNumber FROM RESULT_SET;
   
   IF  maxRunNumber IS NULL then --no rows in RESULT_SET Table
    --dbms_output.put_line('date is null');
	
    return 1; --init to 1
    
    ELSE
		nextRunNumber:= maxRunNumber +1;
		return nextRunNumber; 	-- next run number
    END IF;

    
-- 
exception 
   when NO_DATA_FOUND then
     dbms_output.put_line('no data found');
     return 1;

END;
