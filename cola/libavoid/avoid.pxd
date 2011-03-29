"""
This module contains the C++ code wrappers.
"""

from libc.stddef cimport size_t
#from libcpp import bool
#from libcpp.list cimport list
from libcpp.pair cimport pair
from libcpp.vector cimport vector


cdef extern from "libavoid/python-libavoid.h":
    cdef void LibavoidExn2PyErr()

cdef inline void critical_failure():
    LibavoidExn2PyErr()


cdef extern from "<string>":
     cdef cppclass std_string "std::string": 
         pass
     cdef std_string charp_to_stdstring "std::string"(char*) 


ctypedef void (*conn_ref_cb)(void *ptr)

cdef extern from "libavoid/libavoid.h" namespace "Avoid":
    cdef enum ConnType:
        ConnType_None
        ConnType_PolyLine
        ConnType_Orthogonal

    cdef enum RouterFlag:
        PolyLineRouting = 1
        OrthogonalRouting = 2

    cdef enum ConnDirFlag:
        ConnDirNone
        ConnDirUp
        ConnDirDown
        ConnDirLeft
        ConnDirRight
        ConnDirAll

    ctypedef unsigned int ConnDirFlags

    cdef enum PenaltyType:
        segmentPenalty
        anglePenalty
        crossingPenalty
        clusterCrossingPenalty
        fixedSharedPathPenalty
        portDirectionPenalty


    cdef cppclass Router
    cdef cppclass ConnRef

    #typedef list[ConnRef*] ConnRefList

    cdef cppclass Point:
        Point()
        Point(double, double)
        int id
        double x, y
        #bint operator==(Point)
        #bint operator<(Point)
        #double operator[](unsigned int)
        #Point operator+(Point)
        #Point operator-(Point)


    cdef cppclass Edge:
        Point a
        Point b


    ctypedef Edge BBox


    # Polygon merged methods from PolygonInterface.
    cdef cppclass Polygon:
        Polygon()
        Polygon(unsigned int n)
        int _id
        vector[Point] ps
        vector[char] ts
        size_t size()
        # from PolygonInterface:
        void clear()
        bint empty()
        Point& at(size_t index)
        Polygon boundingRect()

        
    ctypedef Polygon PolyLine


    cdef cppclass Rectangle(Polygon):
        Rectangle(Point& topLeft, Point& bottomRight)
        Rectangle(Point& centre, double width, double height)

    
    cdef cppclass Obstacle:
        unsigned int id()
        Polygon& polygon()
        Router* router()
        void boundingBox(BBox& bbox)
        Point position()


    cdef cppclass ShapeRef(Obstacle):
        ShapeRef(Router *router, Polygon &poly, unsigned int id) except +critical_failure
        #ShapeRef(Router *router, Polygon &poly)
        #void transformConnectionPinPositions(ShapeTransformationType transform)
        #ConnRefList attachedConnectors(void)


    cdef cppclass JunctionRef(Obstacle):
        JunctionRef(Router *router, Point position, unsigned int id) except +critical_failure
        ConnRef *removeJunctionAndMergeConnectors() except +critical_failure


    cdef cppclass ShapeConnectionPin:
        ShapeConnectionPin(ShapeRef* shape, unsigned int classId,
                double xPortionOffset, double yPortionOffset, 
                double insideOffset, ConnDirFlags visDirs)
        ShapeConnectionPin(JunctionRef* junction, unsigned int classId,
                ConnDirFlags visDirs)
        void setConnectionCost(double cost)
        Point position(Polygon& newPoly)
        ConnDirFlags directions()
        void setExclusive(bint exclusive)


    cdef cppclass ConnEnd:
        ConnEnd(Point&)
        ConnEnd(Point&, ConnDirFlags)
        ConnEnd(ShapeRef*, unsigned int connectionPinClassID)
        ConnEnd(JunctionRef*)
        Point position()


    cdef cppclass ConnRef:
        ConnRef(Router *router, unsigned int id) except +critical_failure
        ConnRef(Router *router, ConnEnd& src, ConnEnd& dst, unsigned int id) except +critical_failure
        ConnRef(Router *router, ConnEnd& src, ConnEnd& dst) except +critical_failure
        unsigned int id()
        void setEndpoints(ConnEnd& srcPoint, ConnEnd& dstPoint) except +critical_failure
        void setSourceEndpoint(ConnEnd& srcPoint) except +critical_failure
        void setDestEndpoint(ConnEnd& dstPoint) except +critical_failure
        Router* router()
        bint needsRepaint()
        PolyLine& route()
        PolyLine& displayRoute()
        void setCallback(conn_ref_cb, void *ptr)
        ConnType routingType()
        void setRoutingType(ConnType)
        pair[JunctionRef, ConnRef] splitAtSegment(size_t segmentN) except +critical_failure
        void setRoutingCheckpoints(vector[Point]& checkpoints)
        vector[Point] routingCheckpoints()


    cdef cppclass Router:
        Router(RouterFlag) except +critical_failure
        #~Router() except +
        void setTransactionUse(bint)
        bint transactionUse()
        bint processTransaction() except +critical_failure

        void setRoutingPenalty(PenaltyType, double penVal) except +critical_failure
        double routingPenalty(PenaltyType) except +critical_failure
        
        void moveShape(ShapeRef*, Polygon&) except +critical_failure
        void moveShape(ShapeRef*, double dx, double dy) except +critical_failure
        void deleteShape(ShapeRef*) except +critical_failure

        void moveJunction(JunctionRef*, Point& newPosition) except +critical_failure
        void moveJunction(JunctionRef*, double dx, double dy) except +critical_failure
        void deleteJunction(JunctionRef*) except +critical_failure
 
        void deleteConnector(ConnRef*) except +critical_failure

        #ObstacleList m_obstacles;
        #ConnRefList connRefs;
        #ClusterRefList clusterRefs;
        bint objectIsInQueuedActionList(void*)
        void outputInstanceToSVG(std_string) except +critical_failure
 
# vim: sw=4:et:ai
