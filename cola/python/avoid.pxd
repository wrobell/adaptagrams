"""
This module contains the C++ code wrappers.
"""

from libcpp import bool
from libcpp.vector cimport vector

ctypedef void (*conn_ref_cb)(void *ptr)

cdef extern from "libavoid/libavoid.h" namespace "Avoid":
    cdef enum ConnType:
        ConnType_None
        ConnType_PolyLine
        ConnType_Orthogonal

    cdef enum RouterFlag:
        PolyLineRouting
        OrthogonalRouting

    cdef enum ConnDirFlag:
        ConnDirNone
        ConnDirUp
        ConnDirDown
        ConnDirLeft
        ConnDirRight
        ConnDirAll

    cdef enum PenaltyType:
        segmentPenalty
        anglePenalty
        crossingPenalty
        clusterCrossingPenalty
        fixedSharedPathPenalty
        portDirectionPenalty


    cdef cppclass Router


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
        # from PolygonInterface:
        void clear()
        bint empty()
        Point& at(int index)
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


    cdef cppclass ShapeRef(Obstacle):
        ShapeRef(Router *router, Polygon &poly, unsigned int id)
        #ShapeRef(Router *router, Polygon &poly)
        #void transformConnectionPinPositions(ShapeTransformationType transform)
        #ConnRefList attachedConnectors(void)


    cdef cppclass JunctionRef(Obstacle):
        Junction()


    cdef cppclass ConnEnd:
        ConnEnd(Point&)
        ConnEnd(Point&, ConnDirFlag)
        #ConnEnd(ShapeRef&, unsigned int connectionPinClassID)
        #ConnEnd(JunctionRef&)
        Point position()


    cdef cppclass ConnRef:
        ConnRef(Router *router, unsigned int id)
        ConnRef(Router *router, ConnEnd& src, ConnEnd& dst, unsigned int id)
        ConnRef(Router *router, ConnEnd& src, ConnEnd& dst)
        unsigned int id()
        void setEndpoints(ConnEnd& srcPoint, ConnEnd& dstPoint)
        void setSourceEndpoint(ConnEnd& srcPoint)
        void setDestEndpoint(ConnEnd& dstPoint)
        void setCallback(conn_ref_cb, void *ptr)
        PolyLine& displayRoute()


    cdef cppclass Router:
        Router(RouterFlag)
        void setTransactionUse(bint)
        bint transactionUse()
        bint processTransaction()
        void setRoutingPenalty(PenaltyType, double penVal)
        double routingPenalty(PenaltyType)
        
        void addShape(ShapeRef*)
        void removeShape(ShapeRef*)
        void moveShape(ShapeRef*, Polygon&)
        void moveShape(ShapeRef*, double dx, double dy)

        void addJunction(JunctionRef*)
        void removeJunction(JunctionRef*)
        void moveJunction(JunctionRef*, Point& newPosition)
        void moveJunction(JunctionRef*, double dx, double dy)
 
 
# vim: sw=4:et:ai
