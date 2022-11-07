CREATE or REPLACE FUNCTION DCUA166.fMinMaxChars
( inString IN varchar2, minLength IN INTEGER, maxLength IN INTEGER ) -- inputs are the string to be tested and the maximum length not to be exceeded
RETURN integer
AS
sLength INTEGER;
fName varchar2(50):= 'fMinMaxChars';

-------------------
BEGIN
   
   
    
    If fNullorBlank(inString) =1 Then --is null or blank
        return 0;
    ELSE
		--SELECT LENGTH(inString) INTO sLength from DUAL;
		sLength:=LENGTH(inString);
		IF sLength > maxLength OR sLength < minLength THEN	-- note couldn't get elseif to work
			return sLength;
        ELSE
            return -1; -- not exceeded
        END IF;
	END IF;
	
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;