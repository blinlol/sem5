create table countries (
    id serial primary key,
    name text not null unique
);

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
    personal_data jsonb default {}::jsonb,
    my_events integer array default array[]::integer[], 
    date_added timestamp default current_timestamp   
);

create table person_interests (
    person_id integer references person(id),
    interests integer[] default array[]::integer[]
);


create table events (
    id serial primary key,
    name text not null,
    start_date date,
    end_date date,
    date_added timestamp default current_timestamp
);

create table event_themes (
    event_id integer references events(id),
    event_themes integer[] default array[]::integer[]
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
    registration_date timestamp default current_timestamp
    
);


