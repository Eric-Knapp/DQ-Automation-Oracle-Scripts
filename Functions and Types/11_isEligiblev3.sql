CREATE or REPLACE FUNCTION       DCUA166.fisEligible (dePloyment IN varchar2, inDivID IN INTEGER )
-- inputs are deployment - production('P') or test('T')
-- output is integer = 1 if eligible, -1 if not eligible or if no match found
RETURN integer
AS

fName varchar2(50):='fisEligible';

testResult INTEGER;
--queryString VARCHAR2(300);
--eTableName VARCHAR2(40);
recCount INTEGER;

BEGIN


    IF UPPER(dePloyment) = 'P' THEN --is production environment
--
--		SELECT COUNT(*) INTO recCount
--		FROM
--          IE_APP_ONLINE.DC_INDV A 
--          JOIN IE_APP_ONLINE.ED_ELIGIBILITY E ON A.INDV_ID = E.MEDICAID_INDV_ID 
--		WHERE
--		   e.eligibility_END_DT is null  and 
--         e.DELETE_SW = 'N'  and 
--         e.cg_status_cd = 'AP'  and 
--         e.payment_end_dt is null  and 
--         e.current_elig_ind = 'A'  and 
--		   e.medicaid_indv_id = inDivID;

    DBMS_OUTPUT.PUT_LINE ('Uncomment P section when permissions granted ');
		
    ELSE 
		--eTableName:= 'dummy_eligibility';
		SELECT COUNT(*) INTO recCount
		FROM dummy_table A
        JOIN DUMMY_ELIGIBILITY E ON A.INDV_ID = E.MEDICAID_INDV_ID 
		WHERE
         A.INACTIVE_IND = 'N' and
         e.eligibility_END_DT is null  and 
         e.DELETE_SW = 'N'  and 
         e.cg_status_cd = 'AP'  and 
         e.payment_end_dt is null  and 
         e.current_elig_ind = 'A'  and 
		 e.medicaid_indv_id = inDivID;
	END IF;

    IF recCount IS NULL THEN --shouldn't be null but check anyway
        testResult:= -1;
    ELSE
       IF recCount > 0 THEN --is elibible, should be only 1 record?
            testResult:= 1;
        ELSE
            testResult:=-1; -- not eligible
        END IF;
    END IF;


	return testResult;

	EXCEPTION
	WHEN NO_DATA_FOUND then
     return -1; --didn't find a match and no records results
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE ('An error was encountered in function '|| fName || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
	raise_application_error(-20001,'An error was encountered in function '|| fName || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;