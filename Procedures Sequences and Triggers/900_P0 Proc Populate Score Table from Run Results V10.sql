create or replace PROCEDURE  DQP_SCORE_INSERT(V_RUN_NUMBER INTEGER, V_RUN_DATE DATE)

-- Move amd aggregate latest records from Result_Set into DQ_SCORE
IS

PROC_NAME VARCHAR2(40):= 'SCORE_INSERT'; 

max_DQScore_Date DATE;


V_SCORE_ID INTEGER;
V_INITIAL_COUNT INTEGER:= 0;
V_NEW_COUNT INTEGER:= 0;
V_ROWS_INSERTED INTEGER:= 0;

-- Populate DQ_SCORE table incrementally by only inserting data from result_set that has a run_date greater than 
-- the maxium run_date in the DQ_SCORE table
-- @@@ for this to work all constraints need to be removed from DQ_SCORE_ID
--

BEGIN

    SELECT COUNT(*) INTO V_INITIAL_COUNT FROM DQ_SCORE ; -- get current count of rows
    IF V_INITIAL_COUNT IS NULL THEN V_INITIAL_COUNT:=0; END IF;
    max_DQScore_Date:=  fGETMAXDATE ('RUN_DATE','DQ_SCORE'); -- get maxium date from DQ_SCORE TABLE

	--DBMS_OUTPUT.PUT_LINE ('max_DQScore_Date'||max_DQScore_Date);

INSERT INTO DQ_SCORE (CDE_RULE_ID,
    RUN_DATE,
    CDE_ID,
    CDE_NAME, --use cde name and ID from CDE_COMPONENT TABLE
    CDE_SUBCOMPONENT_ID,
    CDE_SUBCOMPONENT_NAME,
    RULE_ID,
    RULE_NAME,
    --DOMAIN_ID,
    DOMAIN_NAME,
    NUMBER_FAILED_RECORDS,
    TOTAL_REC_PROCESSED,
    DQ_SCORE,
    CDE_TARGET)

    SELECT A.CDE_RULE_ID AS CDE_RULE_ID,
    A.RUN_DATE as run_date,
    B.CDE_COMPONENT_ID AS CDE_ID,
    B.CDE_COMPONENT_NAME AS CDE_NAME, --use cde name and ID from CDE_COMPONENT TABLE
    B.CDE_SUBCOMPONENT_ID,
    B.CDE_SUBCOMPONENT_NAME,
    A.RULE_ID,
    A.RULE_NAME,
    --A.DOMAIN_ID,
    A.DOMAIN_NAME,
    COUNT(*) AS NUMBER_FAILED_RECORDS,
    MAX(A.TOTAL_REC_PROCESSED) AS TOTAL_REC_PROCESSED,
    1.00 - COUNT(*)/MAX(A.TOTAL_REC_PROCESSED) AS DQ_SCORE,
    C.TARGET AS CD_TARGET
    --
    FROM DCUA166.RESULT_SET A 
    INNER JOIN DCUA166.CDE_COMPONENT B ON(A.CDE_ID = B.CDE_ID)
    INNER JOIN DCUA166.CDE_TARGET C ON(A.CDE_ID = C.CDE_ID)

    WHERE A.RUN_DATE > max_DQScore_Date -- Only load latest data from Result_Set
    --
    --
    GROUP BY A.CDE_RULE_ID,
    A.RUN_DATE,
    B.CDE_COMPONENT_ID, 
    B.CDE_COMPONENT_NAME,
    B.CDE_SUBCOMPONENT_ID,
    B.CDE_SUBCOMPONENT_NAME,
    A.RULE_ID,
    A.RULE_NAME,
    A.DOMAIN_ID,
    A.DOMAIN_NAME,
    C.TARGET

    ORDER BY RUN_DATE,CDE_ID; -- put in for readability of DQ SCORE data


    COMMIT;  
    SELECT COUNT(*) INTO V_NEW_COUNT FROM DQ_SCORE ; -- count new total of transactions
    IF V_NEW_COUNT IS NULL THEN V_NEW_COUNT:=0; END IF;

    V_ROWS_INSERTED := V_NEW_COUNT - V_INITIAL_COUNT;
    DBMS_OUTPUT.PUT_LINE ('ROWS INSERTED: '|| V_ROWS_INSERTED);
    IF V_ROWS_INSERTED >0 THEN
        DQP_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,'INSERT INTO SCORE',V_ROWS_INSERTED, ' Success ', 'S');
	ELSE
         DQP_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,'PROCEDURE SCORE INSERT ',V_ROWS_INSERTED, ' No Rows Inserted', '?');
    END IF;
	EXCEPTION
		WHEN OTHERS THEN
         DQP_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,'PROCEDURE SCORE INSERT ',V_ROWS_INSERTED, ' Failed: '
         ||  PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM,'F');
       -- 'An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		DBMS_OUTPUT.PUT_LINE ('An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		raise_application_error(-20001,'An error was encountered in procedure '|| PROC_NAME || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

