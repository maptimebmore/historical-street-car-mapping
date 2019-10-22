-- add postgis extension
create extension postgis;
-- ###############################

--remove extra projections to save space
delete from spatial_ref_sys
	where
		srid != 2248 and
		srid != 4326 and
		srid != 3857;
-- ###############################

-- create our main table
CREATE TABLE streetcars (
	ID serial primary key,
	detail text,
	geom geometry(LINESTRING,2248),
  editor varchar(25)
);
-- ###############################

-- http://postgis.net/workshops/postgis-intro/history_tracking.html
-- create triggers for logging
CREATE TABLE streetcars_history (
  hid SERIAL PRIMARY KEY,
  id INTEGER,
  detail text,
  geom GEOMETRY(LINESTRING,2248),
  editor varchar(25),
  created TIMESTAMP,
  created_by VARCHAR(32),
  deleted TIMESTAMP,
  deleted_by VARCHAR(32)
);
-- ###############################

-- populate with current data
INSERT INTO streetcars_history
  (id, detail, geom, editor, created, created_by)
   SELECT id, detail, geom, editor, now(), current_user
   FROM streetcars;
-- ###############################


-- trigger on create
CREATE OR REPLACE FUNCTION streetcars_insert() RETURNS trigger AS
$$
  BEGIN
    INSERT INTO streetcars_history
      (id, detail, geom, editor, created, created_by)
    VALUES
      (NEW.id, NEW.detail, NEW.geom, NEW.editor
       current_timestamp, current_user);
    RETURN NEW;
  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER streetcars_insert_trigger
AFTER INSERT ON streetcars
  FOR EACH ROW EXECUTE PROCEDURE streetcars_insert();
-- ###############################

-- trigger on delete
CREATE OR REPLACE FUNCTION streetcars_delete() RETURNS trigger AS
$$
  BEGIN
    UPDATE streetcars_history
      SET deleted = current_timestamp, deleted_by = current_user
      WHERE deleted IS NULL and id = OLD.id;
    RETURN NULL;
  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER streetcars_delete_trigger
AFTER DELETE ON streetcars
  FOR EACH ROW EXECUTE PROCEDURE streetcars_delete();
-- ###############################


-- trigger on update
CREATE OR REPLACE FUNCTION streetcars_update() RETURNS trigger AS
$$
  BEGIN

    UPDATE streetcars_history
      SET deleted = current_timestamp, deleted_by = current_user
      WHERE deleted IS NULL and id = OLD.id;

    INSERT INTO streetcars_history
      (id, detail, geom, editor, created, created_by)
    VALUES
      (NEW.id, NEW.detail, NEW.geom, NEW.editor,
       current_timestamp, current_user);
    RETURN NEW;

  END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER streetcars_update_trigger
AFTER UPDATE ON streetcars
  FOR EACH ROW EXECUTE PROCEDURE streetcars_update();
-- ###############################

-- Let's also make a table for storing the atlas index polygons and numbers to help with tracking progress
CREATE TABLE public.atlas_index (
  id serial primary key,
  atlas_sheet varchar(2),
  progress varchar(25),
  geom geometry(POLYGON, 2248)
);
-- ###############################