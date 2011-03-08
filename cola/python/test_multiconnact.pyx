# Cython version of libavoid/tests/multiconnact.cpp.

from cython.operator cimport dereference as deref
from avoid cimport * #Point, ConnRef, Router, RouterFlag

cdef void multiconnact_callback(void *ptr):
    cdef ConnRef *connRef = <ConnRef *>ptr
    cdef PolyLine route = connRef.displayRoute()

    print("Connector %u needs rerouting!" % connRef.id());

    print "New path: ",
    for i in range(0, route.ps.size()):
        print "%s(%f, %f)" % ((i > 0) and "-" or "", route.ps[i].x, route.ps[i].y),
    print

def test_multiconnact():
    cdef Router *router= new Router(OrthogonalRouting)
    cdef Point srcPt = Point(0, 400)
    cdef Point dstPt = Point(775, 400)
    cdef ConnRef *connRef = new ConnRef(router, ConnEnd(srcPt), ConnEnd(dstPt), 0)
    connRef.setCallback(multiconnact_callback, connRef)

    cdef Point srcPt2 = Point(775,625)
    cdef Point dstPt2 = Point(350,475)
    cdef ConnRef *connRef2 = new ConnRef(router, ConnEnd(srcPt2), ConnEnd(dstPt2), 0)
    connRef2.setCallback(multiconnact_callback, connRef2)
     
    router.processTransaction()

    print "Shifting endpoint."
    connRef.setEndpoints(ConnEnd(Point(0,375)), ConnEnd(Point(775,400)))
    connRef2.setEndpoints(ConnEnd(Point(775,625)), ConnEnd(Point(350,450)))
    router.processTransaction()

    print "Shifting endpoint."
    connRef.setEndpoints(ConnEnd(Point(0,400)), ConnEnd(Point(775,400)))
    connRef2.setEndpoints(ConnEnd(Point(775,625)), ConnEnd(Point(350,475)))
    router.processTransaction()


if __name__ == '__main__':
    test_multiconnact()


# vim:sw=4:et:ai
