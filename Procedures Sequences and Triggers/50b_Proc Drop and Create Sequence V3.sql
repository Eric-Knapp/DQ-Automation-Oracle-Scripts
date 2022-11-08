create or replace PROCEDURE         DQP_DROP_CREATE_SEQUENCE (V_SCHEMA_NAME VARCHAR2, V_sequence_Name VARCHAR2)

-- Procedure to Drop Sequence if Exists

IS
    PROC_NAME VARCHAR2(40):= 'DQP_DROP_CREATE_SEQUENCE'; 

	Does_Exist_Flag INTEGER;
    numSequences INTEGER;
    drop_String VARCHAR2(200);
    create_String VARCHAR2(200);

BEGIN -- drop and create sequence
    drop_String:= 'DROP SEQUENCE '|| V_SCHEMA_NAME || '.'  || V_sequence_Name;
    SELECT COUNT(*) INTO  numSequences FROM  ALL_SEQUENCES 
            WHERE SEQUENCE_NAME = V_sequence_Name;
    If  numSequences >0 THEN -- If exists
        DBMS_OUTPUT.PUT_LINE ('### Found it, Dropping and Creating Seq ' ||  V_sequence_Name);
        EXECUTE IMMEDIATE drop_String ;
        Commit;
    ELSE
        DBMS_OUTPUT.PUT_LINE ('### Sequence ' ||  V_sequence_Name || ' does not exist. Will Create');
    END IF;
-- Creat the Seq
    create_String:= 'CREATE SEQUENCE '|| V_SCHEMA_NAME || '.'  || V_sequence_Name;
     EXECUTE IMMEDIATE create_String ;
     COMMIT;

EXCEPTION
		WHEN OTHERS THEN        
		DBMS_OUTPUT.PUT_LINE ('An error was encountered in procedure ' || PROC_NAME || ' - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		raise_application_error(-20001,'An error was encountered in procedure '|| PROC_NAME || ' - '||SQLCODE||' -ERROR- '||SQLERRM);    

END;
