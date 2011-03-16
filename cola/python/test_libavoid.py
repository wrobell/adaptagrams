"""
Test suite. To run the tests, execute nosetests from the command line.
"""

import sys
import weakref
from nose.tools import *
from libavoid import *


def test_rectangle():
    rect = rectangle((0, 0), (3, 4))
    assert_equals((3, 4), rect[1])
    assert_equals((0, 0), rect[3])


def test_router_instantiation():
    router = Router(Router.POLY_LINE)
    assert_equals(2, sys.getrefcount(router)) # router + refcount
    w_router = weakref.ref(router)
    del router
    assert_equals(None, w_router())

@raises(TypeError)
def test_router_add_None_shape():
    router = Router()
    router.addShape(None)

def test_router_shape_refcount():
    """
    Test if reference counting goes well with router and shapes.
    """
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_equals(2, sys.getrefcount(router)) # router + refcount
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    router2 = shape.router
    assert_equals(3, sys.getrefcount(router)) # router + router2 + refcount
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    del router
    assert_equals(2, sys.getrefcount(router2)) # router + refcount
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount

def test_shaperef():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del poly
    assert_equals([(0.0, 0.0), (4.0, 0.0), (4.0, 4.0)], shape.polygon)
    assert_equals(((0.0, 0.0), (4.0, 4.0)), shape.boundingBox)
    assert_true(router is shape.router)

def test_router_and_shape():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    router.addShape(shape)
    assert_equals(3, sys.getrefcount(shape)) # shape + router + refcount
    router.processTransaction()
    router.removeShape(shape)
    assert_equals(3, sys.getrefcount(shape)) # shape + router + refcount
    router.processTransaction()
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    
def test_router_and_shape_delete_router():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    router.addShape(shape)
    assert_equals(3, sys.getrefcount(shape)) # shape + refcount
    del router
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    

@raises(AssertionError)
def test_shaperef_add_to_different_router():
    router = Router()
    router2 = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    router2.addShape(shape)


def test_shaperef_move():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del poly
    router.addShape(shape)
    router.processTransaction()
    router.moveShape(shape, ((1,1), (5,1), (5,5)))
    router.processTransaction()
    assert_equals((1.0, 1.0), shape.polygon[0])

    router.moveShapeRel(shape, 1, 1)
    router.processTransaction()
    assert_equals((2.0, 2.0), shape.polygon[0])

    router.removeShape(shape)
    router.processTransaction()

def test_junctionref_move():
    router = Router()
    junction = JunctionRef(router, (0, 0))
    router.addJunction(junction)
    router.processTransaction()
    router.moveJunction(junction, (3, 4))
    router.processTransaction()
    assert_equals((3.0, 4.0), junction.position)

    router.moveJunctionRel(junction, 1, 1)
    router.processTransaction()
    assert_equals((4.0, 5.0), junction.position)

    router.removeJunction(junction)
    router.processTransaction()

def test_junctionref_move_stop_halfway():
    router = Router()
    junction = JunctionRef(router, (0, 0))
    router.addJunction(junction)
    router.processTransaction()
    router.moveJunction(junction, (3, 4))
    router.processTransaction()
    assert_equals((3.0, 4.0), junction.position)

    router.removeJunction(junction)


def test_connref_with_point():
    router = Router()
    conn = ConnRef(router)
    conn.setSourceEndpoint((2,3))
    conn.setDestEndpoint((10,10))
    router.processTransaction()
    route = conn.displayRoute
    assert_equals([(2.0, 3.0), (10.0, 10.0)], route)


def test_connref_with_point_orthogonal():
    router = Router(Router.ORTHOGONAL)
    conn = ConnRef(router)
    conn.setSourceEndpoint((2,3))
    conn.setDestEndpoint((10,10))
    router.processTransaction()
    route = conn.displayRoute
    assert_equals([(2.0, 3.0), (10.0, 3.0), (10.0, 10.0)], route)


def test_connref_with_shape():
    router = Router()
    #router.setTransactionUse(False)
    conn = ConnRef(router)
    shape = ShapeRef(router, ((2, 2), (6, 2), (4, 4)))
    conn.setSourceEndpoint(shape)
    
    router.addShape(shape)
    #router.processTransaction()


def test_routing_with_output():
    router = Router()
    shape = ShapeRef(router, rectangle((2, -2), (6, 2)))
    router.addShape(shape)
    conn = ConnRef(router, (0, 0), (20, 0))
    router.processTransaction()
    router.outputInstanceToSVG('test_routing_with_output')
    #router.removeShape(shape)
    #router.processTransaction()
    #del conn
    #del shape
    #del router


#gc.set_debug(gc.DEBUG_STATS | gc.DEBUG_COLLECTABLE | gc.DEBUG_UNCOLLECTABLE | gc.DEBUG_INSTANCES)

def callback(data):
    data.append(True)

#@nottest
def test_connref_callback():

    assert_equals(2, sys.getrefcount(callback))
    router = Router()
    shape = ShapeRef(router, rectangle((2, -2), (6, 2)))
    router.addShape(shape)
    conn = ConnRef(router, (0, 0), (20, 0))
    outlist = []
#    assert_equals(2, sys.getrefcount(conn))

    # TODO: Here we can introduce circular references
    conn.setCallback(callback, outlist)
    router.processTransaction()
    assert_equals(1, len(outlist))
    assert_equals(3, sys.getrefcount(callback))
    router.moveShapeRel(shape, 1, 0)
    router.processTransaction()
    assert_equals(2, len(outlist))
    
    conn.setCallback(None, None)
    router.moveShapeRel(shape, -1, 0)
    router.processTransaction()
    assert_equals(2, len(outlist))
    assert_equals(2, sys.getrefcount(callback))

#    del router# , shape, conn, outlist
#    for i in range(10):
#        gc.collect()
#    print '*** finished collect'
#    del conn, shape
#    gc.collect()
#
#    del router

# vim:sw=4:et:ai
