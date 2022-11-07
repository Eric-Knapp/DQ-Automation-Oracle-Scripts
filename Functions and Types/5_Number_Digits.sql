CREATE or REPLACE FUNCTION DCUA166.fNumDigits
( inNumber IN INTEGER) -- inputs are the integer number, output is character count in number, if inNumber is Null return 0
RETURN INTEGER
AS
fName varchar2(50):='fNumDigits';

numDigits INTEGER;
strNumber varchar2(30);

-------------------
BEGIN
	If fNullorBlank( inNumber) =1 Then --is null or blank
        numDigits:=0;
	ELSE
		strNumber:= TO_CHAR( inNumber);
		--SELECT LENGTH(strNumber) INTO numDigits from DUAL;
		numDigits:= LENGTH(strNumber);
    END IF;
    
    Return numdigits;
	
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;