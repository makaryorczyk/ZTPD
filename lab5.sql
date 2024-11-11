-- Lab 5 - Przetwarzanie danych przestrzennych part 2

-- Zad 1

-- A

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'FIGURY',
    'ksztalt',
    SDO_DIM_ARRAY(
      SDO_DIM_ELEMENT('X', -10, 10, 0.01),
      SDO_DIM_ELEMENT('Y', -10, 10, 0.01)
    ), NULL);

-- B

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) FROM DUAL;

-- C

CREATE INDEX FIGURY_INDEX ON FIGURY (KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- D

SELECT ID FROM FIGURY WHERE SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL)) = 'TRUE';

-- E

SELECT ID FROM FIGURY WHERE SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL), 'mask=ANYINTERACT') = 'TRUE';


-- Zad 2.

-- A

SELECT * FROM MAJOR_CITIES;

SELECT C.CITY_NAME, ROUND(SDO_NN_DISTANCE(1)) DISTANCE
FROM MAJOR_CITIES C
WHERE SDO_NN(GEOM,(SELECT geom FROM MAJOR_CITIES WHERE ADMIN_NAME = 'Warszawa'),
            'sdo_num_res=9 unit=km',1) = 'TRUE' AND ROUND(SDO_NN_DISTANCE(1)) > 0
ORDER BY Distance;

-- B


SELECT C.CITY_NAME
FROM MAJOR_CITIES C
WHERE SDO_WITHIN_DISTANCE(GEOM, (SELECT geom FROM MAJOR_CITIES WHERE ADMIN_NAME = 'Warszawa'), 'distance=100 unit=km') = 'TRUE';

-- C.

SELECT C.CNTRY_NAME, M.city_name
FROM COUNTRY_BOUNDARIES C,  MAJOR_CITIES M
WHERE C.CNTRY_NAME = 'Slovakia'
  and SDO_GEOM.RELATE(C.GEOM, 'DETERMINE', M.GEOM, 1) = 'CONTAINS';

-- D.

SELECT C.Cntry_name, ROUND(SDO_GEOM.SDO_DISTANCE(C.GEOM, (
    SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 1, 'unit=km')) ODL
FROM COUNTRY_BOUNDARIES C
WHERE SDO_GEOM.RELATE(C.GEOM, 'DETERMINE', (
    SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 1) = 'DISJOINT';

-- Zad 3.

-- A.

SELECT C2.CNTRY_NAME,
       SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(C1.GEOM, C2.GEOM, 1), 1, 'unit=km') as granica
FROM COUNTRY_BOUNDARIES C1, COUNTRY_BOUNDARIES C2
WHERE C1.CNTRY_NAME = 'Poland' and SDO_GEOM.RELATE(C2.Geom, 'DETERMINE', C1.Geom, 1) = 'TOUCH';

-- B.

SELECT C.CNTRY_NAME, ROUND(SDO_GEOM.sdo_area(C.GEOM, 1, 'unit=SQ_KM')) powierzchnia
from COUNTRY_BOUNDARIES C order by 2 desc fetch first 1 row only;

-- C.

SELECT SDO_GEOM.SDO_AREA((SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(C1.GEOM, C2.GEOM))), 1, 'unit=SQ_KM') powierzchnia
FROM MAJOR_CITIES C1, MAJOR_CITIES C2 WHERE C1.CITY_NAME = 'Warsaw' and C2.CITY_NAME = 'Lodz';

-- D.
SELECT SDO_GEOM.SDO_UNION(B.GEOM, C.GEOM, 1).SDO_GTYPE AS GTYPE
FROM COUNTRY_BOUNDARIES B, MAJOR_CITIES C WHERE B.CNTRY_NAME = 'Poland' AND C.CITY_NAME = 'Prague';

-- E.

SELECT * FROM (SELECT C.city_name, B.CNTRY_Name, SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(B.GEOM,1), C.GEOM) dist
FROM COUNTRY_BOUNDARIES B JOIN MAJOR_CITIES C on (B.CNTRY_NAME = C.CNTRY_NAME))
ORDER BY DIST FETCH FIRST 1 ROW ONLY;

-- F.

SELECT B.CNTRY_NAME, R.name, sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(B.GEOM, R.GEOM, 1), 1, 'unit=km'))
FROM COUNTRY_BOUNDARIES B, RIVERS R
WHERE B.CNTRY_NAME = 'Poland' AND SDO_GEOM.RELATE(B.GEOM, 'DETERMINE', R.GEOM, 1) != 'DISJOINT'
GROUP BY B.CNTRY_NAME, R.name;