
from cython.operator cimport dereference as deref
cimport avoid


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

    def __cinit__(self):
        pass

    property polygon:
        def __get__(self):
            cdef avoid.Polygon polygon = self.thisptr.polygon()
            lst = []
            for index from 0 <= index < polygon.ps.size():
                lst.append((polygon.ps[index].x,
                            polygon.ps[index].y))
            return lst
    property boundingBox:
        def __get__(self):
            cdef avoid.BBox bbox
            self.thisptr.boundingBox(bbox)
            return ((bbox.a.x, bbox.a.y), (bbox.b.x, bbox.b.y))

cdef class ShapeRef(Obstacle):
    def __cinit__(self, Router router, Polygon polygon):
        self.thisptr = new avoid.ShapeRef(router.thisptr, deref(polygon.thisptr), 0) #int(id(self)))
        self.owner = True

    def __dealloc__(self):
        if self.owner:
            del self.thisptr


cdef class ConnEnd:
    cdef avoid.ConnEnd *thisptr
    cdef bint owner

    def __cinit__(self, object point=None, object shape=None, object junction=None):
        if point:
            self.thisptr = new avoid.ConnEnd(avoid.Point(point[0], point[1]))
        #elif shape:
        #    self.thisptr = new avoid.ConnEnd(avoid.Point(point[0], point[1]))
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

    def __dealloc__(self):
        del self.thisptr

    def addShape(self, object shape):
        pass
        #self.thisptr.addShape(<avoid.ShapeRef*>(shape.thisptr))



# vim: sw=4:et:ai
