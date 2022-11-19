-- Zestaw 1
create table figury(
    id number(1) primary key,
    ksztalt MDSYS.SDO_GEOMETRY
);

insert into figury values(
1,
MDSYS.SDO_GEOMETRY(
2003,
NULL,
NULL,
MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
MDSYS.SDO_ORDINATE_ARRAY(3,5, 5,7, 7,5)
) );

insert into figury values(
2,
MDSYS.SDO_GEOMETRY(
2003,
NULL,
NULL,
MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5) ) );

insert into figury values(
3,
MDSYS.SDO_GEOMETRY(
2002,
NULL,
NULL,
MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1) ) );


insert into figury values(
4,
MDSYS.SDO_GEOMETRY(
2002,
NULL,
NULL,
MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 7,1) ) );

SELECT id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005)
   FROM figury;
  
delete from figury where id = 4;

-- Zestaw 2
-- Cw 1
INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
  'figury',
  'ksztalt',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('X', 0, 20, 0.01),
    SDO_DIM_ELEMENT('Y', 0, 20, 0.01)
     ),
  NULL
);

select SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) from dual;

create index figury_idx
on figury(ksztalt)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

select ID
from FIGURY
where SDO_FILTER(KSZTALT,
SDO_GEOMETRY(2001,null,
 SDO_POINT_TYPE(3,3,null),
 null,null)) = 'TRUE';

select ID
from FIGURY
where SDO_RELATE(KSZTALT,
 SDO_GEOMETRY(2001,null,
 SDO_POINT_TYPE(3,3,null),
 null,null),
 'mask=ANYINTERACT') = 'TRUE';


-- Cw 2
-- Zad A
select A.CITY_NAME, SDO_NN_DISTANCE(1) DISTANCE
from MAJOR_CITIES A
where SDO_NN(GEOM,
(
    select m.geom
    from major_cities m
    where city_name = 'Warsaw'
),
'sdo_num_res=10 unit=km',1) = 'TRUE' and city_name != 'Warsaw';
 
-- Zad B
select C.CITY_NAME
from MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.GEOM,
 (
    select m.geom
    from major_cities m
    where city_name = 'Warsaw'
),
'distance=100 unit=km') = 'TRUE' and city_name != 'Warsaw';

-- Zad C
select B.CNTRY_NAME, C.CITY_NAME
from COUNTRY_BOUNDARIES B, MAJOR_CITIES C
where SDO_RELATE(C.GEOM, B.GEOM,
 'mask=INSIDE') = 'TRUE' and B.CNTRY_NAME='Slovakia';
 
-- Zad D
select A.CNTRY_NAME, SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km')
from COUNTRY_BOUNDARIES A, COUNTRY_BOUNDARIES B
where SDO_RELATE(A.GEOM, B.GEOM,
 'mask=TOUCH') != 'TRUE' and A.CNTRY_NAME = 'Poland'
 and B.CNTRY_NAME != 'Poland';

-- Cw 3
-- Zad A
select A.CNTRY_NAME,
 B.CNTRY_NAME,
 ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km'))
from COUNTRY_BOUNDARIES A,
 COUNTRY_BOUNDARIES B
where SDO_RELATE(A.GEOM, B.GEOM,
 'mask=TOUCH') = 'TRUE' and A.CNTRY_NAME = 'Poland';

-- Zad B
select * from (
    select A.CNTRY_NAME,
     ROUND(SDO_GEOM.sdo_area(A.GEOM, 1, 'unit=SQ_KM'))
    from COUNTRY_BOUNDARIES A order by 2 desc
) t
where rownum=1;

-- Zad C
select (SDO_GEOM.sdo_area(SDO_AGGR_MBR(A.GEOM), 1, 'unit=SQ_KM'))
from MAJOR_CITIES A
where A.CITY_NAME in ('Warsaw', 'Lodz');

-- Zad D
select SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1).GET_GTYPE()
from COUNTRY_BOUNDARIES A, MAJOR_CITIES B
where A.CNTRY_NAME = 'Poland'
and B.CITY_NAME = 'Prague';

-- Zad E
select * from(
select a.city_name, cntry_name,
SDO_GEOM.SDO_DISTANCE(A.GEOM, SDO_GEOM.SDO_CENTROID(B.GEOM,1),1, 'unit=km')
from MAJOR_CITIES A join COUNTRY_BOUNDARIES B
using(cntry_name) order by 3
) t
where rownum=1;

-- Zad F
select B.NAME, ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km'))
from COUNTRY_BOUNDARIES A,
 RIVERS B
where SDO_RELATE(A.GEOM, B.GEOM,
 'mask=OVERLAPBDYINTERSECT') = 'TRUE' and A.CNTRY_NAME = 'Poland';