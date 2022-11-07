CREATE OR REPLACE FUNCTION DCUA166.fCompress30 (inputString VARCHAR2)
RETURN VARCHAR2
-- the maximum lenght of a Oracle Procedure name is 30 characters. Would like to use the CDE Name as the base for the proc name, and
-- prefix the proc name with DQP, but this sometimes exceeds 30 characters
--purpose of function is to convert a string >= 30 characters to a string that is less thand or = to 30 characters
-- This is done by truncating the words in the string to be 5 characters or less
-- and then replacing spaces with undwerscore character

AS
    --inputString VARCHAR2(100):= 'This is a regexp_substr demo';
    fName varchar2(50):='fExceedMaxChars';
    
    MAX_LENGTH INTEGER:=30; -- maximum lenght of allowed string
    PRE_PROC_STRING VARCHAR2(10):='DQP ';
    MAX_SHORT INTEGER:=4; -- take first xx characters of each word in string
    whichWord VARCHAR2(40);
    wordCount INTEGER;
    
    buildString Varchar2(100);
    outputString VARCHAR2(100);
   
BEGIN

    outPutString:= PRE_PROC_STRING || inputString;
    

    IF length(inputString) >= MAX_LENGTH Then -- only parse if necessary
        buildString:=PRE_PROC_STRING ;

        SELECT regexp_count(inputString, '[^ ]+') INTO wordCount
          FROM dual;
          
          FOR iWord IN 1..wordCount LOOP
             SELECT regexp_substr( inputString, '[^ ]+' , 1, iWord) INTO whichWord FROM DUAL;
             buildString:=buildString || SUBSTR(whichWord,1,MAX_SHORT) || ' ';                     
         END LOOP;
        -- if resulting string still too long then shorten
        IF Length(TRIM(buildString)) > MAX_LENGTH THEN -- if string still too long shorten it more
           
            buildString:=PRE_PROC_STRING ;
            FOR iWord IN 1..wordCount LOOP
                 SELECT regexp_substr( inputString, '[^ ]+' , 1, iWord) INTO whichWord FROM DUAL;
                 buildString:=buildString || SUBSTR(whichWord,1,MAX_SHORT-1) || ' ';                     
            END LOOP;
        END IF;
        
       ELSE
           buildString:= PRE_PROC_STRING || inputString;
    END IF;
    
    buildString := UPPER(buildString);
    outPutString := Replace(TRIM(buildString),' ','_'); -- replace spaces with_
    --DBMS_OUTPUT.PUT_LINE(' output string= ' || outputString);
    
    Return outPutString;
    
    EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
  END;