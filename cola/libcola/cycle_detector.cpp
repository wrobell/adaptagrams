/* Cycle detector that returns a list of 
 * edges involved in cycles in a digraph.
 *
 * Kieran Simpson 2006
*/
#include <iostream>
#include <stack>
#include <vector>
#include <cassert>
#include <cycle_detector.h>

using namespace std;

// a global var representing time
TimeStamp Time;

CycleDetector::CycleDetector(unsigned numVertices, Edges *edges)  {
  this->V = numVertices; 
  this->edges = edges;

  // make the adjacency matrix
  this->make_matrix();
  assert(nodes.size() == this->V);
}

CycleDetector::~CycleDetector()  {
  if (!nodes.empty())  { for (unsigned i = 0; i < nodes.size(); i++)  { delete nodes[i]; } }
}

void CycleDetector::make_matrix()  {
  Edges::iterator ei;
  Edge anEdge;
  Node *newNode;

  if (!nodes.empty())  { for (map<unsigned, Node *>::iterator ni = nodes.begin(); ni != nodes.end(); ni++)  { delete nodes[ni->first]; } }
  nodes.clear();
  traverse.clear();

  // we should have no nodes in the list
  assert(nodes.empty());
  assert(traverse.empty());

  // from the edges passed, fill the adjacency matrix
  for (ei = edges->begin(); ei != edges->end(); ei++)  {
    anEdge = *ei;
    // the matrix is indexed by the first vertex of the edge
    // the second vertex of the edge is pushed onto another
    // vector of all vertices connected to the first vertex
    // with a directed edge
    cout << "vertex1: " << anEdge.first << ", vertex2: " << anEdge.second << endl;
    if (nodes.find(anEdge.first) == nodes.end())  { 
      cerr << "Making a new vector indexed at: " << anEdge.first << endl;
      newNode = new Node(anEdge.first);
      newNode->dests.push_back(anEdge.second);
      nodes[anEdge.first] = newNode;
    }
    else  {
      //cerr << "Pushing: " << anEdge.second << endl;
      nodes[anEdge.first]->dests.push_back(anEdge.second);
    }

    // check if the destination vertex exists in the nodes map
    if (nodes.find(anEdge.second) == nodes.end())  {
      cerr << "Making a new vector indexed at: " << anEdge.second << endl;
      newNode = new Node(anEdge.second);
      nodes[anEdge.second] = newNode;
    }
  }

  assert(!nodes.empty());

  // the following block is code to print out
  // the adjacency matrix.
  for (map<unsigned, Node *>::iterator ni = nodes.begin(); ni != nodes.end(); ni++)  {
    Node *node = ni->second;
    cout << "nodes[" << node->id << "]: ";
      
    if (isSink(node))  { cout << "SINK"; }
    else  {
      for (unsigned j = 0; j < node->dests.size(); j++)  { cout << node->dests[j] << " "; }
    }
    cout << endl;
  }
}

vector<bool> *CycleDetector::detect_cycles()  {
  vector<bool> *cyclicEdgesMapping = NULL;

  assert(!nodes.empty());
  assert(!edges->empty());

  // make a copy of the graph to ensure that we have visited all
  // vertices
  traverse.clear(); assert(traverse.empty());
  for (unsigned i = 0; i < V; i++)  { traverse[i] = false; }
  for (map<unsigned, bool>::iterator ivi = traverse.begin(); ivi != traverse.end(); ivi++)  {
    cout << "traverse{" << ivi->first << "}: " << ivi->second << endl;
  }

  // set up the mapping between the edges and their cyclic truth
  for(unsigned i = 0; i < edges->size(); i++)  { cyclicEdges[(*edges)[i]] = false; }

  // find the cycles
  assert(nodes.size() > 1);

  // while we still have vertices to visit, visit.
  while (!traverse.empty())  {
    cout << "begining search at vertex(" << traverse.begin()->first << ")" << endl;
    Time = 0;
    visit(traverse.begin()->first);
  }

  assert(traverse.empty());

  cyclicEdgesMapping = new vector<bool>(edges->size(), false);

  for (unsigned i = 0; i < edges->size(); i++)  {
    if (cyclicEdges[(*edges)[i]])  { 
      (*cyclicEdgesMapping)[i] = true;
      cout << "Setting cyclicEdgesMapping[" << i << "] to true" << endl;
    }
  }

  return cyclicEdgesMapping;
}

void CycleDetector::mod_graph(unsigned numVertices, Edges *edges)  {
  this->V = numVertices;
  this->edges = edges;
  // remake the adjaceny matrix
  this->make_matrix();
  assert(nodes.size() == this->V);
}

unsigned CycleDetector::visit(unsigned k)  {
  unsigned cycleOpen;

  // state that we have seen this vertex
  if (traverse.find(k) != traverse.end())  {
    cout << "Visiting vertex(" << k << ") for the first time" << endl;
    traverse.erase(k);
  }

  // set up this node as being visited.
  nodes[k]->stamp = ++Time;
  nodes[k]->status = Node::BeingVisited;

  // traverse to all the vertices adjacent to this vertex.
  for (unsigned n = 0; n < nodes[k]->dests.size(); n++)  {
    unsigned v = nodes[k]->dests[n];

    if (nodes[v]->status != Node::DoneVisiting)  {
      if (nodes[v]->status == Node::NotVisited)  {  
        // visit this node
        cout << "traversing from vertex(" << k << ") to vertex(" << v << ")" << endl;
        visit(v);
      }

      // if we are part of a cycle get the timestamp of the ancestor
      if (nodes[v]->cyclicAncestor != NULL)  { cycleOpen = nodes[v]->cyclicAncestor->stamp; }
      // else just get the timestamp of the node we just visited
      else  { cycleOpen = nodes[v]->stamp; }

      // compare the stamp of the traversal with our stamp
      if (cycleOpen <= nodes[k]->stamp)  {
	if (nodes[v]->cyclicAncestor == NULL)  { nodes[v]->cyclicAncestor = nodes[v]; }
	// store the cycle
	cyclicEdges[Edge(k,v)] = true;
        // this node is part of a cycle
        if (nodes[k]->cyclicAncestor == NULL)  { nodes[k]->cyclicAncestor = nodes[v]->cyclicAncestor; }

	// see if we are part of a cycle with a cyclicAncestor that possesses a lower timestamp
	if (nodes[v]->cyclicAncestor->stamp < nodes[k]->cyclicAncestor->stamp)  { nodes[k]->cyclicAncestor = nodes[v]->cyclicAncestor; }
      }
    }
  }

  nodes[k]->status = Node::DoneVisiting;
}


// determines whether or not a vertex is a sink
bool CycleDetector::isSink(Node *node)  {
  // a vertex is a sink if it has no outgoing edges,
  // or that the adj entry is empty
  if (node->dests.empty())  { return true; }
  else  { return false; }
}
