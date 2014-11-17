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

    def exec_query(self, unicode query, object args):
        """Runs sqlite3_prepare, use .next() to iterate through the rows. Args is a list of *UNICODE* arguments to bind to the query"""
        cdef unicode a
        cdef int idx
        query_u8=query.encode("utf-8")
        cdef char* txt=query_u8
        result=sqlite3_prepare_v2(self.db,query_u8,len(query_u8),&self.stmt,NULL)
        if result!=SQLITE_OK:
            print sqlite3_errmsg(self.db)
            return False, result
        for idx,a in enumerate(args):
            a_u8=a.encode("utf-8")
            result=sqlite3_bind_text(self.stmt,idx+1,a_u8,len(a_u8),<void(*)(void*)>-1) #the last param is from SQLite headers
            if result!=SQLITE_OK:
                print sqlite3_errmsg(self.db)
                return False, result
        return True, 0

    cpdef int next(self):
        cdef int result = sqlite3_step(self.stmt)
        if result==SQLITE_ROW:
            return 0
        elif result==SQLITE_DONE:
            return 1
        else:
            print sqlite3_errmsg(self.db)            
            return result

    cdef void fill_tset(self,TSet *out, int column_index):
        cdef const void *data
        data=sqlite3_column_blob(self.stmt, column_index)
        out.add_serialized_data(data)

    cdef void fill_tsetarray(self, TSetArray *out, int column_index):
        cdef int blob_len
        cdef const void *data
        data=sqlite3_column_blob(self.stmt,column_index)
        blob_len=sqlite3_column_bytes(self.stmt, column_index);
        out.deserialize(data,blob_len)

    def fill_pytset(self, PyTSet s, int column_index):
        self.fill_tset(s.thisptr, column_index)

    def fill_pytsetarray(self, PyTSetArray s, int column_index):
        self.fill_tsetarray(s.thisptr, column_index)

    cdef int get_integer(self, int column_index):
        return sqlite3_column_int(self.stmt, column_index)

    cdef void fill_sets(self, void **set_pointers, int *types, int size):
        cdef int i
        cdef int col_index
        for i in range(size):
            col_index=i+2
            if types[i]==1: # TODO fix constant
                self.fill_tset(<TSet *>set_pointers[i],col_index)
            elif types[i]==2:
                self.fill_tsetarray(<TSetArray *>set_pointers[i],col_index)
            else:
                print "C",types[i]
                assert False
            

