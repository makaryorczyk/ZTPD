-- Lab 2 - Duze obiekty binarne

-- Ex. 1
CREATE table MOVIES_COPY as select * from ZTPD.MOVIES;

-- Ex. 2

select * from MOVIES_COPY FETCH FIRST 5 ROWS ONLY;

-- Ex. 3

SELECT id, title from MOVIES_COPY WHERE cover is NULL;

-- Ex. 4

SELECT id, title, lengthb(cover) as filesize from MOVIES_COPY WHERE cover is NOT NULL;

-- Ex. 5

SELECT id, title, lengthb(cover) as filesize from MOVIES_COPY WHERE cover is NULL;

-- Ex. 6

select DIRECTORY_NAME, DIRECTORY_PATH from ALL_DIRECTORIES;

-- Ex. 7

update MOVIES_COPY
set COVER=EMPTY_BLOB(), MIME_TYPE='image/jpeg'
where id = 66;

-- Ex. 8

SELECT id, title, lengthb(cover) as filesize from MOVIES_COPY WHERE id=65 OR id=66;

-- Ex. 9

DECLARE
    movies BLOB;
    okladka BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
BEGIN
    SELECT COVER into movies
    from MOVIES_COPY
    where id = 66
        for update;
    DBMS_LOB.fileopen(okladka, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(movies, okladka, DBMS_LOB.GETLENGTH(okladka));
    DBMS_LOB.FILECLOSE(okladka);
    COMMIT;
END;

-- Ex. 10

DROP TABLE TEMP_COVERS;

CREATE TABLE TEMP_COVERS (
     movie_id NUMBER(12),
     image BLOB,
     mime_time VARCHAR2(50)
) lob (image)
store as (
 disable storage in row
 chunk 4096
 pctversion 20
 nocache
 nologging
);

-- Ex. 11

insert into TEMP_COVERS values (65, BFILENAME('TPD_DIR', 'eagles.jpg'), 'image/jpg');

-- Ex. 12

select movie_id, image as filesize from TEMP_COVERS;

-- Ex. 13

DECLARE
    mime varchar2(50);
    okladka BFILE;
    bblob BLOB;
BEGIN
    SELECT image, mime_time
    into okladka, mime
    from TEMP_COVERS
    where movie_id=65;
    DBMS_LOB.createtemporary(bblob, TRUE);
    DBMS_LOB.fileopen(okladka, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(bblob, okladka, DBMS_LOB.getlength(okladka));
    DBMS_LOB.fileclose(okladka);
    UPDATE MOVIES_COPY
    SET cover = bblob,
        MIME_TYPE = mime
    WHERE id = 65;
    DBMS_LOB.freetemporary(bblob);
    COMMIT;
end;

-- Ex. 14

SELECT id, title, lengthb(cover) as filesize from MOVIES_COPY WHERE id=65 OR id=66;

-- Ex. 15

DROP TABLE MOVIES_COPY;