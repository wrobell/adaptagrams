"""
This module contains the C++ code wrappers.
"""

from libcpp import bool
from libcpp.vector cimport vector

ctypedef void (*conn_ref_cb)(void *ptr)

cdef extern from "libavoid/libavoid.h" namespace "Avoid":
    cdef cppclass Point:
        Point()
        Point(double, double)
        int id
        double x, y
        bint operator==(Point)
        bint operator<(Point)
        double operator[](unsigned int)
        Point operator+(Point)
        Point operator-(Point)

    cdef enum ConnType:
        ConnType_None
        ConnType_PolyLine
        ConnType_Orthogonal

    cdef enum RouterFlag:
        PolyLineRouting
        OrthogonalRouting

#    cdef cppclass ShapeRef:

    cdef cppclass Router:
        Router(RouterFlag)
        void setTransactionUse(bint)
        bint transactionUse()
        bint processTransaction()
#        void addShape(ShapeRef*)
#        void removeShape(ShapeRef*)
#        void moveShape(ShapeRef*, Polygon&)

    cdef cppclass Polygon:
        Polygon()
        int _id
        vector[Point] ps
        vector[char] ts
        
    ctypedef Polygon PolyLine

    cdef cppclass ConnEnd:
        ConnEnd(Point& point)
        Point position()

    cdef cppclass ConnRef:
        ConnRef(Router *router, unsigned int id)
        ConnRef(Router *router, ConnEnd& src, ConnEnd& dst, unsigned int id)
        unsigned int id()
        void setEndpoints(ConnEnd& srcPoint, ConnEnd& dstPoint)
        void setSourceEndpoint(ConnEnd& srcPoint)
        void setDestEndpoint(ConnEnd& dstPoint)
        void setCallback(conn_ref_cb, void *ptr)
        PolyLine& displayRoute()



# vim: sw=4:et:ai
