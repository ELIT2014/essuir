CREATE TABLE authors			
(			
  surname_en character varying(32) NOT NULL,			
  initials_en character varying(64) NOT NULL,			
  surname_ru character varying(32),			
  initials_ru character varying(64),			
  surname_uk character varying(32),			
  initials_uk character varying(64),			
  CONSTRAINT authors_pkey PRIMARY KEY (surname_en , initials_en )			
);

CREATE TABLE eperson_service
(
  eperson_id integer NOT NULL,
  collection_id integer NOT NULL,
  CONSTRAINT eperson_service_pkey PRIMARY KEY (eperson_id ),
  CONSTRAINT eperson_service_collection_id_fkey FOREIGN KEY (collection_id)
      REFERENCES collection (collection_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT eperson_service_eperson_id_fkey FOREIGN KEY (eperson_id)
      REFERENCES eperson (eperson_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE faculty
(
  faculty_id integer NOT NULL,
  faculty_name character varying(128) NOT NULL,
  CONSTRAINT faculty_pkey PRIMARY KEY (faculty_id )
);

CREATE TABLE chair
(
  chair_id integer NOT NULL,
  chair_name character varying(256) NOT NULL,
  faculty_id integer,
  CONSTRAINT chair_pkey PRIMARY KEY (chair_id ),
  CONSTRAINT chair_faculty_id_fkey FOREIGN KEY (faculty_id)
      REFERENCES faculty (faculty_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL
);

ALTER TABLE eperson ADD COLUMN chair_id integer;
ALTER TABLE eperson ADD COLUMN position character varying(128);

ALTER TABLE authors OWNER TO dspace;
ALTER TABLE eperson_service OWNER TO dspace;
ALTER TABLE faculty OWNER TO dspace;
ALTER TABLE chair OWNER TO dspace;