/**
 * Test of topology conserving constraints.  Sets up a graph
 * with four nodes and two edges, initially with two bends around the
 * first disconnected node.  After an iteration an edge segment must be split
 * to bend around the second disconnected node.
 *
 * \file split.cpp
 * \author Tim Dwyer
 * \date Dec 2007
 */
#include <libvpsc/rectangle.h>
#include <libtopology/topology_constraints.h>
#include <libcola/cola.h>
#include <libcola/output_svg.h>
#include <libvpsc/constraint.h>
#include <vector>
#include <iostream>
#include <sstream>
using namespace std;
using namespace topology;
#include "test.h"

double expectedStress=1.48116;
double expectedG1[]=
{0.00849768, -0.0192465, 0, 0.0107488};

double expectedG2[]={0.003837,-0.001923,-0.001914};
double expectedH1[]= 
{0.000312442, -0.000438933, 0,  0.000126491, 
-0.000438933,  0.000746922, 0, -0.000307989,
           0,            0, 0,            0, 
 0.000126491, -0.000307989, 0,  0.000181498};

double expectedH2[]={0.000505,-0.000169,-0.000336,
                     -0.000169,0.000165,0.000004 ,
                     -0.000336,0.000004,0.000333};

void split() {
    Nodes nodes;
    Edges es;

    printf("test: bend2()\n");

    addNode(nodes,100,100,40,20);
    addNode(nodes,100,130,40,20);
    addNode(nodes,70,160,40,20);
    addNode(nodes,180,190,40,20);
    EdgePoints p1;
    addToPath(p1,nodes[0],EdgePoint::CENTRE);
    addToPath(p1,nodes[1],EdgePoint::BL);
    addToPath(p1,nodes[1],EdgePoint::TL);
    addToPath(p1,nodes[3],EdgePoint::CENTRE);
    es.push_back(new Edge(100,p1));

    EdgePoints p2;
    addToPath(p2,nodes[2],EdgePoint::CENTRE);
    addToPath(p2,nodes[3],EdgePoint::CENTRE);
    es.push_back(new Edge(50,p2));

    const size_t V = nodes.size();

    vpsc::Constraints cs;
    vpsc::Variables vs;
    getVariables(nodes,vs);
    { // scope for t, so that t gets destroyed before es

        TopologyConstraints t(cola::HORIZONTAL,nodes,es,vs,cs);
        writeFile(nodes,es,"split-0.svg");

        // test computeStress
        double stress=t.computeStress();
        printf("Stress=%f\n",stress);
        //assert(fabs(expectedStress-stress)<1e-4);

        valarray<double> g(V);
        cola::SparseMap h(V);
        for(unsigned i=1;i<5;i++) {
            g=0;
            h.clear();
            t.gradientProjection(g,h);
            stringstream ss;
            ss << "split-" << i << ".svg";
            writeFile(nodes,es,ss.str().c_str());
        }
    }

    for_each(nodes.begin(),nodes.end(),delete_node());
    for_each(es.begin(),es.end(),delete_object());
    for_each(cs.begin(),cs.end(),delete_object());
    for_each(vs.begin(),vs.end(),delete_object());
}

int main() {
    split();
    return 0;
}
// vim: filetype=cpp:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80 :
