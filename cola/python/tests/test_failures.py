"""
Tests that fail (SIGSEG/abort) are placed here. They require special attention.
"""

import sys, gc
import weakref
from nose.tools import *
from libavoid import *

DEBUG = True

#gc.set_debug(gc.DEBUG_STATS | gc.DEBUG_COLLECTABLE | gc.DEBUG_UNCOLLECTABLE | gc.DEBUG_INSTANCES)

def callback(data):
    data.append(True)

#@nottest
def test_connref_callback():

    assert_equals(2, sys.getrefcount(callback))
    router = Router()
    shape = ShapeRef(router, Rectangle((2, -2), (6, 2)))
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
