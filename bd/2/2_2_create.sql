
create table themes (
    id serial primary key,
    name varchar not null unique 
);

create table countries (
    id serial primary key,
    name varchar not null unique 
);

create table scientists (
    id serial primary key,
    full_name varchar not null,
    country_id integer references countries(id),
    degree varchar,
    position varchar 
);

create table conference (
    id serial primary key,
    name varchar not null,
    country_id integer references countries(id),
    place varchar,
    start_date date 
);

create table participation (
    scientist_id integer references scientists(id),
    conference_id integer references conference(id),
    role varchar,
    reports_count integer constraint positive_count check  (reports_count >= 0)
);

create table specialization (
    scientist_id integer references scientists(id),
    theme_id integer references themes(id)
);

create table conference_topics (
    conference_id integer references conference(id),
    theme_id integer references themes(id)
);

insert into themes(name) values ('math');
insert into themes(name) values ('machine learning'),
                                ('literature'),
                                ('poetry'),
                                ('prose'),
                                ('chemistry'),
                                ('physics'),
                                ('cuantum theory'),
                                ('neural networks'),
                                ('translation theory')
;

insert into countries(name) values ('Russia'),
                                   ('USA'),
                                   ('Ukrain'),
                                   ('England'),
                                   ('Poland'),
                                   ('Kazakhstan'),
                                   ('China'),
                                   ('Canada'),
                                   ('Spain'),
                                   ('France')
;

-- change primary key in themes table
-- and foreign keys in specialization and conference_topics
alter table themes drop column id cascade;
drop table themes;
create table themes (
    name varchar primary key
);

alter table specialization rename column theme_id to theme;
alter table specialization alter column theme type varchar;
alter table specialization add foreign key (theme) references themes(name);

alter table conference_topics  rename column theme_id to theme;
alter table conference_topics  alter column theme type varchar;
alter table conference_topics  add foreign key (theme) references themes(name);


-- change countries primary key
-- and foreign keys in conference and scientists

alter table scientists drop constraint scientists_country_id_fkey;
alter table scientists rename column country_id to country;
alter table scientists alter column country type varchar;
alter table scientists add foreign key (country) references countries(name);

alter table conference drop constraint conference_country_id_fkey;
alter table conference rename column country_id to country;
alter table conference alter column country type varchar;
alter table conference add foreign key (country) references countries(name);

alter table countries drop constraint countries_pkey;
alter table countries add primary key (name);
alter table countries drop column id;


insert into scientists(full_name, country, degree, position)
               values ('PUPKIN VASILIY VYACHESLAVOVICH', null, null, null),
                      ('LOMOV IGOR SERGEEVICH', 'Russia', 'PhD', 'professor'),
                      ('A', 'England', null, null),
                      ('PIN HUN DUI', 'China', null, 'docent'),
                      ('SHLYAKHOV PAVEL IGOREVICH', 'Russia', null, 'junior research assistant'),
                      ('PUP GOROHOVIY', 'Poland', 'PhD', null),
                      ('JOHN BROWN JR', 'USA', null, null),
                      ('JOHN BROWN', 'USA', 'PhD', null),
                      ('VLASOV OLEG OLEGOVICH', 'Ukrain', null, 'junior research assistant'),
                      ('KATOD EVGENIY ANODOVICH', 'Russia', null, 'professor')
;

insert into conference (name, country, place, start_date) 
                values ('Nauka 0+', 'Russia', 'Moscow, VDNH', '29.09.2022'),
                       ('Global math conference', 'France', null, '12.12.2022'),
                       ('Nauka 0+', 'Russia', 'Moscow, Leninskiy prospect 27-11', '20.09.2023'),
                       ('Most Global conference', 'USA', null, '06.07.2021'),
                       ('Online conf', null, null, '12.12.2022'),
                       ('Offline conf', 'Kazakhstan', 'Almaty, Lenin st. 14', '08.06.2023'),
                       ('RATATA', 'Russia', 'KBR, Chekino vill., Bububu st. 77', '01.01.2022'),
                       ('Lit Conf.', 'Poland', null, '02.02.2002'),
                       ('Ooking bechture klop', 'Poland', 'Warsaw, Kutim st. 43', '1.1.2019'),
                       ('Conference', 'Russia', 'Moscow, Leninskiye gory st. 1', '20.04.2023')
;

insert into conference_topics (conference_id, theme)
                       values (1, 'math'),
                              (1, 'physics'),
                              (1, 'chemistry'),
                              (1, 'machine learning'),
                              (2, 'math'),
                              (3, 'math'),
                              (3, 'physics'),
                              (3, 'chemistry'),
                              (4, 'translation theory'),
                              (4, 'math'),
                              (4, 'quantum theory'),
                              (4, 'neural networks'),
                              (5, 'chemistry'),
                              (6, 'chemistry'),
                              (8, 'poetry'),
                              (8, 'prose'),
                              (8, 'literature'),
                              (9, 'physics'),
                              (9, 'quantum theory'),
                              (10, 'math')
;

insert into specialization (scientist_id, theme)
                    values (2, 'math'),
                           (2, 'literature'),
                           (2, 'physics'),
                           (3, 'translation theory'),
                           (4, 'prose'),
                           (4, 'poetry'),
                           (4, 'literature'),
                           (4, 'chemistry'),
                           (5, 'math'),
                           (5, 'literature'),
                           (5, 'machine learning'),
                           (6, 'quantum theory'),
                           (6, 'physics'),
                           (7, 'physics'),
                           (7, 'chemistry'),
                           (8, 'chemistry'),
                           (9, 'machine learning'),
                           (9, 'neural networks'),
                           (10, 'math'),
                           (10, 'physics')
;

insert into participation (scientist_id, conference_id, role, reports_count)
                   values (1, 1, 'listener', 0),
                          (2, 1, 'lecturer', 2),
                          (2, 3, 'lecturer', 3),
                          (2, 2, 'lecturer', 1),
                          (2, 8, 'listener', 0),
                          (4, 4, 'lecturer', 1),
                          (4, 5, 'lecturer', 1),
                          (5, 9, 'lecturer', 1),
                          (5, 3, 'organizer', 0),
                          (6, 1, 'lecturer', 1),
                          (8, 1, 'lecturer', 2),
                          (8, 3, 'lecturer', 1),
                          (8, 7, 'lecturer', 1),
                          (9, 1, 'lecturer', 1),
                          (9, 3, 'lecturer', 1),
                          (9, 6, 'lecturer', 1),
                          (9, 9, 'listener', 1),
                          (10, 1, 'lecturer', 2),
                          (10, 3, 'lecturer', 2),
                          (10, 4, 'lecturer', 1)
;






















































































create type themes_type as enum ('math', 'physics', 'ml');
alter type themes_type add value if not exists 'history';

create table scientists (
    id serial primary key,
    name varchar,
    country varchar,
    degree varchar,
    position varchar 
);

create table conference (
    id serial primary key,
    name varchar not null,
    country varchar,
    place varchar,
    date date 
);

create table participation (
    scientist_id integer references scientists(id),
    conference_id integer references conference(id),
    role varchar,
    reports_count integer constraint positive_count check  (reports_count >= 0)
);

create table specialization (
    scientist_id integer references scientists(id),
    theme themes_type
);

create table conference_topics (
    conference_id integer references conference(id),
    theme themes_type
);



























































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



create type themes_type as enum ('math', 'physics', 'ml');
alter type themes_type add value if not exists 'history';

alter table conference_topics drop column theme;
alter table conference_topics add column theme themes_type not null;


alter table specialization  drop column theme;
alter table specialization  add column theme themes_type not null;

drop table themes;

