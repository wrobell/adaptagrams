/*
 * vim: ts=4 sw=4 et tw=0 wm=0
 *
 * libavoid - Fast, Incremental, Object-avoiding Line Router
 *
 * Copyright (C) 2010  Monash University
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * See the file LICENSE.LGPL distributed with the library.
 *
 * Licensees holding a valid commercial license may use this file in
 * accordance with the commercial license agreement provided with the 
 * library.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *
 * Author(s):   Michael Wybrow <mjwybrow@users.sourceforge.net>
*/


#include "libavoid/junction.h"
#include "libavoid/router.h"
#include "libavoid/connectionpin.h"


namespace Avoid {


JunctionRef::JunctionRef(Router *router, Point position, const unsigned int id)
    : m_router(router),
      m_position(position),
      m_active(false)
{
    COLA_ASSERT(m_router != NULL);
    m_id = m_router->assignId(id);

    // Set up pins in four directions:
    m_connection_pins.insert(new Avoid::ShapeConnectionPin(this, 
            Avoid::CONNECTIONPIN_CENTRE, ConnDirUp));
    m_connection_pins.insert(new Avoid::ShapeConnectionPin(this, 
            Avoid::CONNECTIONPIN_CENTRE, ConnDirDown));
    m_connection_pins.insert(new Avoid::ShapeConnectionPin(this, 
            Avoid::CONNECTIONPIN_CENTRE, ConnDirLeft));
    m_connection_pins.insert(new Avoid::ShapeConnectionPin(this, 
            Avoid::CONNECTIONPIN_CENTRE, ConnDirRight));
}


void JunctionRef::preferOrthogonalDimension(const size_t dim)
{
    const double smallPenalty = 1.0;
    for (std::set<ShapeConnectionPin *>::iterator curr = 
            m_connection_pins.begin(); curr != m_connection_pins.end(); ++curr)
    {
        ShapeConnectionPin *pin = *curr;
        if (dim == YDIM)
        {
            if (pin->directions() & (ConnDirLeft | ConnDirRight))
            {
                pin->setConnectionCost(smallPenalty);
            }
        }
        else if (dim == XDIM)
        {
            if (pin->directions() & (ConnDirUp | ConnDirDown))
            {
                pin->setConnectionCost(smallPenalty);
            }
        }
    }
}


JunctionRef::~JunctionRef()
{
    if (m_active)
    {
        makeInactive();
    }
    // Free and clear any connection pins.
    while (!m_connection_pins.empty())
    {
        delete *(m_connection_pins.begin());
    }
}


unsigned int JunctionRef::id(void) const
{
    return m_id;
}


Router *JunctionRef::router(void) const
{
    return m_router;
}


Point JunctionRef::position(void) const
{
    return m_position;
}


void JunctionRef::setPosition(const Point& position)
{
    m_position = position;
}


bool JunctionRef::isActive(void) const
{
    return m_active;
}


void JunctionRef::makeActive(void)
{
    COLA_ASSERT(!m_active);
    
    // Add to junctionRefs list.
    m_junctionrefs_pos = m_router->junctionRefs.insert(
            m_router->junctionRefs.begin(), this);

    m_active = true;
}


void JunctionRef::makeInactive(void)
{
    COLA_ASSERT(m_active);
    
    // Remove from junctionRefs list.
    m_router->junctionRefs.erase(m_junctionrefs_pos);

    m_active = false;
    
    // Turn attached ConnEnds into manual points.
    bool deletedShape = true;
    while (!m_following_conns.empty())
    {
        ConnEnd *connEnd = *(m_following_conns.begin());
        connEnd->disconnect(deletedShape);
    }
}


void JunctionRef::removeFromGraph(void)
{
}


void JunctionRef::addFollowingConnEnd(ConnEnd *connEnd)
{
    m_following_conns.insert(connEnd);
}


void JunctionRef::removeFollowingConnEnd(ConnEnd *connEnd)
{
    m_following_conns.erase(connEnd);
}

void JunctionRef::moveAttachedConns(const Point& newPosition)
{
    // Update positions of attached connector ends.
    for (std::set<ConnEnd *>::iterator curr = m_following_conns.begin();
            curr != m_following_conns.end(); ++curr)
    {
        ConnEnd *connEnd = *curr;
        COLA_ASSERT(connEnd->m_conn_ref != NULL);
        m_router->modifyConnector(connEnd->m_conn_ref, connEnd->type(), 
                *connEnd);
    }
    for (std::set<ShapeConnectionPin *>::iterator curr = 
            m_connection_pins.begin(); curr != m_connection_pins.end(); ++curr)
    {
        ShapeConnectionPin *pin = *curr;
        pin->updatePosition(newPosition);
    }
}


unsigned int JunctionRef::addConnectionPin(ShapeConnectionPin *pin)
{
    m_connection_pins.insert(pin);

    return m_connection_pins.size();
}


void JunctionRef::removeConnectionPin(ShapeConnectionPin *pin)
{
    m_connection_pins.erase(pin);
}


ConnRef *JunctionRef::removeJunctionAndMergeConnectors(void)
{
    if (m_following_conns.size() != 2)
    {
        return NULL;
    }

    std::set<ConnEnd *>::iterator curr = m_following_conns.begin();
    ConnEnd *connEnd1 = *curr;
    ++curr;
    ConnEnd *connEnd2 = *curr;
    COLA_ASSERT(connEnd2->m_conn_ref != NULL);
    COLA_ASSERT(connEnd1->m_conn_ref != NULL);

    // The second conn will be the one we will delete.
    ConnRef *conn2 = connEnd2->m_conn_ref;
    // So, determine its endpoint that is not attached to the junction.
    ConnEnd *connEnd2Other = (conn2->m_src_connend == connEnd2) ? 
            conn2->m_dst_connend : conn2->m_src_connend;
    if (connEnd2Other == NULL)
    {
        // If it doesn't have a valid other endpoint, then ignore.
        return NULL;
    }
    // Modify the first connectors junction endpoint to connect to the 
    // other end of the second connector.
    m_router->modifyConnector(connEnd1->m_conn_ref, connEnd2Other->type(), 
            *connEnd2Other);

    // Delete the second connector.
    delete conn2;

    // Remove the junction from the router scene.  It should get deleted later.
    m_router->removeJunction(this);

    // Return the first (i.e. merged) connector.
    return connEnd1->m_conn_ref;
}


//============================================================================
}


