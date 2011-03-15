#* vim: ts=4 sw=4 et tw=0 wm=0
#*
#* libavoid - Fast, Incremental, Object-avoiding Line Router
#* Copyright (C) 2010  Monash University
#*
#* This library is free software; you can redistribute it and/or
#* modify it under the terms of the GNU Lesser General Public
#* License as published by the Free Software Foundation; either
#* version 2.1 of the License, or (at your option) any later version.
#* See the file LICENSE.LGPL distributed with the library.
#*
#* Licensees holding a valid commercial license may use this file in
#* accordance with the commercial license agreement provided with the 
#* library.
#*
#* This library is distributed in the hope that it will be useful,
#* but WITHOUT ANY WARRANTY; without even the implied warranty of
#* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
#*
#* Author(s):   Michael Wybrow <mjwybrow@users.sourceforge.net>
#* Python bindings: Arjan Molenaar <gaphor@gmail.com>

from libavoid import *

def test_connectionpin01():
    router = Router(Router.ORTHOGONAL)
    
    # Create the ShapeRef:
    shapeRect1 = rectangle((0, 0), (10, 10))
    shapeRef1 = ShapeRef(router, shapeRect1)
    router.addShape(shapeRef1)
    
    shapeRect2 = rectangle((40, 20), (50, 30))
    shapeRef2 = ShapeRef(router, shapeRect2)
    router.addShape(shapeRef2)

    CENTRE = 1
    #ShapeConnectionPin(shapeRef1, CENTRE, ShapeConnectionPin.ATTACH_POS_CENTRE, 
    #        ShapeConnectionPin.ATTACH_POS_CENTRE)
    #ShapeConnectionPin(shapeRef2, CENTRE, ShapeConnectionPin.ATTACH_POS_CENTRE, 
    #        ShapeConnectionPin.ATTACH_POS_CENTRE)
    # or:
    shapeRef1.addConnectionPin(CENTRE, ShapeRef.ATTACH_POS_CENTRE, 
            ShapeRef.ATTACH_POS_CENTRE)
    shapeRef2.addConnectionPin(CENTRE, ShapeRef.ATTACH_POS_CENTRE, 
            ShapeRef.ATTACH_POS_CENTRE)

    #Avoid::ConnEnd dstEnd(shapeRef1, CENTRE)
    #Avoid::ConnEnd srcEnd(shapeRef2, CENTRE)
    connRef = ConnRef(router)
    connRef.setSourceEndpoint(shapeRef1, CENTRE)
    connRef.setDestEndpoint(shapeRef2, CENTRE)
    # Force inital callback:
    router.processTransaction()
    router.outputInstanceToSVG("test-connectionpin01-1")

    router.moveShapeRel(shapeRef2, 5, 0)

    router.processTransaction()
    router.outputInstanceToSVG("test-connectionpin01-2")
    
    router.moveShapeRel(shapeRef1, 0, -10)

    router.processTransaction()
    router.outputInstanceToSVG("test-connectionpin01-3")

if __name__ == '__main__':
    test_connectionpin01()
