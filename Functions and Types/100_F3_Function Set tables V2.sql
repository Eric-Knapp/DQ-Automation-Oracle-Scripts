-- Get CDE Reference Values for Given CDE_RULEID
CREATE OR REPLACE TYPE DCUA166.CDE_TABLES_TYPE AS OBJECT--Type to hold Tables List
(
	indivTableName VARCHAR2(40),
	eligibleTableName VARCHAR2(40),
	caseIndivTableName VARCHAR2(40),
	casesTableName VARCHAR2(40),
	caseAddressTableName VARCHAR2(40),
    stateCodeTableName VARCHAR2(40),
    countyCodeTableName  VARCHAR2(40),
    indivAlienTableName  VARCHAR2(40)  
);
/
CREATE OR REPLACE FUNCTION DCUA166.fSET_CDETEDS_TABLE_NAMES (V_DeployFlag IN VARCHAR2)
return CDE_TABLES_TYPE 
AS 
   TLIST CDE_TABLES_TYPE;
BEGIN
    TLIST:= NEW CDE_TABLES_TYPE (null,null,null,null,null,null,null,null);

	IF V_DePloyFlag = 'P' THEN	
		-- substitue prod table names and schema
		TLIST.indivTableName:= 'IE_APP_ONLINE.DC_INDV';
		TLIST.eligibleTableName:= 'IE_APP_ONLINE.ED_ELIGIBILITY';
		TLIST.caseIndivTableName:= 'IE_APP_ONLINE.DC_CASE_INDIVIDUAL';
		TLIST.casesTableName:= 'IE_APP_ONLINE.DC_CASES';
		TLIST.caseAddressTableName:= 'IE_APP_ONLINE.DC_CASE_ADDRESSES';
		TLIST.stateCodeTableName:= 'ie_app_online.State';
		TLIST.countyCodeTableName:= 'ie_app_online.County';
		TLIST.indivAlienTableName:= 'Ie_app_online.dc_individual_alien';
	ELSE
		TLIST.indivTableName:= 'Dummy_Table';
		TLIST.eligibleTableName:= 'dummy_eligibility';
		TLIST.caseIndivTableName:= 'DUMMY_DC_CASE_INDIVIDUAL';
		TLIST.casesTableName:= 'DUMMY_DC_CASES';
		TLIST.caseAddressTableName:= 'DUMMY_DC_CASE_ADDRESSES';
		TLIST.stateCodeTableName:= 'State_Code';
		TLIST.countyCodeTableName:= 'County_Code';
		TLIST.indivAlienTableName:= 'individual_alien';
	END IF;


   RETURN (TLIST);  
   
END;