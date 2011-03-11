
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

cdef inline avoid.Polygon* new_polygon(points):
    """
    Create a new Polygon instance. Caller is responsible for deleting it.
    """
    cdef avoid.Polygon *polygon
    cdef int i
    cdef double x, y
    polygon = new avoid.Polygon(len(points))
    for i, (x, y) in enumerate(points):
        polygon.ps[i] = avoid.Point(x, y)
    return polygon


cdef class Polygon:
    cdef avoid.Polygon *thisptr

    def __cinit__(self, *points):
        """
        Create a new polygon based on a set of points.

        >>> p = Polygon((0,0), (3, 0), (1.5, 2))
        >>> p
        <...>
        """
        self.thisptr = new_polygon(points)

    def __dealloc__(self):
        del self.thisptr

    def __len__(self):
        return self.thisptr.ps.size()

    def __getitem__(self, long index):
        return (self.thisptr.ps[index].x, self.thisptr.ps[index].y)

    def __setitem__(self, long index, object point):
        cdef double x, y
        if index < 0:
            index = self.thisptr.size() + index
        assert 0 <= index < <long>self.thisptr.size()
        x, y = point
        self.thisptr.ps[index] = avoid.Point(x, y)


cdef class Rectangle(Polygon):
    def __cinit__(self, object topLeft, object bottomRight):
        cdef double tlx, tly, brx, bry
        tlx, tly = topLeft
        brx, bry = bottomRight
        self.thisptr = new avoid.Rectangle(avoid.Point(tlx, tly),
                                           avoid.Point(brx, bry))


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
    """
    A ShapeRef denotes some shape lines should be routed around.
    """

    def __cinit__(object self, Router router, Polygon polygon):
        self.thisptr = new avoid.ShapeRef(router.thisptr, deref(polygon.thisptr), iid(self))
        self.owner = True
        self._router_ref = PyWeakref_NewRef(router, None)

    def __dealloc__(self):
        # if self.router and self.thisptr in self.router.m_obstacles:
        if self.owner:
            del self.thisptr


cdef class JunctionRef(Obstacle):
    """
    A Junction denotes a point where one or more connection ends (ConnEnd)
    come together.
    """

    def __cinit__(object self, Router router, object position):
        cdef double x, y
        x, y = position
        self.thisptr = new avoid.JunctionRef(router.thisptr, avoid.Point(x, y), iid(self))
        self.owner = True
        self._router_ref = PyWeakref_NewRef(router, None)

    def __dealloc__(self):
        if self.owner:
            del self.thisptr

    def removeJunctionAndMergeConnectors(self):
        """
        Remove function from router (if applicable) and merge the two
        connectors into one.
        """
        cdef avoid.ConnRef *connRef = (<avoid.JunctionRef*>(self.thisptr)).removeJunctionAndMergeConnectors()
        # TODO: find the connRef (from the router?) and return it.


cdef class ConnEnd:
    cdef avoid.ConnEnd *thisptr

    def __cinit__(self, object point=None, object shape=None, object junction=None):
        if point:
            self.thisptr = new avoid.ConnEnd(avoid.Point(point[0], point[1]))
        #elif shape:
        #    self.thisptr = new avoid.ConnEnd(shape.thisptr)

    def __dealloc__(self):
        del self.thisptr

    property position:
        def __get__(self):
            cdef avoid.Point p = self.thisptr.position()
            return (p.x, p.y)

#cdef inline avoid.ConnEnd to_connend(object src, unsigned int connectionPinClassIdOrConnDirFlags):
#    if isinstance(src, ShapeRef):
#        return avoid.ConnEnd(<avoid.ShapeRef*>(<Obstacle>src).thisptr, connectionPinClassIdOrConnDirFlags)
#    elif isinstance(src, JunctionRef):
#        return avoid.ConnEnd(<avoid.JunctionRef*>(<Obstacle>src).thisptr)
#    else:
#        x, y = src
#        return avoid.ConnEnd(avoid.Point(x, y), connectionPinClassIdOrConnDirFlags)

cdef void _connref_callback(void *ptr):
    cdef self = <object>ptr
    if self._callback is None:
        self._callback(self._callback_data)

cdef class ConnRef:
    cdef avoid.ConnRef *thisptr
    cdef object _router_ref
    cdef object _callback
    cdef object _callback_data
    cdef bint owner

    def __cinit__(self, Router router, object src=None, object dst=None):
        self.thisptr = new avoid.ConnRef(router.thisptr, iid(self))
        self._router_ref = PyWeakref_NewRef(router, None)
        if src:
            self.setSourceEndpoint(src)
        if dst:
            self.setDestEndpoint(dst)
        self._callback = None
        self._callback_data = None

    def __dealloc__(self):
        # ConnRef is always owned by Router
        #del self.thisptr
        pass

    def setSourceEndpoint(self, object src not None,
            unsigned int connectionPinClassIdOrConnDirFlags=avoid.ConnDirAll):
        # connectionPinClassId == ConnDirFlags. Default is 15
        if isinstance(src, ShapeRef):
            self.thisptr.setSourceEndpoint(
                    avoid.ConnEnd(<avoid.ShapeRef*>(<Obstacle>src).thisptr,
                                  connectionPinClassIdOrConnDirFlags))
        elif isinstance(src, JunctionRef):
            self.thisptr.setSourceEndpoint(
                    avoid.ConnEnd(<avoid.JunctionRef*>(<Obstacle>src).thisptr))
        else:
            x, y = src
            self.thisptr.setSourceEndpoint(
                    avoid.ConnEnd(avoid.Point(x, y),
                                  connectionPinClassIdOrConnDirFlags))

    def setDestEndpoint(self, object dst not None,
            unsigned int connectionPinClassIdOrConnDirFlags=avoid.ConnDirAll):
        # connectionPinClassId == ConnDirFlags. Default is 15
        if isinstance(dst, ShapeRef):
            self.thisptr.setDestEndpoint(avoid.ConnEnd(<avoid.ShapeRef*>(<Obstacle>dst).thisptr, connectionPinClassIdOrConnDirFlags))
        elif isinstance(dst, JunctionRef):
            self.thisptr.setDestEndpoint(avoid.ConnEnd(<avoid.JunctionRef*>(<Obstacle>dst).thisptr))
        else:
            x, y = dst
            self.thisptr.setDestEndpoint(avoid.ConnEnd(avoid.Point(x, y), connectionPinClassIdOrConnDirFlags))

    def setCallback(self, object callback, object data):
        self._callback = callback
        self._callback_data = data
        if callback:
            self.thisptr.setCallback(_connref_callback, <void*>self)
        else:
            # Unset callback
            self.thisptr.setCallback(NULL, NULL)

    property router:
        def __get__(self):
            return <object>PyWeakref_GetObject(self._router_ref)



cdef class Router:
    POLY_LINE = avoid.PolyLineRouting
    ORTHOGONAL = avoid.OrthogonalRouting

    cdef avoid.Router *thisptr
    cdef set _obstacles
    cdef set _connrefs
    # Obstacles are not removed directly. First a processTransaction() is
    # required. Hence we need to cache them before handing over control.
    cdef set _to_be_removed

    def __cinit__(self, router_flag=avoid.PolyLineRouting):
        self.thisptr = new avoid.Router(router_flag)
        self._obstacles = set()
        self._connrefs = set()
        self._to_be_removed = set()

    def __dealloc__(self):
        del self.thisptr

    def __del__(self):
        # Clean up dangling updates
        self.processTransaction()

    cdef object __weakref__

    def setTransactionUse(self, bint useTransactions):
        self.thisptr.setTransactionUse(useTransactions)

    def processTransaction(self):
        cdef bint result = self.thisptr.processTransaction()
        cdef Obstacle o
        for o in self._to_be_removed: o.owner = True
        self._to_be_removed.clear()
        return result

    def addShape(self, ShapeRef shape not None):
        assert self is shape.router
        self._obstacles.add(shape)
        shape.owner = False
        self.thisptr.addShape(<avoid.ShapeRef*>(shape.thisptr))

    def removeShape(self, ShapeRef shape not None):
        assert self is shape.router
        self.thisptr.removeShape(<avoid.ShapeRef*>(shape.thisptr))
        self._obstacles.remove(shape)
        if self.thisptr.transactionUse():
            self._to_be_removed.add(shape)

    def moveShape(self, ShapeRef shape not None, Polygon polygon not None):
        assert self is shape.router
        self.thisptr.moveShape(<avoid.ShapeRef*>shape.thisptr, deref(polygon.thisptr))

    def moveShapeRel(self, ShapeRef shape not None, double dx, double dy):
        assert self is shape.router
        self.thisptr.moveShape(<avoid.ShapeRef*>shape.thisptr, dx, dy)

    def outputInstanceToSVG(self, char* c_string): 
        cdef avoid.std_string cpp_string = avoid.charp_to_stdstring(c_string) 
        self.thisptr.outputInstanceToSVG(cpp_string) 

# vim: sw=4:et:ai
