
from cython.operator cimport dereference as deref
cimport avoid

from cpython.weakref cimport PyWeakref_NewRef, PyWeakref_GetObject, PyWeakref_CheckRef
from cpython.ref cimport Py_INCREF


cdef unsigned int iid(object o):
    return id(o) & 0xFFFFFFFF

# The following classes lose ownership once passed to a Router:
#        Avoid::ShapeRef,
#        Avoid::ConnRef,
#        Avoid::ClusterRef,
#        Avoid::JunctionRef,
# In the next case ownership is passed to the parent shapeRef/junctionRef
#        Avoid::ShapeConnectionPin

cdef class Polygon:
    cdef avoid.Polygon *thisptr
    cdef bint owner
    def __cinit__(self, *points):
        """
        Create a new polygon based on a set of points.

        >>> p = Polygon((0,0), (3, 0), (1.5, 2))
        >>> p
        <...>
        """
        self.thisptr = new avoid.Polygon(len(points))
        for index, point in enumerate(points):
            self.thisptr.ps[index] = avoid.Point(point[0], point[1])
        self.owner = True

    def __dealloc__(self):
        if self.owner:
            del self.thisptr

    def __len__(self):
        return self.thisptr.ps.size()

    def __getitem__(self, index):
        return(self.thisptr.ps[index].x, self.thisptr.ps[index].y)

    def __setitem__(self, index, point):
        assert index < self.thisptr.ps.size()
        self.thisptr.ps[index] = avoid.Point(point[0], point[1])


cdef class Rectangle(Polygon):
    def __cinit__(self, object topLeft, object bottomRight):
        self.thisptr = new avoid.Rectangle(avoid.Point(topLeft[0], topLeft[1]),
                                      avoid.Point(bottomRight[0], bottomRight[1]))
        self.owner = True


cdef class Router


cdef class Obstacle:
    cdef avoid.Obstacle *thisptr
    cdef bint owner
    cdef object _router_ref

    property position:
        def __get__(self):
            cdef avoid.Point p = self.thisptr.position()
            return (p.x,p.y)

    property polygon:
        def __get__(self):
            cdef avoid.Polygon polygon = self.thisptr.polygon()
            cdef unsigned int index
            cdef object lst = []
            for index from 0 <= index < polygon.ps.size():
                lst.append((polygon.ps[index].x,
                            polygon.ps[index].y))
            return lst

    property boundingBox:
        def __get__(self):
            cdef avoid.BBox bbox
            self.thisptr.boundingBox(bbox)
            return ((bbox.a.x, bbox.a.y), (bbox.b.x, bbox.b.y))

    property router:
        def __get__(self):
            return <object>PyWeakref_GetObject(self._router_ref)


cdef class ShapeRef(Obstacle):
    def __cinit__(object self, Router router, Polygon polygon):
        self.thisptr = new avoid.ShapeRef(router.thisptr, deref(polygon.thisptr), iid(self))
        self.owner = True
        self._router_ref = PyWeakref_NewRef(router, None)

    def __dealloc__(self):
        if self.owner:
            del self.thisptr


cdef class JunctionRef(Obstacle):
    """
    A Junction denotes a point where one or more connection ends (ConnEnd)
    come together.
    """

    def __cinit__(object self, Router router, object position):
        self.thisptr = new avoid.JunctionRef(router.thisptr, avoid.Point(position[0], position[1]), iid(self))
        self.owner = True
        self._router_ref = PyWeakref_NewRef(router, None)


cdef class ConnEnd:
    cdef avoid.ConnEnd *thisptr
    cdef bint owner

    def __cinit__(self, object point=None, object shape=None, object junction=None):
        if point:
            self.thisptr = new avoid.ConnEnd(avoid.Point(point[0], point[1]))
        #elif shape:
        #    self.thisptr = new avoid.ConnEnd(shape.thisptr)
        self.owner = True

    def __dealloc__(self):
        if self.owner:
            del self.thisptr

    property position:
        def __get__(self):
            cdef avoid.Point p = self.thisptr.position()
            return (p.x, p.y)


cdef class Router:
    POLY_LINE = avoid.PolyLineRouting
    ORTHOGONAL = avoid.OrthogonalRouting

    cdef avoid.Router *thisptr

    def __cinit__(self, router_flag=avoid.PolyLineRouting):
        self.thisptr = new avoid.Router(router_flag)
        #_routers[id(self.thisptr)] = self

    def __dealloc__(self):
        del self.thisptr

    cdef object __weakref__

    def addShape(self, object shape):
        pass
        #self.thisptr.addShape(<avoid.ShapeRef*>(shape.thisptr))



# vim: sw=4:et:ai
