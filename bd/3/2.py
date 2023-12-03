import psycopg as pg

with pg.connect("dbname=lab_3 user=postgres password=postgres") as conn:
    with conn.cursor() as cur:
        with open("./3/20000_person_ids", "w") as f:
            s = cur.execute("select id from persons").fetchall()
            f.write("\n".join(map(lambda e: str(e[0]), s)))
        
        with open("./3/20000_events_ids", "w") as f:
            s = cur.execute("select id from events").fetchall()
            f.write("\n".join(map(lambda e: str(e[0]), s)))
        