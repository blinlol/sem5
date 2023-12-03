create table themes (
    id serial primary key,
    name text not null unique
);

create table roles (
    id serial primary key,
    name text not null unique    
);

create table persons (
    id serial primary key,
    personal_data jsonb default '{}'::jsonb,
    my_events integer array default array[]::integer[], 
    date_added timestamp default current_timestamp   
);

create table person_themes (
    person_id integer references persons(id),
    theme_id integer references themes(id),
    constraint person_themes_unique_row unique (person_id, theme_id)
);


create table events (
    id serial primary key,
    name text not null,
    start_date timestamp,
    end_date timestamp,
    date_added timestamp default current_timestamp
);

create table event_themes (
    event_id integer references events(id),
    theme_id integer references themes(id),
    constraint event_themes_unique_row unique (event_id, theme_id)
);

create table event_description (
    event_id integer references events(id),
    description text default ''
);

create table event_participants (
    event_id integer unique references events(id),
    participants_id integer[] default array[]::integer[]
);


create table participation (
    person_id integer references persons(id),
    event_id integer references events(id),
    roles integer[] default array[]::integer[],
    registration_date timestamp default current_timestamp,
    mark integer,
    constraint participation_unique unique (person_id, event_id)
);

