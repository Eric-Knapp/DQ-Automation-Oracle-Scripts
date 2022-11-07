CREATE or REPLACE FUNCTION DCUA166.fNonValidApplicationStatus
( inString IN VARCHAR2) -- input is string, output is 1 if null or is not in valide code list else is -1 if passes test and valid code
RETURN INTEGER
AS
fName varchar2(50):='fNonValidApplicationStatus';
testResult INTEGER;

-------------------
BEGIN
	If fNullorBlank( inString) =1 Then --is null or blank
        testResult:= 1; -- null fails test
	ELSE
		
		IF UPPER(inString) IN ('APPROVED', 'PENDING', 'TERMED', 'DENIED') THEN
			testResult:= -1;	-- didn't fail
		ELSE
			testResult:= 1; -- failed and not in list
		END IF;	
		
		
    END IF; 
    Return testResult;
	
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;