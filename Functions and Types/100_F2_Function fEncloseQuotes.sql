create or replace FUNCTION  DCUA166.fEncloseQuotes (inString VARCHAR2)
-- input is string, output is ''inStringValue''
RETURN VARCHAR2
AS

fName varchar2(50):='fEncloseQuotes';

outQuoteString VARCHAR2(40);
singQuote VARCHAR2(40):=''''; 

BEGIN
    outQuoteString:= singQuote || inString || singQuote; 
    RETURN outQuoteString;

	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;