CREATE OR REPLACE FUNCTION   DCUA166.finvalidState ( StateCode VARCHAR2, deployFlag VARCHAR2)
-- input is state code to be tested and deployFlag for environment
-- output is integer = 1 if not in reference table, -1 if is in reference table
-- Version 2 szf

RETURN integer

AS

fName varchar2(50):='finvalidState';

TLIST CDE_TABLES_TYPE;
testResult INTEGER;
recCount INTEGER;
sqlString VARCHAR2(200);

BEGIN
	TLIST:= fSET_CDETEDS_TABLE_NAMES(deployFlag); -- get list of schema table names
	sqlString:= 'SELECT COUNT(*) FROM ' || TLIST.stateCodeTableName || ' e WHERE e.CODE =  ' || fEncloseQuotes(UPPER(StateCode));
	
	
	EXECUTE IMMEDIATE sqlString INTO recCount;
	

    IF recCount IS NULL THEN --shouldn't be null but check anyway
        testResult:= 1;
    ELSE
       IF recCount > 0 THEN --is elibible
            testResult:= -1; -- found so didn't fail 
        ELSE
            testResult:= 1; -- not found so failed
        END IF;
    END IF;


	return testResult;

	EXCEPTION
	WHEN NO_DATA_FOUND then
     return 1; --didn't find a match and no records results so failed
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;