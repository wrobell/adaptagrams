#include "commondefs.h"
// vim: set cindent 
// vim: ts=4 sw=4 et tw=0 wm=0
#include <float.h>
#include <cassert>
#include <iostream>
#include <libvpsc/pairing_heap.h>
using namespace std;
namespace shortest_paths {
// O(n^3) time dynamic programming approach.  Slow, but fool proof.  Use for testing.
template <typename T>
void floyd_warshall(
        unsigned const n,
        T** D, 
        vector<Edge> const & es,
        valarray<T> const * eweights) 
{
    assert(!eweights||eweights->size()==es.size());
    for(unsigned i=0;i<n;i++) {
        for(unsigned j=0;j<n;j++) {
            if(i==j) D[i][j]=0;
            else D[i][j]=numeric_limits<T>::max();
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
template <typename T>
void dijkstra_init(
        vector<Node<T> > & vs, 
        vector<Edge> const& es, 
        valarray<T> const* eweights) {
    assert(!eweights||eweights->size()==es.size());
#ifndef NDEBUG
    const unsigned n=vs.size();
#endif
    for(unsigned i=0;i<es.size();i++) {
        unsigned u=es[i].first, v=es[i].second;
        assert(u<n);
        assert(v<n);
        T w=eweights?(*eweights)[i]:1;
        vs[u].neighbours.push_back(&vs[v]);
        vs[u].nweights.push_back(w);
        vs[v].neighbours.push_back(&vs[u]);
        vs[v].nweights.push_back(w);
    }
}
template <typename T>
void dijkstra(
        unsigned const s,
        vector<Node<T> > & vs,
        T* d)
{
    const unsigned n=vs.size();
    assert(s<n);
    for(unsigned i=0;i<n;i++) {
        vs[i].id=i;
        vs[i].d=numeric_limits<T>::max();
        vs[i].p=NULL;
    }
    vs[s].d=0;
    PairingHeap<Node<T>*,CompareNodes<T> > Q;
    for(unsigned i=0;i<n;i++) {
        vs[i].qnode = Q.insert(&vs[i]);
    }
    while(!Q.isEmpty()) {
        Node<T> *u=Q.extractMin();
        d[u->id]=u->d;
        for(unsigned i=0;i<u->neighbours.size();i++) {
            Node<T> *v=u->neighbours[i];
            T w=u->nweights[i];
            if(u->d!=numeric_limits<T>::max()
               && v->d > u->d+w) {
                v->p=u;
                v->d=u->d+w;
                Q.decreaseKey(v->qnode,v);
            }
        }
    }
}
template <typename T>
void dijkstra(
        unsigned const s,
        unsigned const n,
        T* d,
        vector<Edge> const & es,
        valarray<T> const * eweights)
{
    assert(!eweights||es.size()==eweights->size());
    assert(s<n);
    vector<Node<T> > vs(n);
    dijkstra_init(vs,es,eweights);
    dijkstra(s,vs,d);
}
template <typename T>
void johnsons(
        unsigned const n,
        T** D, 
        vector<Edge> const & es,
        valarray<T> const * eweights) 
{
    vector<Node<T> > vs(n);
    dijkstra_init(vs,es,eweights);
    for(unsigned k=0;k<n;k++) {
        dijkstra(k,vs,D[k]);
    }
}
}
