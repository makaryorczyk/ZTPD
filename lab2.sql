-- Lab 2 - Duze obiekty binarne

-- Ex. 1
CREATE table MOVIES_COPY as select * from ZTPD.MOVIES;

-- Ex. 2

select *
from ZTPD.MOVIES
    FETCH FIRST 5 ROWS ONLY;

-- Ex. 3

SELECT id, title from ZTPD.MOVIES WHERE cover is NULL;

-- Ex. 4

SELECT id, title, lengthb(cover) as filesize from ZTPD.MOVIES WHERE cover is NOT NULL;

-- Ex. 5

SELECT id, title, lengthb(cover) as filesize from ZTPD.MOVIES WHERE cover is NULL;

-- Ex. 6

select DIRECTORY_NAME, DIRECTORY_PATH from ALL_DIRECTORIES;

-- Ex. 7

update MOVIES_COPY
set COVER=EMPTY_BLOB(), MIME_TYPE='image/jpeg'
where id = 66;

-- Ex. 8

SELECT id, title, lengthb(cover) as filesize from ZTPD.MOVIES WHERE id=65 OR id=66;

-- Ex. 9
-- TODO

DECLARE
    movies BLOB;
    okladka BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
BEGIN


END;
-- TODO

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

-- TODO verify
select movie_id, image as filesize from TEMP_COVERS;
-- TODO verify

-- Ex. 13

DECLARE
    mime varchar2(50);
    okladka BFILE;
    bblob BLOB;

BEGIN
    SELECT image, mime_time
    into okladka, mime
    from TEMP_COVERS
    where movie_id = 65;

    DBMS_LOB.createtemporary(bblob, TRUE);
    DBMS_LOB.fileopen(okladka, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(blobb, okladka, DBMS_LOB.getlength(okladka));
    DBMS_LOB.fileclose(okladka);

    UPDATE MOVIES_CP
    SET cover = bblob,
        MIME_TYPE = mime
    WHERE id = 65;

    DBMS_LOB.freetemporary(bblob);
    COMMIT;
end;

-- Ex. 14

SELECT id, title, lengthb(cover) as filesize from ZTPD.MOVIES WHERE id=65 OR id=66;

-- Ex. 15

DROP TABLE MOVIES_COPY;