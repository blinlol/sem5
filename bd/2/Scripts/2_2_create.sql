CREATE TABLE public.themes (
	theme varchar primary key 
);

create table scientists (
    name varchar primary key,
    country varchar,
    degree varchar,
    position varchar 
);

create table conference (
    name varchar primary key,
    country varchar,
    place varchar,
    date date 
);

create table participation (
    scientist varchar references scientists(name),
    conference varchar references conference(name),
    role varchar,
    reports_count integer constraint positive_count check  (reports_count >= 0)
);

create table specialization (
    scientist varchar references scientists(name),
    theme varchar references themes(theme)
);

create table conference_topics (
    conference varchar references conference(name),
    theme varchar references themes(theme)
);