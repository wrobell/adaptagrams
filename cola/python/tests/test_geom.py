"""
Test suite. To run the tests, execute nosetests from the command line.
"""

import sys
import weakref
from nose.tools import *
from libavoid import *


def test_polygon():
    poly = Polygon((0, 0), (4,0), (4, 4))
    assert_equals((0, 0), poly[0])
    assert_equals((4, 0), poly[1])
    assert_equals((4, 4), poly[2])
    
    poly[1] = (2, 3)
    assert_equals((0, 0), poly[0])
    assert_equals((2, 3), poly[1])
    assert_equals((4, 4), poly[2])


@raises(AssertionError)
def test_polygon_has_fixed_size():
    poly = Polygon((0, 0), (4,0), (4, 4))
    poly[4] = (0, 0)
        

@raises(ValueError)
def test_polygon_can_only_take_pairs():
    poly = Polygon((0, 0), (4,0), (4, 4))
    poly[1] = (0, 0, 0)


def test_rectangle():
    rect = Rectangle((0, 0), (3, 4))
    assert_equals((3, 4), rect[1])
    assert_equals((0, 0), rect[3])


def test_connend():
    c = ConnEnd((2,4))
    assert_equals((2, 4), c.position)


def test_router_instantiation():
    router = Router(Router.POLY_LINE)
    assert_equals(2, sys.getrefcount(router)) # router + refcount
    w_router = weakref.ref(router)
    del router
    assert_equals(None, w_router())


def test_router_shape_refcount():
    """
    Test if reference counting goes well with router and shapes.
    """
    router = Router()
    poly = Polygon((0, 0), (4, 0), (4, 4))
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
    poly = Polygon((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del poly
    assert_equals([(0.0, 0.0), (4.0, 0.0), (4.0, 4.0)], shape.polygon)
    assert_equals(((0.0, 0.0), (4.0, 4.0)), shape.boundingBox)
    assert_true(router is shape.router)

def test_router_and_shape():
    router = Router()
    poly = Polygon((0, 0), (4, 0), (4, 4))
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
    poly = Polygon((0, 0), (4, 0), (4, 4))
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
    poly = Polygon((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    router2.addShape(shape)


def test_shaperef_move():
    router = Router()
    poly = Polygon((0, 0), (4, 0), (4, 4))
    shape = ShapeRef(router, poly)
    del poly
    router.addShape(shape)
    router.processTransaction()
    router.moveShape(shape, Polygon((1,1), (5,1), (5,5)))
    router.processTransaction()
    assert_equals((1.0, 1.0), shape.polygon[0])

    router.moveShapeRel(shape, 1, 1)
    router.processTransaction()
    assert_equals((2.0, 2.0), shape.polygon[0])

    router.removeShape(shape)
    router.processTransaction()


# vim:sw=4:et:ai
