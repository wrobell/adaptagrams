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
    router = Router(POLY_LINE_ROUTING)
    assert_equals(2, sys.getrefcount(router)) # router + refcount
    w_router = weakref.ref(router)
    del router
    assert_equals(None, w_router())

@raises(RuntimeError)
def test_router_wrong_instantiation():
    router = Router(100)

def test_router_shape_refcount():
    """
    Test if reference counting goes well with router and shapes.
    """
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_equals(2, sys.getrefcount(router)) # router + refcount
    assert_equals(3, sys.getrefcount(shape)) # shape + router + refcount
    router2 = shape.router
    assert_equals(3, sys.getrefcount(router)) # router + router2 + refcount
    assert_equals(3, sys.getrefcount(shape)) # shape + refcount
    del router
    assert_equals(2, sys.getrefcount(router2)) # router + refcount
    assert_equals(3, sys.getrefcount(shape)) # shape + router2 + refcount

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
    assert_equals(3, sys.getrefcount(shape)) # shape + router + refcount
    router.processTransaction()
    assert_true(shape in router.obstacles)
    router.deleteShape(shape)
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    router.processTransaction()
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    
@raises(RuntimeError)
def test_router_and_shape_add_delete():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_true(shape in router.obstacles)
    router.deleteShape(shape)
    
def test_router_and_shape_delete_router():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    assert_true(shape in router.obstacles)
    assert_equals(3, sys.getrefcount(shape)) # shape + router + refcount
    del router
    assert_equals(2, sys.getrefcount(shape)) # shape + refcount
    

@raises(AssertionError)
def test_shaperef_move_on_different_router():
    router = Router()
    router2 = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    router2.moveShapeRel(shape, 1, 1)

def test_shaperef_destroyed_router():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del router
    shape.addConnectionPin(0, 0, 0)

@raises(AssertionError)
def test_shaperef_methodcall_after_deletion():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    router.processTransaction()
    router.deleteShape(shape)
    shape.router

def test_shaperef_move():
    router = Router()
    poly = ((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del poly
    router.processTransaction()
    router.moveShape(shape, ((1,1), (5,1), (5,5)))
    router.processTransaction()
    assert_equals((1.0, 1.0), shape.polygon[0])

    router.moveShapeRel(shape, 1, 1)
    router.processTransaction()
    assert_equals((2.0, 2.0), shape.polygon[0])

    router.deleteShape(shape)
    router.processTransaction()

def test_junctionref_move():
    router = Router()
    junction = JunctionRef(router, (0, 0))
    router.processTransaction()
    router.moveJunction(junction, (3, 4))
    router.processTransaction()
    assert_equals((3.0, 4.0), junction.position)

    router.moveJunctionRel(junction, 1, 1)
    router.processTransaction()
    assert_equals((4.0, 5.0), junction.position)

    router.deleteJunction(junction)
    router.processTransaction()

def test_junctionref_move_stop_halfway():
    router = Router()
    junction = JunctionRef(router, (0, 0))
    router.processTransaction()
    router.moveJunction(junction, (3, 4))
    router.processTransaction()
    assert_equals((3.0, 4.0), junction.position)

    router.deleteJunction(junction)


def test_connref_with_point():
    router = Router()
    conn = ConnRef(router)
    conn.setSourceEndpoint((2,3))
    conn.setDestEndpoint((10,10))
    router.processTransaction()
    route = conn.displayRoute
    assert_equals([(2.0, 3.0), (10.0, 10.0)], route)


def test_connref_with_point_orthogonal():
    router = Router(ORTHOGONAL_ROUTING)
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
    
    #router.processTransaction()


def test_routing_with_output():
    router = Router()
    shape = ShapeRef(router, rectangle((2, -2), (6, 2)))
    conn = ConnRef(router, (0, 0), (20, 0))
    router.processTransaction()
    router.outputInstanceToSVG('test_routing_with_output')
    router.deleteShape(shape)
    router.processTransaction()
    del conn
    del shape
    del router


def callback(data):
    data.append(True)

def test_connref_callback():

    assert_equals(2, sys.getrefcount(callback))
    router = Router()
    shape = ShapeRef(router, rectangle((2, -2), (6, 2)))
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

def test_connref_add_delete():
    router = Router()
    conn = ConnRef(router, (0, 0), (20, 0))
    assert_true(router.connectors)
    router.deleteConnector(conn)
    assert_false(router.connectors)

def test_connref_delete():
    router = Router()
    conn = ConnRef(router, (0, 0), (20, 0))

    router.processTransaction()
    router.outputInstanceToSVG('test_connref_delete_1')

    router.deleteConnector(conn)

    router.processTransaction()
    router.outputInstanceToSVG('test_connref_delete_2')

    try:
        conn.setSourceEndpoint((1, 1))
    except AssertionError:
        pass # ok
    else:
        assert 0, 'AssertionError should have been raised'

def test_connref_routing_checkpoints():
    router = Router()
    conn = ConnRef(router, (0, 0), (20, 0))
    conn.routingCheckpoints = ((3, 3), (4, 8))
    assert_equals([(3.0, 3.0), (4.0, 8.0)], conn.routingCheckpoints)
    # Required:
    router.processTransaction()

# vim:sw=4:et:ai
