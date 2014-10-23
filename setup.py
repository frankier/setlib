from distutils.core import setup
from Cython.Build import cythonize

setup(ext_modules = cythonize(
           "pytset.pyx",                 # our Cython source
           sources=["tset.cpp","query_functions.cpp"],  # additional source file(s)
           language="c++",             # generate C++ code
      ))

setup(ext_modules = cythonize(
           "test2.pyx",                 # our Cython source
           sources=["tset.cpp","query_functions.cpp"],  # additional source file(s)
           language="c++",             # generate C++ code
      ))

setup(ext_modules = cythonize(
           "db_util.pyx",                 # our Cython source
           language="c++",             # generate C++ code
           sources=["tset.cpp"],
           libraries=["sqlite3"],
      ))


