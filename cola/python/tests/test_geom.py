"""
Test suite. To run the tests, execute nosetests from the command line.
"""

from libavoid import Point, Polygon, Rectangle

from nose.tools import *

def test_point():
    p1 = Point(2, 4)

    assert p1.x == 2
    assert p1.y == 4

    p1.id = 12
    assert p1.id == 12

    try:
        p1.id = 'foo'
        assert False
    except TypeError:
        pass
    p2 = Point(2, 2)


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
        

def test_rectangle():
    rect = Rectangle((0, 0), (3, 4))
    assert_equals((3, 4), rect[1])
    assert_equals((0, 0), rect[3])

# vim:sw=4:et:ai
