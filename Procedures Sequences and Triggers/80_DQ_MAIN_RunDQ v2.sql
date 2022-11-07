CREATE or REPLACE PROCEDURE DCUA166.DQP_RUN_CHECKS

-- Main Procedure to Run each CDE Fault Test Procedure and Aggregate Data into DQ_SCORE TABLE
-- This should be run via a batch job and scheduled
-- Version 2.1 szf

IS
    PROC_NAME VARCHAR2(40):= 'DQP_RUN_CHECKS'; 
    
    V_RUN_NUMBER INTEGER;
    V_RUN_DATE DATE;
    V_DEPLOY_FLAG VARCHAR2(10);
    
    V_CDE_NAME VARCHAR2(80);
    cdeRow INTEGER;
    cdeProcName VARCHAR2(60);
    procSQL VARCHAR2(100);
    procCount INTEGER;
    errMessage VARCHAR2(1000);


BEGIN
    

    V_RUN_NUMBER:= fGETNextRunNumber(); -- get next incremental run number from result set
    V_RUN_DATE:= SYSDATE; -- current date and time
    V_DEPLOY_FLAG:= 'T'; -- T for test environment; Change to P when deploy to production
    
    FOR cdeRow IN (SELECT CDE_ID,CDE_NAME from CDE) LOOP -- loop through all the CDEs and get associated PROC name
    
        V_CDE_NAME:= cdeRow.CDE_NAME;
        cdeProcName:= fCompress30( V_CDE_NAME); --calcuate proc name based on CDE Name
        
       --dbms_output.put_line(cdeProcName);
      
       --check if procedure exists
      SELECT COUNT(*) INTO procCount FROM USER_PROCEDURES WHERE OBJECT_NAME = cdeProcName AND OBJECT_TYPE = 'PROCEDURE' ;
      IF procCount > 0 THEN -- proc exists
              procSQL:= 'BEGIN '|| cdeProcName || '(' || V_RUN_NUMBER || ',' || fEncloseQuotes(V_RUN_DATE) || ',' ||
                fEncloseQuotes (V_DEPLOY_FLAG) || '); END;';
                
			--dbms_output.put_line(' ### execute procSQL: ' || procSQL);
			EXECUTE IMMEDIATE  procSQL; --run the PROCedure

        ELSE
            
            errMessage:= '!!! ERROR, PROCEDURE ' || cdeProcName ||
            ' Does''nt exist for CDE ' || V_CDE_NAME;
            DQ_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,V_CDE_NAME,0, errMessage,'F');
            dbms_output.put_line(errMessage);
              
        END IF;    
    END LOOP;
	-- Aggregate data into  DQ_Score TABLE
	SCORE_INSERT(V_RUN_NUMBER, V_RUN_DATE);
EXCEPTION
		WHEN OTHERS THEN
        errMessage:= '!!! ERROR, PROCEDURE ' || cdeProcName ||
            ' Does''nt exist for CDE ' || V_CDE_NAME;
        DQ_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,V_CDE_NAME,0, errMessage,'F');
       
		DBMS_OUTPUT.PUT_LINE ('An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		raise_application_error(-20001,'An error was encountered in procedure '|| PROC_NAME || ' - '||SQLCODE||' -ERROR- '||SQLERRM);    

END;