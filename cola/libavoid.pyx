cdef extern from "libavoid/geomtypes.h" namespace "Avoid":
    cdef cppclass Point:
        Point(int, int)
        int id
        double x, y
        
#cdef class Point
# vim: sw=4:et:ai
