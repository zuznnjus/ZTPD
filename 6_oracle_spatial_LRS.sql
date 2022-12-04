-- Zad 1
-- A
create table A6_LRS(
    geom sdo_geometry
);

-- B
insert into A6_LRS
    select SR.GEOM
    from STREETS_AND_RAILROADS SR, MAJOR_CITIES C
    where SDO_RELATE(SR.GEOM,
     SDO_GEOM.SDO_BUFFER(C.GEOM, 10, 1, 'unit=km'),
    'MASK=ANYINTERACT') = 'TRUE'
    and C.CITY_NAME = 'Koszalin';

-- C
select
 SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km') DISTANCE,
 ST_LINESTRING(GEOM) .ST_NUMPOINTS() ST_NUMPOINTS
from a6_lrs;

-- D
update a6_lrs
set geom =  SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.681);

-- E
INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('A6_LRS','GEOM',
MDSYS.SDO_DIM_ARRAY(
 MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
 MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
 MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1) ),
 8307);

-- F
CREATE INDEX lrs_idx ON a6_lrs(geom)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- Zad 2
-- A
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
from A6_LRS;

-- B
select SDO_LRS.GEOM_SEGMENT_END_PT(GEOM).Get_WKT() END_PT
from A6_LRS;

-- C
select SDO_LRS.LOCATE_PT(GEOM, 150, 0).Get_WKT() KM150 from A6_LRS;

-- D
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160).Get_WKT() CLIPED from A6_LRS;

-- E
select SDO_LRS.GET_NEXT_SHAPE_PT(A6.geom, C.geom).Get_WKT()
from A6_LRS A6, MAJOR_CITIES C where C.CITY_NAME = 'Slupsk';

-- F
select SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50,
 'unit=m arc_tolerance=0.05')
from A6_LRS A6, USER_SDO_GEOM_METADATA M
where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM';