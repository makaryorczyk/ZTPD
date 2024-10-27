DROP TABLE WLASCICIELE;
DROP TABLE SAMOCHODY;
DROP TYPE SAMOCHOD;

-- Ex. 1

CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
      marka VARCHAR2(20),
      model VARCHAR2(20),
      kilometry NUMBER,
      data_produkcji DATE,
      cena NUMBER(10, 2)
);

CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('Toyota', 'Corolla', 50000, TO_DATE('2018-05-20', 'YYYY-MM-DD'), 60000));
INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('BMW', 'X5', 120000, TO_DATE('2016-10-15', 'YYYY-MM-DD'), 120000));
INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('Audi', 'A4', 75000, TO_DATE('2019-03-10', 'YYYY-MM-DD'), 85000));

SELECT * FROM SAMOCHODY;

-- Ex. 2

CREATE TABLE WLASCICIELE (
     imie VARCHAR2(100),
     nazwisko VARCHAR2(100),
     auto SAMOCHOD
);

INSERT INTO WLASCICIELE VALUES (
    'Jan', 'Kowalski', SAMOCHOD('Fiat', 'Seicento', 30000, TO_DATE('2010-12-02', 'YYYY-MM-DD'), 19500));

INSERT INTO WLASCICIELE VALUES (
    'Adam', 'Nowak', SAMOCHOD('Opel', 'Astra', 34000, TO_DATE('2009-06-01', 'YYYY-MM-DD'), 33700));

SELECT * FROM WLASCICIELE;

-- Ex. 3

ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena*power(0.9,extract(year from current_date) - extract(year from data_produkcji));
    END wartosc;
    MAP MEMBER FUNCTION VALUE RETURN NUMBER IS
    BEGIN
        RETURN (extract(year from current_date) - extract(year from data_produkcji)) + kilometry/10000;
    END VALUE;
END;

-- Ex. 4

SELECT marka, cena, p.wartosc() FROM SAMOCHODY p;

ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION VALUE
    RETURN NUMBER CASCADE INCLUDING TABLE DATA;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

-- Ex. 5

CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);

ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    wlasciciel REF WLASCICIEL,
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE TABLE Wlasciciele_tab OF WLASCICIEL;

INSERT INTO Wlasciciele_tab VALUES (WLASCICIEL('Jan', 'Kowalski'));
INSERT INTO Wlasciciele_tab VALUES (WLASCICIEL('Adam', 'Nowak'));

-- Ex. 6

DECLARE
TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
            moje_przedmioty(i) := 'PRZEDMIOT_' || i;
        END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

-- Ex. 7

DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki.extend(9);
    moje_ksiazki(1) := 'Cien wiatru';
    moje_ksiazki(2) := 'Ostatnie zyczenie';
    moje_ksiazki(3) := 'Miecz przeznaczenia';
    moje_ksiazki(4) := 'Krew elfow';
--     moje_ksiazki.EXTEND('Ostatnie zyczenie');
    FOR i IN 2..10 LOOP
            moje_ksiazki(i) := 'Ksiazka_' || i;
        END LOOP;
    moje_ksiazki.DELETE();
END;

-- Ex. 8

DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
            moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
        END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- Ex. 9

DECLARE
    -- Definicja zagnieżdżonej tablicy miesięcy
    TYPE t_miesiace IS TABLE OF VARCHAR2(15);
    miesiace t_miesiace := t_miesiace();
BEGIN
    -- Dodanie miesięcy do kolekcji
    miesiace.EXTEND(12);
    miesiace(1) := 'Styczen';
    miesiace(2) := 'Luty';
    miesiace(3) := 'Marzec';
    miesiace(4) := 'Kwiecien';
    miesiace(5) := 'Maj';
    miesiace(6) := 'Czerwiec';
    miesiace(7) := 'Lipiec';
    miesiace(8) := 'Sierpien';
    miesiace(9) := 'Wrzesien';
    miesiace(10) := 'Pazdziernik';
    miesiace(11) := 'Listopad';
    miesiace(12) := 'Grudzien';

    DBMS_OUTPUT.PUT_LINE('Przed usunieciem:');
    FOR i IN miesiace.FIRST..miesiace.LAST LOOP
            DBMS_OUTPUT.PUT_LINE(miesiace(i));
        END LOOP;

    miesiace.DELETE(7, 8); -- Usuniecie

    DBMS_OUTPUT.PUT_LINE('Po usunieciu:');
    FOR i IN miesiace.FIRST..miesiace.LAST LOOP
            IF miesiace.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(miesiace(i));
            END IF;
        END LOOP;
END;

-- Ex. 10

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);

CREATE TYPE stypendium AS OBJECT (
                                     nazwa VARCHAR2(50),
                                     kraj VARCHAR2(30),
                                     jezyki jezyki_obce );

CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
    ('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
    ('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);

CREATE TYPE semestr AS OBJECT (
                                  numer NUMBER,
                                  egzaminy lista_egzaminow );

CREATE TABLE semestry OF semestr
    NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
    (semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
    (semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';


-- Ex. 11

CREATE TYPE Produkt AS OBJECT (
  nazwa VARCHAR(200),
  cena NUMBER(10, 2)
);

CREATE TYPE Koszyk_Produktow AS TABLE OF Produkt;

CREATE TABLE Zakupy (
    zakup_id NUMBER,
    koszyk Koszyk_Produktow
) NESTED TABLE koszyk STORE AS koszyk_produktow_nt;

INSERT INTO Zakupy VALUES (1,
Koszyk_Produktow(Produkt('Czekolada', 3.50), Produkt('Smietana', 4.20))
);
INSERT INTO Zakupy VALUES (2,
Koszyk_Produktow(Produkt('Maka', 1.20), Produkt('Banany', 5.00))
);

SELECT z.zakup_id, p.nazwa, p.cena
FROM Zakupy z, TABLE(z.koszyk) p;

DELETE FROM Zakupy z
WHERE EXISTS (
    SELECT 1 FROM TABLE(z.koszyk) p
    WHERE p.nazwa = 'Banany'
);

-- Ex. 12

CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;

CREATE OR REPLACE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN dzwiek;
    END;
END;


CREATE TYPE instrument_dety UNDER instrument (
     material VARCHAR2(20),
     OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
     MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );


CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dmucham: '||dzwiek;
    END;
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN glosnosc||':'||dzwiek;
    END;
END;


CREATE TYPE instrument_klawiszowy UNDER instrument (
   producent VARCHAR2(20),
   OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );

CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'stukam w klawisze: '||dzwiek;
    END;
END;


DECLARE
    tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;


-- Ex. 13

CREATE TYPE istota AS OBJECT (
                                 nazwa VARCHAR2(20),
                                 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
    NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
                                 liczba_nog NUMBER,
                                 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: '||ofiara;
    END;
END;
DECLARE
    KrolLew lew := lew('LEW',4);
    InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
    DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

-- Ex. 14

DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;


-- Ex. 15

CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
                               );
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;