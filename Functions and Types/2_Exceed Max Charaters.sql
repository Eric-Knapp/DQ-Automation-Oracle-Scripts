create or replace FUNCTION  DCUA166.fExceedMaxChars (inString IN varchar2, maxLength IN INTEGER )
-- inputs are the string to be tested and the maximum length not to be exceeded. Return 0 is string null, return length if error, else -1
RETURN integer
AS
sLength INTEGER;
fName varchar2(50):='fExceedMaxChars';


BEGIN

    

    If fNullorBlank(inString) =1 Then --is null or blank
        return 0;
    ELSE 
        --SELECT LENGTH(inString) INTO sLength from DUAL; -- get length of string
		sLength:= LENGTH(inString);
		
        IF sLength > maxLength THEN	-- note couldn't get elseif to work
            return sLength;
        ELSE
            return -1; -- not an error
        END IF;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;