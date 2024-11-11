-- Lab 3 - Duze obiekty tekstowe

-- Zad 1.

CREATE TABLE DOKUMENTY (
   ID NUMBER(12) PRIMARY KEY,
   DOKUMENT CLOB
);

-- Zad 2.

DECLARE
    doc CLOB;
Begin
    DBMS_LOB.createTemporary(doc, TRUE);
    FOR i in 1..10000 LOOP
            doc := doc || 'Oto tekst. ';
        END LOOP;
    INSERT INTO DOKUMENTY VALUES (1, doc);
    COMMIT;
    DBMS_LOB.freeTemporary(doc);
END;

-- Zad 3.

-- a)
SELECT * FROM DOKUMENTY;
-- b)
SELECT UPPER(dokument) FROM DOKUMENTY;
-- c)
SELECT LENGTH(dokument) FROM DOKUMENTY;
-- d)
SELECT DBMS_LOB.getLength(dokument) FROM DOKUMENTY;
-- e)
SELECT SUBSTR(dokument, 5, 1000) FROM DOKUMENTY;
-- f)
SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM DOKUMENTY;

-- Zad 4.
INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

-- Zad 5.
INSERT INTO DOKUMENTY VALUES (3, NULL);
COMMIT;

-- Zad 7.
DECLARE
    dane CLOB;
    plik BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    dest_offset integer := 1;
    src_offset integer := 1;
    lang_context integer := 0;
    warning integer := null;
BEGIN
    SELECT dokument into dane
    from DOKUMENTY
    where id = 2
        for update;
    DBMS_LOB.fileopen(plik, DBMS_LOB.file_readonly);
    DBMS_LOB.loadClobFromFile(dane, plik, DBMS_LOB.LOBMAXSIZE, dest_offset, src_offset, 0, lang_context, warning);
    DBMS_LOB.FILECLOSE(plik);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status: ' || warning);
END;

-- Zad 8.
update DOKUMENTY
set dokument = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'))
where id = 3;

-- Zad 9.
SELECT * FROM DOKUMENTY;

-- Zad 10.
SELECT id, DBMS_LOB.getLength(dokument) FROM DOKUMENTY;

-- Zad 11.
DROP TABLE DOKUMENTY;

-- Zad 12.

CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    data IN OUT CLOB,
    replace_text IN VARCHAR2
)
    IS
    start_pos INTEGER := 1;
    word_len INTEGER;
    dots VARCHAR2(1000);
BEGIN
    word_len := length(replace_text);
    IF word_len > 0 THEN
        dots := LPAD('.', word_len, '.');
        LOOP
            start_pos := INSTR(data, replace_text, start_pos);
            EXIT WHEN start_pos = 0;
            DBMS_LOB.WRITE(data, word_len, start_pos, dots);
            start_pos := start_pos + word_len;
        end loop;
    end if;
end;

-- Zad 13.
DROP TABLE BIOGRAPHIES;
CREATE table BIOGRAPHIES as select * from ZTPD.BIOGRAPHIES;

DECLARE
    data clob;
Begin
    SELECT bio into data from BIOGRAPHIES where id = 1 for update ;
    CLOB_CENSOR(data, 'Cimrman');
    UPDATE BIOGRAPHIES set BIO = data where id = 1;
    COMMIT;
END;

SELECT * FROM BIOGRAPHIES;

-- Zad 14.

DROP TABLE BIOGRAPHIES;