# distutils: language = c++
# distutils: libraries = sqlite3
# distutils: sources = tset.cpp
from libcpp cimport bool
#http://www.sqlite.org/cintro.html
from pytset cimport PyTSet, PyTSetArray 

cdef class DB:

    def open_db(self,unicode db_name):
        db_name_u8=db_name.encode("utf-8") #Need to make a variable for this one, because .encode() produces only a temporary object
        sqlite3_open_v2(db_name_u8,&self.db,SQLITE_OPEN_READONLY,NULL)

    def close_db(self):
        sqlite3_close(self.db)

    def exec_query(self,unicode query):
        query_u8=query.encode("utf-8")
        result=sqlite3_prepare_v2(self.db,query_u8,len(query_u8),&self.stmt,NULL)
        if result!=SQLITE_OK:
            return False
        else:
            return True

    cdef int fill_next_tset(self,TSet *out):
        cdef int result = sqlite3_step(self.stmt)
        cdef const void *data
        if result==SQLITE_ROW:
            data=sqlite3_column_blob(self.stmt,0)
            out.add_serialized_data(data)
            return 0
        elif result==SQLITE_DONE:
            return 1
        else: 
            return result #TODO: UGLY

    cdef int fill_next_tsetarray(self, TSetArray *out):
        cdef int blob_len
        cdef int result = sqlite3_step(self.stmt)
        cdef const void *data
        if result==SQLITE_ROW:
            data=sqlite3_column_blob(self.stmt,0)
            blob_len=sqlite3_column_bytes(self.stmt, 0);
            out.deserialize(data,blob_len)
            return 0
        elif result==SQLITE_DONE:
            return 1
        else: 
            return result #TODO: UGLY

    def fill_next_pytset(self, PyTSet s):
        return self.fill_next_tset(s.thisptr)

    def fill_next_pytsetarray(self, PyTSetArray s):
        return self.fill_next_tsetarray(s.thisptr)
