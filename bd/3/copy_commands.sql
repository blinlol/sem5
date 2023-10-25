\copy countries(name) from '/home/fedor/sem5/bd/3/fakes/countries';
\copy themes(name) from '/home/fedor/sem5/bd/3/fakes/themes'
\copy roles(name) from '/home/fedor/sem5/bd/3/fakes/roles'
\copy persons(personal_data, date_added) from '/home/fedor/sem5/bd/3/fakes/persons' delimiter '|'
\copy events(name, start_date, end_date, date_added) from '/home/fedor/sem5/bd/3/fakes/events' delimiter '|'
