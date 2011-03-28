
from cython.operator cimport dereference as deref
cimport avoid

from cpython.weakref cimport PyWeakref_NewRef, PyWeakref_GetObject, PyWeakref_CheckRef
from cpython.ref cimport Py_INCREF


DEBUG = False

cdef inline void debug(char *msg, params):
    if DEBUG: print msg % (params)

cdef unsigned int iid(object o):
    return id(o) & 0xFFFFFFFF

# The following classes lose ownership once passed to a Router:
#        Avoid::ShapeRef,
#        Avoid::ConnRef,
#        Avoid::ClusterRef,
#        Avoid::JunctionRef,
# In the next case ownership is passed to the parent shapeRef/junctionRef
#        Avoid::ShapeConnectionPin

cdef inline void to_polygon(object points, avoid.Polygon &polygon):
    cdef int i
    cdef double x, y
    for i, (x, y) in enumerate(points):
        polygon.ps[i] = avoid.Point(x, y)


cdef inline object from_polygon(avoid.Polygon &polygon):
        cdef unsigned int index
        cdef object points = []
        for index from 0 <= index < polygon.ps.size():
            points.append((polygon.ps[index].x,
                           polygon.ps[index].y))
        return points


def rectangle(object topLeft, object bottomRight):
    """Create a rectangular polygon.
    """
    cdef double xMin, xMax, yMin, yMax
    xMin = min(topLeft[0], bottomRight[0])
    xMax = max(topLeft[0], bottomRight[0])
    yMin = min(topLeft[1], bottomRight[1])
    yMax = max(topLeft[1], bottomRight[1])

    return ((xMax, yMin), (xMax, yMax), (xMin, yMax), (xMin, yMin))


cdef class Router


cdef class Obstacle:
    cdef avoid.Obstacle *thisptr
    cdef bint owner
    cdef object _router_ref
    cdef object _owned_pins

    property position:
        def __get__(self):
            cdef avoid.Point p = self.thisptr.position()
            return (p.x,p.y)

    property polygon:
        def __get__(self):
            return from_polygon(<avoid.Polygon&>(self.thisptr.polygon()))

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
    ATTACH_POS_TOP = 0
    ATTACH_POS_LEFT = 0
    ATTACH_POS_CENTRE = 0.5
    ATTACH_POS_BOTTOM = 1
    ATTACH_POS_RIGHT = 1

    def __cinit__(object self, Router router, object points):
        cdef avoid.Polygon polygon = avoid.Polygon(len(points))
        to_polygon(points, polygon)
        self.thisptr = new avoid.ShapeRef(router.thisptr, polygon, iid(self))
        self.owner = True
        self._router_ref = PyWeakref_NewRef(router, None)

    def __dealloc__(self):
        # if self.router and self.thisptr in self.router.m_obstacles:
        debug('ShapeRef%s.__dealloc__()', self)
        if self.owner:
            del self.thisptr
        debug('ShapeRef%s.__dealloc__() done', self)

    def addConnectionPin(self, unsigned int classId,
                double xPortionOffset, double yPortionOffset, 
                double insideOffset = 0.0, unsigned int visDirs = 0):
        assert self.router
        avoid.ShapeConnectionPin(<avoid.ShapeRef*>self.thisptr, classId, xPortionOffset,
            yPortionOffset, insideOffset, visDirs)

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
        debug('JunctionRef%s.__dealloc__()', self)
        if self.owner:
            del self.thisptr
        debug('JunctionRef%s.__dealloc__() done', self)

    def removeJunctionAndMergeConnectors(self):
        """
        Remove function from router (if applicable) and merge the two
        connectors into one.
        """
        cdef avoid.ConnRef *connRef = (<avoid.JunctionRef*>(self.thisptr)).removeJunctionAndMergeConnectors()
        # TODO: find the connRef (from the router?) and return it.

    def addConnectionPin(self, unsigned int classId, unsigned int visDirs = 0):
        assert self.router
        avoid.ShapeConnectionPin(<avoid.JunctionRef*>self.thisptr, classId, visDirs)


cdef void _connref_callback(void *ptr):
    cdef ConnRef self = <ConnRef>ptr
    self._callback[0](*(self._callback[1]))


cdef class ConnRef:
    #
    # NOTE:
    # ConnRef is added to the router on creation time (contrary to ShapeRef and
    # JunctionRef). To remove call Router.removeConn(connRef).
    #
    cdef avoid.ConnRef *thisptr
    cdef object _router_ref
    cdef object _callback
    #cdef bint owner

    def __cinit__(self, Router router, object src=None, object dst=None):
        self.thisptr = new avoid.ConnRef(router.thisptr, iid(self))
        self._router_ref = PyWeakref_NewRef(router, None)
        if src:
            self.setSourceEndpoint(src)
        if dst:
            self.setDestEndpoint(dst)

    def __dealloc__(self):
#        # ConnRef is always owned by Router
#        #del self.thisptr
        debug('ConnRef%s.__dealloc__()', self)
        self._router_ref = None
        self._callback = None
        debug('ConnRef%s.__dealloc__() done', self)

    def setSourceEndpoint(self, object src not None,
            unsigned int connectionPinClassIdOrConnDirFlags=avoid.ConnDirAll):
        # connectionPinClassId == ConnDirFlags. Default is 15
        assert self.router
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
        assert self.router
        if isinstance(dst, ShapeRef):
            self.thisptr.setDestEndpoint(avoid.ConnEnd(<avoid.ShapeRef*>(<Obstacle>dst).thisptr, connectionPinClassIdOrConnDirFlags))
        elif isinstance(dst, JunctionRef):
            self.thisptr.setDestEndpoint(avoid.ConnEnd(<avoid.JunctionRef*>(<Obstacle>dst).thisptr))
        else:
            x, y = dst
            self.thisptr.setDestEndpoint(avoid.ConnEnd(avoid.Point(x, y), connectionPinClassIdOrConnDirFlags))

    def setCallback(self, object callback, *data):
        assert self.router
        if callback:
            self._callback = (callback, data)
            self.thisptr.setCallback(_connref_callback, <void*>self)
        else:
            # Unset callback
            self.thisptr.setCallback(NULL, NULL)
            self._callback = None

    property router:
        def __get__(self):
            return self._router_ref and <object>PyWeakref_GetObject(self._router_ref)

    property displayRoute:
        def __get__(self):
            assert self.router
            return from_polygon(self.thisptr.displayRoute())


cdef class Router:
    # RoutingFlag
    POLY_LINE = avoid.PolyLineRouting
    ORTHOGONAL = avoid.OrthogonalRouting

    # PenaltyType
    SEGMENT_PENALTY = avoid.segmentPenalty
    ANGLE_PENALTY = avoid.anglePenalty
    CROSSING_PENALTY = avoid.crossingPenalty
    CLUSTER_CROSSING_PENALTY = avoid.clusterCrossingPenalty
    FIXED_SHARED_PATH_PENALTY = avoid.fixedSharedPathPenalty
    PORT_DIRECTION_PENALTY = avoid.portDirectionPenalty

    cdef avoid.Router *thisptr
    cdef set _obstacles
    cdef set _connrefs
    # Obstacles are not removed directly. First a processTransaction() is
    # required. Hence we need to cache them before handing over control.
    cdef set _to_be_removed

    def __cinit__(Router self, unsigned int router_flag=avoid.PolyLineRouting):
        self.thisptr = new avoid.Router(<avoid.RouterFlag>router_flag)
        self._obstacles = set()
        self._connrefs = set()
        self._to_be_removed = set()

    def __dealloc__(Router self):
        # Clean up dangling updates (not the Python one!)
        self.thisptr.processTransaction()
        debug('Router%s.__dealloc__', self)
        del self.thisptr
        debug('Router%s.__dealloc__ finished', self)

#    def __del__(self):
#        # Gain some stability in knowing the router is always deleted first
#        pass
##        print 'Delete router', self

    cdef object __weakref__

    def setTransactionUse(Router self, bint useTransactions):
        self.thisptr.setTransactionUse(useTransactions)

    def processTransaction(Router self):
        cdef bint result = self.thisptr.processTransaction()
        cdef Obstacle o
        #print 'Objects no longer owned by router:', self._to_be_removed
        for o in self._to_be_removed: o.owner = True
        self._to_be_removed.clear()
        return result

    def addShape(Router self, ShapeRef shape not None):
        assert self is shape.router
        self._obstacles.add(shape)
        shape.owner = False
        self.thisptr.addShape(<avoid.ShapeRef*>(shape.thisptr))

    def removeShape(Router self, ShapeRef shape not None):
        assert self is shape.router
        self.thisptr.removeShape(<avoid.ShapeRef*>(shape.thisptr))
        self._obstacles.remove(shape)
        if self.thisptr.transactionUse():
            self._to_be_removed.add(shape)

    def moveShape(Router self, ShapeRef shape not None, object points not None):
        assert self is shape.router
        cdef avoid.Polygon polygon = avoid.Polygon(len(points))
        to_polygon(points, polygon)
        self.thisptr.moveShape(<avoid.ShapeRef*>shape.thisptr, polygon)

    def moveShapeRel(Router self, ShapeRef shape not None, double dx, double dy):
        assert self is shape.router
        self.thisptr.moveShape(<avoid.ShapeRef*>shape.thisptr, dx, dy)

    def addJunction(Router self, JunctionRef junction not None):
        assert self is junction.router
        self._obstacles.add(junction)
        junction.owner = False
        self.thisptr.addJunction(<avoid.JunctionRef*>(junction.thisptr))

    def removeJunction(Router self, JunctionRef junction not None):
        assert self is junction.router
        self.thisptr.removeJunction(<avoid.JunctionRef*>(junction.thisptr))
        self._obstacles.remove(junction)
        if self.thisptr.transactionUse():
            self._to_be_removed.add(junction)

    def moveJunction(Router self, JunctionRef junction not None, object point not None):
        assert self is junction.router
        cdef double x, y
        x, y = point
        self.thisptr.moveJunction(<avoid.JunctionRef*>junction.thisptr, avoid.Point(x, y))

    def moveJunctionRel(Router self, JunctionRef junction not None, double dx, double dy):
        assert self is junction.router
        self.thisptr.moveJunction(<avoid.JunctionRef*>junction.thisptr, dx, dy)

    def removeConn(Router self, ConnRef conn not None):
        conn._router_ref = None
        del conn.thisptr

    def setRoutingPenalty(Router self, unsigned int penaltyType, double penVal):
        self.thisptr.setRoutingPenalty(<avoid.PenaltyType>penaltyType, penVal)

    def routingPenalty(Router self, unsigned int penaltyType):
        return self.thisptr.routingPenalty(<avoid.PenaltyType>penaltyType)

    def outputInstanceToSVG(Router self, char* c_string): 
        cdef avoid.std_string cpp_string = avoid.charp_to_stdstring(c_string) 
        self.thisptr.outputInstanceToSVG(cpp_string) 

# vim: sw=4:et:ai
