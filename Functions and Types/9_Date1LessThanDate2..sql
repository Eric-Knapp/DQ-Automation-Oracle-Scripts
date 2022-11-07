CREATE or REPLACE FUNCTION DCUA166.fDate1LessDate2
( date1 IN Date, date2 IN Date) -- inputs are date1 and date2. output is 1 if date1 less than date2, -1 is either date is null, -1 if date1 >=date2
RETURN INTEGER
AS
fName varchar2(50):='fDate1LessDate2';

testSuccess INTEGER;
-------------------
BEGIN
	IF fNullorBlank( date1) =1 OR fNullorBlank( date2) =1 THEN --is null or blank
        testSuccess:= -1;
	ELSE
		IF date1 < date2 THEN -- oneor  more characters don't match, failed testSuccess
			testSuccess:= 1;
		ELSE
			testSuccess:= -1;
		END IF;
    END IF;
    
    Return testSuccess;
	
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;