CREATE or REPLACE FUNCTION DCUA166.fNullorBlank
( inString IN VARCHAR2) -- inputs are the string or integer, output is 1 if blank or null else -1
RETURN INTEGER
AS
fName varchar2(50):='fNullorBlank';

isBlank INTEGER;
isNulllorBlank INTEGER;

BEGIN
	isNulllorBlank:= -1; -- init to not null or blank
	If inString IS NULL Then
        isNulllorBlank:= 1; -- is not null or blank
	ELSE
		--SELECT LENGTH(TRIM(inString)) INTO isBlank from DUAL;
		isBlank:= LENGTH(TRIM(inString));
		IF isBlank IS NULL THEN
            isNulllorBlank:= 1;	-- is null or blank
        END IF;
    END IF;
    
    Return isNulllorBlank;
	
	EXCEPTION WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
        
END;