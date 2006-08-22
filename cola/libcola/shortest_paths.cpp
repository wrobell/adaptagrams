// vim: set cindent 
// vim: ts=4 sw=4 et tw=0 wm=0
#include "shortest_paths.h"
#include <float.h>
#include <cassert>
#include <iostream>
#include <libvpsc/pairingheap/PairingHeap.h>
using namespace std;
namespace shortest_paths {
// O(n^3) time dynamic programming approach.  Slow, but fool proof.  Use for testing.
void floyd_warshall(
        unsigned n,
        double** D, 
        vector<Edge>& es,
        valarray<double>* eweights) 
{
    assert(!eweights||eweights->size()==es.size());
    for(unsigned i=0;i<n;i++) {
        for(unsigned j=0;j<n;j++) {
            if(i==j) D[i][j]=0;
            else D[i][j]=DBL_MAX;
        }
    }
    for(unsigned i=0;i<es.size();i++) {
        unsigned u=es[i].first, v=es[i].second;
        assert(u<n&&v<n);
        D[u][v]=D[v][u]=eweights?(*eweights)[i]:1;
    }
    for(unsigned k=0; k<n; k++) {
        for(unsigned i=0; i<n; i++) {
            for(unsigned j=0; j<n; j++) {
                D[i][j]=min(D[i][j],D[i][k]+D[k][j]);
            }
        }
    }
}
void dijkstra_init(Node* vs, vector<Edge> const & es, valarray<double> const * eweights) {
    assert(!eweights||eweights->size()==es.size());
    for(unsigned i=0;i<es.size();i++) {
        unsigned u=es[i].first, v=es[i].second;
        double w=eweights?(*eweights)[i]:1;
        vs[u].neighbours.push_back(&vs[v]);
        vs[u].nweights.push_back(w);
        vs[v].neighbours.push_back(&vs[u]);
        vs[v].nweights.push_back(w);
    }
}
void dijkstra(
        unsigned const s,
        unsigned const n,
        Node* vs,
        double* d)
{
    assert(s<n);
    for(unsigned i=0;i<n;i++) {
        vs[i].id=i;
        vs[i].d=DBL_MAX;
        vs[i].p=NULL;
    }
    vs[s].d=0;
    PairingHeap<Node*> Q(&compareNodes);
    for(unsigned i=0;i<n;i++) {
        vs[i].qnode = Q.insert(&vs[i]);
    }
    while(!Q.isEmpty()) {
        Node *u=Q.extractMin();
        d[u->id]=u->d;
        for(unsigned i=0;i<u->neighbours.size();i++) {
            Node *v=u->neighbours[i];
            double w=u->nweights[i];
            if(v->d>u->d+w) {
                v->p=u;
                v->d=u->d+w;
                Q.decreaseKey(v->qnode,v);
            }
        }
    }
}
void dijkstra(
        unsigned const s,
        unsigned const n,
        double* d,
        vector<Edge> const & es,
        valarray<double> const * eweights)
{
    assert(!eweights||es.size()==eweights->size());
    assert(s<n);
    Node vs[n];
    dijkstra_init(vs,es,eweights);
    dijkstra(s,n,vs,d);
}
void johnsons(
        unsigned const n,
        double** D, 
        vector<Edge> const & es,
        valarray<double> const * eweights) 
{
    Node vs[n];
    dijkstra_init(vs,es,eweights);
    for(unsigned k=0;k<n;k++) {
        dijkstra(k,n,vs,D[k]);
    }
}
}
