# Cython version of libavoid/tests/example.cpp.

from cython.operator cimport dereference as deref
from _libavoid cimport * #Point, ConnRef, Router, RouterFlag

cdef void example_callback(void *ptr):
    cdef ConnRef *connRef = <ConnRef *>ptr
    cdef PolyLine route = connRef.displayRoute()

    print("Connector %u needs rerouting!" % connRef.id());

    print "New path: ",
    for i in range(0, route.ps.size()):
        print "%s(%f, %f)" % ((i > 0) and "-" or "", route.ps[i].x, route.ps[i].y),
    print

def test_example():
    cdef Router *router= new Router(OrthogonalRouting)

    cdef Polygon shapePoly = Polygon(3)

    shapePoly.ps[0] = Point(1, 1)
    shapePoly.ps[1] = Point(2.5, 1.5)
    shapePoly.ps[2] = Point(1.5, 2.5)

    cdef ShapeRef *shapeRef = new ShapeRef(router, shapePoly, 0)

    cdef Point srcPt = Point(1.2, 0.5)
    cdef Point dstPt = Point(1.5, 4)
    cdef ConnRef *connRef = new ConnRef(router, ConnEnd(srcPt), ConnEnd(dstPt))
    connRef.setCallback(example_callback, connRef);

    # Force inital callback:
    router.processTransaction()

    print "Adding a shape."
    router.addShape(shapeRef)
    router.processTransaction()

    print "Shifting endpoint."
    cdef Point dstPt2 = Point(6, 4.5)
    connRef.setDestEndpoint(ConnEnd(dstPt2))
    # It's expected you know the connector needs rerouting, so the callback
    # isn't called.  You can force it to be called though, via:
    router.processTransaction()

    print "Moving shape right by 0.5."
    router.moveShape(shapeRef, 0.5, 0)
    router.processTransaction()


if __name__ == '__main__':
    test_example()


# vim:sw=4:et:ai
