set serveroutput on 10000000
declare 

cursor main_curs is

select distinct u.*

from user_cons_columns u, user_tab_columns a,  user_constraints c

where u.COLUMN_NAME = a.COLUMN_NAME
AND C.TABLE_NAME = U.TABLE_NAME
AND data_type = 'NUMBER'
AND u.constraint_name like '%_PK' 
AND C.R_CONSTRAINT_NAME is null
AND c.table_name in (SELECT TABLE_NAME
from user_cons_columns
where constraint_name like '%_PK'
GROUP BY TABLE_NAME
having count(column_name) = 1);

seq_start number (10);
v_no_of_seq number (2);


begin

for curs_rec in main_curs loop

         SELECT COUNT(SEQUENCE_NAME)
                  INTO v_no_of_seq 
                  FROM user_sequences                   
                  where upper(SEQUENCE_NAME) = upper (curs_rec.table_name || '_SEQ');
                   DBMS_OUTPUT.put_line(curs_rec.table_name || ' , ' ||  v_no_of_seq );
                  
                  if v_no_of_seq > 0 then
                  EXECUTE IMMEDIATE 'drop sequence ' || curs_rec.table_name || '_SEQ';
                  v_no_of_seq := 0;
                  end if;
                  DBMS_OUTPUT.put_line(curs_rec.table_name || ' , ' ||  v_no_of_seq );
                  
                  
        
        EXECUTE IMMEDIATE 'SELECT nvl(MAX( ' || curs_rec.column_name ||' ), 0)' || ' FROM ' || curs_rec.table_name INTO seq_start;
        
        EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || curs_rec.table_name || '_SEQ ' || ' START WITH ' || (seq_start +1);
        DBMS_OUTPUT.put_line(seq_start);

        EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || curs_rec.table_name || '_TRIG BEFORE INSERT ON ' || curs_rec.table_name ||
         ' FOR EACH ROW BEGIN :new.' || curs_rec.column_name || ' := ' || curs_rec.table_name || '_SEQ.nextval; END;';
            

end loop;
end;