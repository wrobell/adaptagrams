"""
Test suite. To run the tests, execute nosetests from the command line.
"""

from libavoid import Point

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

#def test_point_add():
#    p1 = Point(2, 4)
#    p2 = Point(2, 2)
#    p3 = p1 + p2
#    assert p3.x == 4
#    assert p3.y == 6
#
    #assert p1 == p2, '%s == %s' % (p1, p2)

    #p3 = Point(3,3)

    #assert p1 < p3


# vim:sw=4:et:ai
