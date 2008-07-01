/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 1.3.36
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

namespace org.adaptagrams.cola {

using System;
using System.Runtime.InteropServices;

public class cola {
  public static Dim conjugate(Dim d) {
    Dim ret = (Dim)colaPINVOKE.conjugate((int)d);
    return ret;
  }

  public static void generateXConstraints(RectPtrVector rs, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vars, SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t cs, bool useNeighbourLists) {
    colaPINVOKE.generateXConstraints(RectPtrVector.getCPtr(rs), SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vars), SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t.getCPtr(cs), useNeighbourLists);
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static void generateYConstraints(RectPtrVector rs, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vars, SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t cs) {
    colaPINVOKE.generateYConstraints(RectPtrVector.getCPtr(rs), SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vars), SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t.getCPtr(cs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static void removeoverlaps(RectPtrVector rs) {
    colaPINVOKE.removeoverlaps__SWIG_0(RectPtrVector.getCPtr(rs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static void removeoverlaps(RectPtrVector rs, SWIGTYPE_p_std__setT_unsigned_int_t arg1, bool thirdPass) {
    colaPINVOKE.removeoverlaps__SWIG_1(RectPtrVector.getCPtr(rs), SWIGTYPE_p_std__setT_unsigned_int_t.getCPtr(arg1), thirdPass);
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static void removeoverlaps(RectPtrVector rs, SWIGTYPE_p_std__setT_unsigned_int_t arg1) {
    colaPINVOKE.removeoverlaps__SWIG_2(RectPtrVector.getCPtr(rs), SWIGTYPE_p_std__setT_unsigned_int_t.getCPtr(arg1));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static TestConvergence defaultTest {
    get {
      IntPtr cPtr = colaPINVOKE.defaultTest_get();
      TestConvergence ret = (cPtr == IntPtr.Zero) ? null : new TestConvergence(cPtr, false);
      return ret;
    } 
  }

  public static Rectangle bounds(RectPtrVector rs) {
    Rectangle ret = new Rectangle(colaPINVOKE.bounds(RectPtrVector.getCPtr(rs)), true);
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
    return ret;
  }

  public static void removeClusterOverlapFast(RootCluster clusterHierarchy, RectPtrVector rs, ColaLocks locks) {
    colaPINVOKE.removeClusterOverlapFast(RootCluster.getCPtr(clusterHierarchy), RectPtrVector.getCPtr(rs), ColaLocks.getCPtr(locks));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static void generateVariablesAndConstraints(CompoundConstraintsVector ccs, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vars, SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t cs) {
    colaPINVOKE.generateVariablesAndConstraints(CompoundConstraintsVector.getCPtr(ccs), SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vars), SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t.getCPtr(cs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static Dim dim {
    set {
      colaPINVOKE.dim_set((int)value);
    } 
    get {
      Dim ret = (Dim)colaPINVOKE.dim_get();
      return ret;
    } 
  }

  public static void setNodeVariables(TopologyNodePtrVector ns, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vs) {
    colaPINVOKE.setNodeVariables(TopologyNodePtrVector.getCPtr(ns), SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public static double crossProduct(double x0, double y0, double x1, double y1, double x2, double y2) {
    double ret = colaPINVOKE.crossProduct(x0, y0, x1, y1, x2, y2);
    return ret;
  }

}

}
