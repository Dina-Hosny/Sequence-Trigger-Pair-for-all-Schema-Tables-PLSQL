DECLARE

--decalre a cursor to containt each tables name and its numeric primary key columns.
    
    CURSOR primary_data IS

        SELECT tab.table_name, col.column_name
        FROM user_constraints tab           --contain the the table name and each constraint it have and its type.
        JOIN user_cons_columns col         --contain the constraint name and the column name that it apply on it
        ON tab.table_name = col.table_name
        AND tab.constraint_name = col.constraint_name
        JOIN user_tab_columns dtype     --contain table and its the columns data types
        ON dtype.table_name = col.table_name
        AND dtype.column_name = col.column_name
        WHERE TAB.CONSTRAINT_TYPE='P'           --the constraint of "Primary Key" type
        AND dtype.data_type = 'NUMBER';
        
--declare variable to store the start sequence value        
    v_start_seq NUMBER(8);    
--declare variable to store the sequence name                
    v_seq_name VARCHAR2(250);     
--declare variable to store the trigger name      
    v_trigg_name VARCHAR2(250);         




BEGIN

    FOR primary_rec IN primary_data
    LOOP
    
        v_seq_name := primary_rec.table_name || '_seq';         --sequence name depends on the current table name
        v_trigg_name := primary_rec.table_name||'_trig';        --trigger name depends on the current table name
        
--drop existing sequence with the same name 
        
         EXECUTE IMMEDIATE 'DROP SEQUENCE ' || v_seq_name ;     
         
--find the start sequence value by getting the maximum value in the ID column and increment it by 1 to start after last ID value, if no values in this column start with 0 

         EXECUTE IMMEDIATE 'SELECT NVL(MAX ( '|| primary_rec.column_name || '),0)+1 FROM ' ||primary_rec.table_name         
         INTO v_start_seq;          --the value that sequence will start with
         
--create sequence using dynamic sequence         
        
         EXECUTE IMMEDIATE          
         'CREATE SEQUENCE ' || v_seq_name
         ||' START WITH ' || v_start_seq
         ||' INCREMENT BY 1';
         
--create or replace trigger if exist to auto insert an ID vaue based on the sequence current value (Row Level Trigger)         

         EXECUTE IMMEDIATE          
         'CREATE OR REPLACE TRIGGER ' || v_trigg_name 
          || ' BEFORE INSERT ON ' || primary_rec.table_name
          || ' FOR EACH ROW '
          || ' BEGIN '
          || ' :NEW.' || primary_rec.column_name || ' := ' || v_seq_name || '.NEXTVAL;'
          || ' END; ';
        

    END LOOP;

END;


SHOW ERRORS;
