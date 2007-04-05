#include "commondefs.h"
// vim: set cindent 
// vim: ts=4 sw=4 et tw=0 wm=0
#include "shortest_paths.h"
#include <float.h>
#include <cassert>
#include <iostream>
#include <libvpsc/pairing_heap.h>
using namespace std;
namespace shortest_paths {
// O(n^3) time dynamic programming approach.  Slow, but fool proof.  Use for testing.
void floyd_warshall(
        unsigned const n,
        double** D, 
        vector<Edge> const & es,
        valarray<double> const * eweights) 
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
void dijkstra_init(
        vector<Node> & vs, 
        vector<Edge> const& es, 
        valarray<double> const* eweights) {
    assert(!eweights||eweights->size()==es.size());
#ifndef NDEBUG
    const unsigned n=vs.size();
#endif
    for(unsigned i=0;i<es.size();i++) {
        unsigned u=es[i].first, v=es[i].second;
        assert(u<n);
        assert(v<n);
        double w=eweights?(*eweights)[i]:1;
        vs[u].neighbours.push_back(&vs[v]);
        vs[u].nweights.push_back(w);
        vs[v].neighbours.push_back(&vs[u]);
        vs[v].nweights.push_back(w);
    }
}
void dijkstra(
        unsigned const s,
        vector<Node> & vs,
        double* d)
{
    const unsigned n=vs.size();
    assert(s<n);
    for(unsigned i=0;i<n;i++) {
        vs[i].id=i;
        vs[i].d=DBL_MAX;
        vs[i].p=NULL;
    }
    vs[s].d=0;
    PairingHeap<Node*,CompareNodes> Q;
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
    vector<Node> vs(n);
    dijkstra_init(vs,es,eweights);
    dijkstra(s,vs,d);
}
void johnsons(
        unsigned const n,
        double** D, 
        vector<Edge> const & es,
        valarray<double> const * eweights) 
{
    vector<Node> vs(n);
    dijkstra_init(vs,es,eweights);
    for(unsigned k=0;k<n;k++) {
        dijkstra(k,vs,D[k]);
    }
}
}
