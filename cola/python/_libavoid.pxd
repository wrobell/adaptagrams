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

    # Forward reference??
    cdef cppclass ShapeRef
    cdef cppclass Polygon

    cdef cppclass Router:
        Router(RouterFlag)
        void setTransactionUse(bint)
        bint transactionUse()
        bint processTransaction()
        # ShapeRef*
        void addShape(ShapeRef*)
        void removeShape(ShapeRef*)
        void moveShape(ShapeRef*, Polygon&)
        void moveShape(ShapeRef*, double dx, double dy)


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


    cdef cppclass ConnEnd:
        ConnEnd(Point& point)
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


    cdef cppclass ShapeRef:
        ShapeRef(Router *router, Polygon &poly, unsigned int id)
        ShapeRef(Router *router, Polygon &poly)
        Polygon& polygon()
        #void transformConnectionPinPositions(ShapeTransformationType transform)
        void boundingBox(BBox& bbox)
        #ConnRefList attachedConnectors(void)


    cdef cppclass Junction:
        Junction()


# vim: sw=4:et:ai
