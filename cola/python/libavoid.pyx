
from cython.operator cimport dereference as deref
from _libavoid cimport Point as cPoint
from _libavoid cimport ConnEnd as cConnEnd
from _libavoid cimport ConnRef as cConnRef


cdef class Point(object):
    cdef cPoint *thisptr
    cdef bint owner
    def __cinit__(self, double x, double y):
        self.thisptr = new cPoint(x, y)
        self.owner = True

    def __dealloc__(self):
        if self.owner:
            del self.thisptr

# <	0
# ==	2
# > 	4
# <=	1
# !=	3
# >=	5

#    def __richcmp__(self, Point other, int op):
#        p1 = self.thisptr
#        p2 = other.thisptr
#        if op == 0: # <
#            pass
#        elif op == 1: # <=
#            pass
#        elif op == 2: # ==
#            pass #return p1 == p2
#        elif op == 3: # !=
#            pass
#        elif op == 4: # >
#            pass
#        elif op == 5: # >=
#            pass

#    def __add__(self, Point other):
#        #cdef cPoint cp = deref(self.thisptr) + deref(other.thisptr)
#        #return Point(cp.x, cp.y)
#        cdef cPoint p1 = deref(self.thisptr)
#        cdef cPoint p2 = deref(other.thisptr)
#        cdef cPoint cp = p1 + p2
#        return Point(cp.x, cp.y)

    property x:
        def __get__(self): return self.thisptr.x
        def __set__(self, x): self.thisptr.x = x
    
    property y:
        def __get__(self): return self.thisptr.y
        def __set__(self, y): self.thisptr.y = y
    
    property id:
        def __get__(self): return self.thisptr.id
        def __set__(self, id): self.thisptr.id = id
    

#cdef cPoint *p1 = new cPoint(2,4)
#cdef cPoint *p2 = new cPoint(1,3)
#
#cdef cPoint p3 = deref(p1) + deref(p2)
#
#print p1.x, p1.y
#print p2.x, p2.y
#print p3.x, p3.y


# The following classes lose ownership once passed to a Router:
#        Avoid::ShapeRef,
#        Avoid::ConnRef,
#        Avoid::ClusterRef,
#        Avoid::JunctionRef,
# In the next case ownership is passed to the parent shapeRef/junctionRef
#        Avoid::ShapeConnectionPin

# vim: sw=4:et:ai
