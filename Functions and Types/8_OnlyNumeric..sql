CREATE or REPLACE FUNCTION DCUA166.fOnlyNumeric
( inString IN VARCHAR2) -- input is string, output is 1 if fails test of onlydigits , -1 if passes test, 0 if null
RETURN INTEGER
AS
fName varchar2(50):='fOnlyNumeric';

numChars INTEGER;
numMatches INTEGER;
testSuccess INTEGER;


-------------------
BEGIN
	If fNullorBlank( inString) =1 Then --is null or blank
        testSuccess:=0;
	ELSE
        numChars:=LENGTH(inString);
		-- allow number characters ONLY
        numMatches:=REGEXP_COUNT(inString, '[0-9]');
		
		IF numChars <> numMatches Then -- oneor  more characters don't match, failed testSuccess
			testSuccess:=1;
		ELSE
			testSuccess:=-1;
		END IF;
    END IF;
    
    Return testSuccess;
	
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;