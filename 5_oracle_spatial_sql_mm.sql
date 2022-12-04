-- Zad 1
-- A
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
 and prior t.owner = t.owner;
 
-- B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

-- C
create table myst_major_cities(
    fips_cntry VARCHAR2(2),
    city_name VARCHAR2(40),
    stgeom ST_POINT
);

-- D
insert into myst_major_cities
select 
    fips_cntry, 
    city_name, 
    TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_POINT) stgeom
from major_cities;

-- Zad 2
-- A
insert into myst_major_cities values(
    'PL',
    'Szczyrk',
    TREAT(ST_POINT.FROM_WKT('POINT(19.036107 49.718655)') AS ST_POINT)
);

-- B
select name, r.geom.get_wkt()
from rivers r;

-- C
select SDO_UTIL.TO_GMLGEOMETRY(c.stgeom.GET_SDO_GEOM())
from myst_major_cities c
where city_name = 'Szczyrk';

-- Zad 3
-- A
create table myst_country_boundaries(
    fips_cntry VARCHAR2(2),
    cntry_name VARCHAR2(40),
    stgeom ST_MULTIPOLYGON
);

-- B
insert into myst_country_boundaries
select 
    fips_cntry,
    cntry_name,
    ST_MULTIPOLYGON(GEOM) 
from country_boundaries;

-- C
select b.stgeom.ST_GEOMETRYTYPE(), count(*)
from myst_country_boundaries b
group by b.stgeom.ST_GEOMETRYTYPE();

-- D
select b.stgeom.ST_ISSIMPLE()
from myst_country_boundaries b;

-- Zad 4
-- A
select b.cntry_name, count(*)
from myst_country_boundaries b, myst_major_cities c
where b.stgeom.ST_Contains(c.stgeom) = 1 and city_name != 'Szczyrk'
group by cntry_name;

-- B
select a.cntry_name a_name, b.cntry_name b_name
from myst_country_boundaries a, myst_country_boundaries b
where a.stgeom.st_touches(b.stgeom) = 1 and b.cntry_name = 'Czech Republic';

-- C
select distinct b.cntry_name, r.name
from myst_country_boundaries b, rivers r
where b.cntry_name = 'Czech Republic'
and ST_LINESTRING(r.GEOM).ST_INTERSECTS(b.STGEOM) = 1;
  
-- D
select a.stgeom.st_union(b.stgeom) powierzchnia
from myst_country_boundaries a, myst_country_boundaries b
where a.cntry_name = 'Slovakia' and b.cntry_name = 'Czech Republic';

-- E
select TREAT(b.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(w.GEOM)) as ST_POLYGON).ST_AREA() obiekt,
 b.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(w.GEOM)).ST_GEOMETRYTYPE() wegry_bez
from myst_country_boundaries b, water_bodies w
where b.cntry_name = 'Hungary'
and w.name = 'Balaton';
    
-- Zad 5
-- A
select count(*)
from myst_country_boundaries b, myst_major_cities c
where SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
and b.cntry_name = 'Poland'
group by b.cntry_name;

explain plan for
select count(*) from myst_country_boundaries b, myst_major_cities c
where SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
and b.cntry_name = 'Poland'
group by b.cntry_name;

-- B
insert into user_sdo_geom_metadata
select 'MYST_MAJOR_CITIES', 'STGEOM',
T.DIMINFO, T.SRID
from user_sdo_geom_metadata T
where T.TABLE_NAME = 'MAJOR_CITIES';
 
-- C
create index MYST_MAJOR_CITIES_IDX on
 MYST_MAJOR_CITIES(STGEOM)
indextype IS MDSYS.SPATIAL_INDEX;

-- D
select count(*)
from myst_country_boundaries b, myst_major_cities c
where SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
and b.cntry_name = 'Poland'
group by b.cntry_name;

explain plan for
select count(*) from myst_country_boundaries b, myst_major_cities c
where SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
and b.cntry_name = 'Poland'
group by b.cntry_name;