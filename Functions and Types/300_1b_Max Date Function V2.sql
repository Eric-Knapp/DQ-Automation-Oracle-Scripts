
CREATE OR REPLACE FUNCTION DCUA166.fGETMAXDATE (DATE_FIELD_NAME IN VARCHAR2, TABLE_NAME IN VARCHAR2)
RETURN date

-- Function to calculate latest date from TABLE

AS

maxDate Date;
getDateSQL VARCHAR2(200);

BEGIN

    getDateSQL := 'SELECT MAX(' || DATE_FIELD_NAME ||  ')  FROM ' || TABLE_NAME;
    dbms_output.put_line('max date SQL: ' || getDateSQL);
    EXECUTE IMMEDIATE getDateSQL INTO maxDate;
   
    IF  maxDate IS NULL then
        --dbms_output.put_line('date is null');
        return TO_DATE('1975-01-01','YYYY-MM-DD');
    
    ELSE
        return maxDate;
    END IF;

    
-- 
exception 
    when NO_DATA_FOUND then
        dbms_output.put_line('no data found');
        return TO_DATE('1975-01-01','YYYY-MM-DD');

END;
