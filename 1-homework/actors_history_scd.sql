create table actors_history_scd (
	actor text,
	actorid TEXT,
	is_active BOOLEAN,
	start_date INTEGER,
	end_date INTEGER,
	"current_date" INTEGER,
  quality_class quality_class,
	primary KEY(actorid,start_date)
);
