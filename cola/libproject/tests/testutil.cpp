/**
 * \file testutil.cpp
 * utilities for testing libproject
 */
#include <cassert>
#include <cmath>
#include <algorithm>
#include <libproject/project.h>
#include <libproject/util.h>
#include "testutil.h"
#include "quadprogpp/QuadProg++.hh"

using namespace project;
using namespace std;

/**
 * Solve a project problem using a conventional quadratic programming solver.
 * We use Luca Di Gaspero's GPLed QuadProg++ program 
 * http://www.diegm.uniud.it/digaspero/
 *
 * The problem is converted to the form:
 *
 * \f$\min_x \frac{1}{2} x^T G x + g^T x \f$ 
 * subject to \f$C^T x + c \ge 0 \f$
 *
 * @param vs variables
 * @param cs constraints
 * @param result the solution vector
 */
void qps(Variables &vs, Constraints &cs, vector<double> &result) {
    const unsigned n=vs.size();
    assert(n<=MATRIX_DIM);
    double G[MATRIX_DIM][MATRIX_DIM],
           g[MATRIX_DIM];
    VMap vmap;
    for(unsigned i=0;i<n;i++) {
        vmap[vs[i]]=i;
        g[i]=-2.0*vs[i]->d;
        for(unsigned j=0;j<n;j++) {
            G[i][j]=i==j?2:0;
        }
    }
    const unsigned m=cs.size();
    assert(m<=MATRIX_DIM);
    double C[MATRIX_DIM][MATRIX_DIM],
           c[MATRIX_DIM];
    for(unsigned i=0;i<n;i++) {
        fill(C[i],C[i]+m,0);
    }
    for(unsigned i=0;i<m;i++) {
        const unsigned l=vmap[cs[i]->l],
                       r=vmap[cs[i]->r];
        C[l][i]=-1;
        C[r][i]=1;
        c[i]=-cs[i]->g;
    }
    double x[MATRIX_DIM];
    solve_quadprog(G, g, n, NULL, NULL, 0, C, c, m, x);
    result.resize(n);
    copy(x,x+n,result.begin());
}

/**
 * Checks that each constraint is satisfied.
 * @return false if unsatisfied constraint found
 */
bool feasible(Constraints &cs) {
    for(Constraints::iterator i=cs.begin();i!=cs.end();++i) {
        Constraint* c=*i;
        double slack = c->r->x - c->l->x - c->g;
        if (slack < -epsilon) {
            printf("Unsatisfiable constraint: slack = %f\n",slack);    
            return false;
        }
    }
    return true;
}
/**
 * Print out the problem instance (as code that can easily be pasted into
 * a test case)
 */
void printProblem(Variables &vs, 
        vector<double> &XI, 
        Constraints &cs, 
        VMap &vmap) 
{
    printf("problem instance:\n");
    printf("//------ snip -----------------\n");
    printf("const char* testname(Variables& vs, Constraints &cs) {\n");
    vector<double> x;
    qps(vs,cs,x);
    for(unsigned i=0;i<vs.size();i++) {
        char *match="==";
        if(!approxEquals(vs[i]->x,x[i])) {
            match="!=";
        }
        printf("vs.push_back(new Variable(%f,%f));//soln=%f %s rslt=%f\n",
                XI[i],vs[i]->d,x[i],match,vs[i]->x);
    }
    for(Constraints::iterator i=cs.begin();i!=cs.end();++i) {
        Constraint* c=*i;
        unsigned l=vmap[c->l], r=vmap[c->r];
        printf("cs.push_back(new Constraint(vs[%d],vs[%d],%f));\n", l,r,c->g);
    }
    printf("return __ASSERT_FUNCTION;\n}\n");
    printf("//------ end snip ------------\n");
}
/**
 * get random number in the range [0,max]
 */
double getRand(const double max) {
    return (double)max*rand()/(RAND_MAX);
}
/**
 * Check approximate equality of two doubles.
 * float comparisons (i.e. \f$a=b\$f) in our tests are actually \$f|a-b|<epsilon\$f.
 * @return true if the above condition is met
 */
bool approxEquals(double a, double b) {
    return fabs(a-b)<epsilon;
}
/**
 * Attempt to use libproject to solve a given projection problem instance.
 * @param t pointer to a function that will populate a list of variables and a list
 * of constraints.
 */
void test(const char* (*t)(Variables&, Constraints&), bool silentPass) {
    Variables vs;
    Constraints cs;

    // call given function to generate the problem instance
    const char *tn=t(vs,cs);

    // extract the test function name
    unsigned l=strlen(tn)-12-44;
    char testName[l+1];
    strncpy(testName,tn+12,l);
    testName[l]=0;
    
    // store initial positions
    vector<double> XI(vs.size());
    VMap vmap;
    for(unsigned i=0;i<vs.size();i++) {
        XI[i]=vs[i]->x;
        vmap[vs[i]]=i;
    }

    // assert initial solution is feasible:
    assert(feasible(cs));

    // run standard qpsolver
    vector<double> qpresult;
    qps(vs,cs,qpresult);

    try {
        // run our solver
        Project f(vs,cs);
        f.solve();

        // assert final solution is feasible:
        if(!feasible(cs)) {
            throw "infeasible solution!";
        }
        // assert solution matches solution from standard QP solver
        for(unsigned i=0;i<vs.size();i++) {
            if(!approxEquals(vs[i]->x,qpresult[i])) {
                throw "incorrect solution!";
            }
        }
        if(!silentPass) {
            printf("PASS: %s\n",testName);
        }
    } catch(CriticalFailure &f) {
        f.print();
        printProblem(vs,XI,cs,vmap);
        fprintf(stderr,"FAIL: %s\n",testName);
        exit(1);
    }
    for_each(vs.begin(),vs.end(),delete_object());
    for_each(cs.begin(),cs.end(),delete_object());
}

/*
 * vim: set cindent 
 * vim: ts=4 sw=4 et tw=0 wm=0
 */
