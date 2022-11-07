CREATE or REPLACE PROCEDURE DCUA166.DQP_RECI_MAIL_ADDR_LINE_1(V_Run_Number INTEGER, V_Run_Date Date, V_dePloyFlag VARCHAR2)
-- DQ Procedure for CDE Recipient Mailing Address Address Line 1
-- input parameters are run number from seq generator, Run Date, and V_dePloyFlag 'T' or 'P'
-- Version 8b szf
IS

	PROC_NAME VARCHAR2(40):= 'DQP_RECI_MAIL_ADDR_LINE_1'; --Recipient Address Line 1

	PROC_STATUS VARCHAR2(20);
	--CDE_ID INTEGER:= 10;

	CDE_REF_RECORD CDE_REF_REC_TYPE; --CDE_NAME,CDE_ID,RULE_NAME, RULE_ID,DOMAIN_NAME, DOMAIN_ID
	V_TABLE_LIST CDE_TABLES_TYPE;

	V_CDE_RULE_ID INTEGER;

	V_CDE_Total_Population INTEGER:=0; -- total records in population
	V_CDE_Number_Null_Records INTEGER:= 0; -- Number of Null Records in Population of records scanned
	V_CDE_Total_Non_Null_Records INTEGER:=0; --total records - number of null records
	V_CDE_Number_Failed_Records INTEGER:=0; -- test for failures not including nulls
	V_TOTAL_RECS_INSERTED INTEGER:=0; -- total recs insert into RESULT_SET

	V_Address_Type VARCHAR2(20):='MA'; -- Set to mailing address for this CDE

	-- Dynamic query strings
	totalNumberQueryString VARCHAR2(6000);
	numberNullQueryString VARCHAR2(6000);
	numberFailuresQueryString VARCHAR2(6000);
	subQueryStringBase VARCHAR2(6000);
	subQueryStringCustom VARCHAR2(6000);
	insertPreString VARCHAR2(7000);
	insertAllString VARCHAR2(8000);
	insertMaxString  VARCHAR2(8000);

BEGIN
	V_CDE_RULE_ID:= 24; -- Test mailing address line 1 for nulls
	
	V_TABLE_LIST:= fSET_CDETEDS_TABLE_NAMES (V_DEPLOYFLAG); -- Set table names
	CDE_REF_RECORD:= fGET_CDE_REFERENCE_DATA (V_CDE_RULE_ID); --Get reference data: CDE_NAME,CDE_ID,RULE_NAME, RULE_ID,DOMAIN_NAME, DOMAIN_ID

	SUBQUERYSTRINGBASE:=
			'SELECT DISTINCT(B.INDV_ID),A.CASE_NUM, A.CREATE_DT, A.UPDATE_DT, A.ADDR_LINE1, 
			  A.ADDR_LINE, A.ADDR_TYPE_CD, A.ADDR_FORMAT, C.FIRST_NAME, C.LAST_NAME, C.INACTIVE_IND, 
			  B.EFF_END_DT, B.ACTIVE_IN_CASE_SW, D.CASE_STATUS_CD 
			FROM ' ||	
			  V_TABLE_LIST.CASEADDRESSTABLENAME || ' A
			  JOIN ' ||  V_TABLE_LIST.CASEINDIVTABLENAME || ' B ON A.CASE_NUM = B.CASE_NUM 
			  JOIN ' ||  V_TABLE_LIST.INDIVTABLENAME ||' C ON B.INDV_ID = C.INDV_ID  
			  JOIN ' ||  V_TABLE_LIST.CASESTABLENAME || ' D ON B.CASE_NUM = D.CASE_NUM 
			  JOIN ' ||  V_TABLE_LIST.ELIGIBLETABLENAME || ' E ON C.INDV_ID = E.MEDICAID_INDV_ID '
			|| ' WHERE 
			  A.ADDR_TYPE_CD = ' || FENCLOSEQUOTES(V_ADDRESS_TYPE) || ' AND A.ADDR_FORMAT = ''US''
			  AND C.INACTIVE_IND = ''N''AND A.EFF_END_DT IS NULL AND B.EFF_END_DT IS NULL
			  AND B.ACTIVE_IN_CASE_SW = ''Y'' AND D.CASE_STATUS_CD = ''AP''
			  AND FISELIGIBLE (''T'', B.INDV_ID) = 1' ; 
			  
	totalNumberQueryString:= 'SELECT Count(*) FROM (' || subQueryStringBase || ')' ;
		--DBMS_OUTPUT.PUT_LINE ('Total Query String: ' || totalNumberQueryString ); --debug
	EXECUTE IMMEDIATE totalNumberQueryString INTO V_CDE_Total_Population; -- Get total population


	subQueryStringCustom:= subQueryStringBase || ' and fNullorBlank(a.ADDR_LINE1) = 1 '; 		 -- For NULL Test
		
	numberNullQueryString:= 'SELECT Count(*) FROM (' || subQueryStringCustom || ')' ;
	EXECUTE IMMEDIATE numberNullQueryString INTO V_CDE_Number_Null_Records; -- Get total number of address 1 nulls
	IF V_CDE_Number_Null_Records is null THEN V_CDE_Number_Null_Records:= 0; END IF;

	V_CDE_Total_Non_Null_Records:=V_CDE_Total_Population - V_CDE_Number_Null_Records; --remaing population


	-- Get Null Record Errors into Result Set
	insertPreString:=
	'INSERT INTO RESULT_SET
		SELECT RUN_RESULT_SEQ.nextval,' ||  fEncloseQuotes(V_RUN_DATE) ||',' || V_RUN_NUMBER || ',' ||
		V_CDE_RULE_ID || ',' || fEncloseQuotes(CDE_REF_RECORD.DOMAIN_NAME)|| ',' || CDE_REF_RECORD.DOMAIN_ID || ',' || 
		fEncloseQuotes(CDE_REF_RECORD.CDE_NAME)|| ',' || CDE_REF_RECORD.CDE_ID || ',' || 
		CDE_REF_RECORD.RULE_ID || ',' || fEncloseQuotes(CDE_REF_RECORD.RULE_NAME)|| ',' ||
		V_CDE_Total_Population || ',
		''Error Rule Check:'' || ''Indv_ID: '' || indv_id || '' First Name: '' || FIRST_NAME   || '' Last Name: '' || LAST_NAME  '; -- add others as required
		  

	 --    DBMS_OUTPUT.PUT_LINE ('insertPreString: ' || insertPreString); --debug
		 

	-- Insert NULL Records if exist into Result_Set
	insertAllString:= insertPreString || 'FROM (' || subQueryStringCustom || ')' ;

	--DBMS_OUTPUT.PUT_LINE ('sinsertAllString : ' || insertAllString); --debug
	IF V_CDE_Number_Null_Records > 0 THEN
		EXECUTE IMMEDIATE insertAllString;
		COMMIT; -- COMMIT Inserts
	END IF;

	-- Other Failures
	V_CDE_RULE_ID:= 23; -- Test MaxLength
	CDE_REF_RECORD:= fGET_CDE_REFERENCE_DATA (V_CDE_RULE_ID); --CDE_NAME,CDE_ID,RULE_NAME, RULE_ID,DOMAIN_NAME, DOMAIN_ID
	--insertMaxString:= insertPreString ||  ' || '' Last Address Line 1: '' || ADDR_LINE1 '; -- add to error message
	insertMaxString:='INSERT INTO RESULT_SET
		SELECT RUN_RESULT_SEQ.nextval,' ||  fEncloseQuotes(V_RUN_DATE) ||',' || V_RUN_NUMBER || ',' ||
		V_CDE_RULE_ID || ',' || fEncloseQuotes(CDE_REF_RECORD.DOMAIN_NAME)|| ',' || CDE_REF_RECORD.DOMAIN_ID || ',' || 
		fEncloseQuotes(CDE_REF_RECORD.CDE_NAME)|| ',' || CDE_REF_RECORD.CDE_ID || ',' || 
		CDE_REF_RECORD.RULE_ID || ',' || fEncloseQuotes(CDE_REF_RECORD.RULE_NAME)|| ',' ||
		V_CDE_Total_Non_Null_Records || ',
		''Error Rule Check:'' || ''Indv_ID: '' || indv_id || '' First Name: '' || FIRST_NAME   || '' Last Name: '' || LAST_NAME  || 
		'' Address Line 1: '' || ADDR_LINE1 ';
		  
	-- Test for MaxChars	
	subQueryStringCustom:= SUBQUERYSTRINGBASE || ' and fNullorBlank(a.ADDR_LINE1) < 1 and fExceedMaxChars(a.ADDR_LINE1,88) > 0 ';
  
    
    numberFailuresQueryString:= 'Select count(*) From (' || subQueryStringCustom || ')';
    --DBMS_OUTPUT.PUT_LINE ('numberFailuresQueryString:: ' || numberFailuresQueryString); --debug
    EXECUTE IMMEDIATE numberFailuresQueryString INTO V_CDE_Number_Failed_Records;
    IF V_CDE_Number_Failed_Records IS NULL THEN V_CDE_Number_Failed_Records:=0; END IF;
    --DBMS_OUTPUT.PUT_LINE ('numberFaiked recs:: ' || V_CDE_Number_Failed_Records); --debug
	-- Need to add test for no records returned
	IF V_CDE_Number_Failed_Records > 0 THEN
        insertAllString:= insertMaxString || ' FROM (' || subQueryStringCustom|| ')' ;
	    --DBMS_OUTPUT.PUT_LINE ('insertAllString: ' || insertAllString); --debug
        EXECUTE IMMEDIATE insertAllString;
        COMMIT;
    END IF;
    
    V_TOTAL_RECS_INSERTED:=V_CDE_Number_Failed_Records + V_CDE_Number_Null_Records; -- number of recs inserted into RESULT_SET
    DQP_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,CDE_REF_RECORD.CDE_NAME,V_TOTAL_RECS_INSERTED, 'SUCCESS','S');

	
	-------------------------- Tested Through Here-------
	EXCEPTION
		WHEN OTHERS THEN
         DQP_STATUS_LOG_UPDATE(V_RUN_NUMBER,V_RUN_DATE,CDE_REF_RECORD.CDE_NAME,V_TOTAL_RECS_INSERTED, ' Failed: '
         ||  PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM,'F');
       -- 'An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		DBMS_OUTPUT.PUT_LINE ('An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		raise_application_error(-20001,'An error was encountered in procedure '|| PROC_NAME || ' - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/

