import pytset
import sqlite3
import db_index
import struct

def serialize_as_tset_array(tree_len,sets):
    """
    tree_len -> length of the tree to be serialized
    sets: array of tree_len sets, each set holding the indices of the elements
    """
    indices=[]
    for set_idx,s in enumerate(sets):
        for item in s:
            indices.append(struct.pack("@HH",set_idx,item))
    res=struct.pack("@H",tree_len)+("".join(indices))
    return res

def make_dummy_db(conn):
    conn.execute("DROP TABLE IF EXISTS sets;")
    conn.execute("CREATE TABLE sets (name STRING PRIMARY KEY, set_data BLOB);")
    conn.execute("DROP TABLE IF EXISTS setarrays;")
    conn.execute("CREATE TABLE setarrays (name STRING PRIMARY KEY, setarray_data BLOB);")


conn = sqlite3.connect('delme.db')
make_dummy_db(conn)
s=pytset.PyTSet(129,range(50,110))
s_ser=s.tobytes()
conn.execute(u"INSERT OR IGNORE INTO sets VALUES (?,?)",(u"s1",buffer(s_ser)))
s=pytset.PyTSet(129,range(51,110))
s_ser=s.tobytes()
conn.execute(u"INSERT OR IGNORE INTO sets VALUES (?,?)",(u"s2",buffer(s_ser)))
s=pytset.PyTSet(129,range(52,110))
s_ser=s.tobytes()
conn.execute(u"INSERT OR IGNORE INTO sets VALUES (?,?)",(u"s3",buffer(s_ser)))
conn.commit()

sets=[set() for _ in range(20)]
sets[0].add(5)
sets[0].add(15)
sets[1].add(17)
conn.execute(u"INSERT OR IGNORE INTO setarrays VALUES (?,?)",(u"sa1",buffer(serialize_as_tset_array(20,sets))))
conn.commit()
conn.close()


##And now try to get it back
#conn = sqlite3.connect('delme.db')
#cur=conn.cursor()
#cur.execute(u"SELECT set_data FROM sets WHERE name=?",(u"s",))
#for row in cur.fetchall():
#    print str(row[0])==s_ser, "<< should be True"
#conn.close()

db_index.open_db(u"delme.db")
q=u"select set_data from sets"
db_index.exec_query(q)
s=pytset.PyTSet(129,range(50,110))
while db_index.python_fill_next(s)!=1:
    for item in s:
        print item,
    print
db_index.close_db()




