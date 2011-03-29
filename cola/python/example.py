# Cython version of libavoid/tests/example.cpp.

from libavoid import *

def example_callback(connRef):
    route = connRef.displayRoute

    print("Connector %u needs rerouting!" % id(connRef));

    print "New path: ",
    for x, y in route:
        print " (%f, %f)" % (x, y),
    print

def test_example():
    router = Router(Router.ORTHOGONAL)

    shapePoly = ((1, 1), (2.5, 1.5), (1.5, 2.5))

    shapeRef = ShapeRef(router, shapePoly)

    connRef = ConnRef(router, (1.2, 0.5), (1.5, 4))
    connRef.setCallback(example_callback, connRef);

    # Force inital callback:
    router.processTransaction()

    print "Shifting endpoint."
    connRef.setDestEndpoint((6, 4.5))
    # It's expected you know the connector needs rerouting, so the callback
    # isn't called.  You can force it to be called though, via:
    router.processTransaction()

    print "Moving shape right by 0.5."
    router.moveShapeRel(shapeRef, 0.5, 0)
    router.processTransaction()


if __name__ == '__main__':
    test_example()


# vim:sw=4:et:ai
