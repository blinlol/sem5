import faker
import datetime
import psycopg

from random import gauss
from typing import List, Tuple
from collections import OrderedDict



events_number = 1#10 ** 3
persons_number = 1#10 ** 3

db_conn_env = "dbname=lab_3 user=postgres password=postgres"

fkr = faker.Faker()

# def gen_countries(n):
#     with open("./3/fakes/countries", mode="w") as f:
#         for _ in range(n):
#             f.write(f"{fkr.unique.country()}\n")
#     fkr.unique.clear()


def gen_persons(n):
    with open("./3/fakes/persons", mode="w") as f:
        for _ in range(n):
            data_columns = [('first_name', 'first_name'),
                            ('last_name', 'last_name'),
                            ('email', 'email'),
                            ('phone_number', 'phone_number')]
            date_added = fkr.date_time_between(start_date='-2y', end_date='now')
            f.write(f"{fkr.json(data_columns=data_columns, num_rows=1)}|{date_added}\n")


def gen_events(n):
    with open("./3/fakes/events", mode="w") as f:
        hours_8_to_22 = list(range(8, 23))
        days_7_to_90 = list(range(7, 91))

        for _ in range(n):
            name = fkr.sentence(nb_words=3).rstrip('.')

            sd = fkr.date_between(start_date='-2y', end_date='+1m')
            st = datetime.time(hour=fkr.random_element(hours_8_to_22),
                               minute=fkr.random_element([0, 15, 30, 45]),
                               second=0)
            duration = datetime.timedelta(days=fkr.random_element([0, 1, 2, 3, 4, 5, 6, 7]), 
                                          hours=fkr.random_element([0, 6, 8, 12]))
            start_date = datetime.datetime.combine(sd, st)
            end_date = start_date + duration
            
            date_added = start_date - datetime.timedelta(days=fkr.random_element(days_7_to_90))

            f.write(f"{name}|{start_date}|{end_date}|{date_added}\n")


def gen_descriptions():
    with open('./3/fakes/descriptions', mode='w') as f:
        for id in get_ids('events'):
            f.write(str(id) + '|' + fkr.text(max_nb_chars=168).replace('\n', '') + '\n')


def gen_event_themes():
    with open('./3/fakes/event_themes', mode='w') as f:
        all_themes = get_ids('themes')
        for id in get_ids('events'):
            for theme in fkr.random_elements(elements=all_themes, 
                                             length=fkr.random_int(1, 8),
                                             unique=True):
                f.write(f"{id}|{theme}\n")


def gen_person_themes():
    with open('./3/fakes/person_themes', mode='w') as f:
        all_themes = get_ids('themes')
        for id in get_ids('persons'):
            for theme in fkr.random_elements(elements=all_themes, 
                                             length=fkr.random_int(1, 16),
                                             unique=True):
                f.write(f"{id}|{theme}\n")


def check_themes_uniquines():
    with open('./3/fakes/themes', mode='r') as f:
        themes = set()
        for line in f:
            themes.add(line.strip())
    
    with open('./3/fakes/themes', 'w') as f:
        for theme in themes:
            f.write(f"{theme}\n")


def get_ids(table_name: str) -> List[int]:
    with psycopg.connect(db_conn_env) as conn:
        with conn.cursor() as cur:
            cur.execute(f"select id from {table_name}")
            return [e[0] for e in cur]


def gen_participation(min_max_participants: Tuple[int, int] =(10, 400)):
    with psycopg.connect(db_conn_env) as conn:
        with conn.cursor() as cur:
            persons = cur.execute(f"select id, date_added from persons order by date_added asc").fetchall()
            events = cur.execute(f"select id, start_date, date_added from events order by start_date asc").fetchall()
    
    f = open('./3/fakes/participation', mode='w')
    p_indx_last_added = 0
    for e_id, e_start, e_added in events:
        while e_start >= persons[p_indx_last_added][1]:
            p_indx_last_added += 1
        
        participants = fkr.random_elements(
                            elements=persons[:p_indx_last_added],
                            length=min(fkr.random_int(min_max_participants[0], min_max_participants[1]), p_indx_last_added),
                            unique=True)
        for p_id, p_added in participants:
            role = fkr.random_element(elements=OrderedDict([('1', 0.1), ('2', 0.9)]))
            reg_date = fkr.date_time_between(start_date=max(e_added, p_added),
                                             end_date=e_start)
            mark = fkr.random_int(1, 10)
            f.write(f"{p_id}|{e_id}|{{{role}}}|{reg_date}|{mark}\n")

    f.close()


def truncate_persons_events():
    with psycopg.connect(db_conn_env) as conn:
        with conn.cursor() as cur:
            cur.execute("truncate table events, persons cascade")


# gen_persons(persons_number)
# gen_events(events_number)

"""
first copy data to db with command
\copy persons(personal_data, date_added) from /home/fedor/sem5/bd/3/fakes/persons delimiter '|'
\copy events(name, start_date, end_date, date_added) from /home/fedor/sem5/bd/3/fakes/events delimiter '|'
"""


# gen_person_themes()
# gen_descriptions()
# gen_event_themes()

# gen_participation((10, 800))

"""
commands to copy remaining data
\copy person_themes(person_id, theme_id) from /home/fedor/sem5/bd/3/fakes/person_themes delimiter '|'
\copy event_description(event_id, description) from /home/fedor/sem5/bd/3/fakes/descriptions delimiter '|'
\copy event_themes(event_id, theme_id) from /home/fedor/sem5/bd/3/fakes/event_themes delimiter '|'
\copy participation(person_id, event_id, roles, registration_date, mark) from /home/fedor/sem5/bd/3/fakes/participation delimiter '|'

"""
