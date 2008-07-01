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

public class Edge : IDisposable {
  private HandleRef swigCPtr;
  protected bool swigCMemOwn;

  internal Edge(IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr(Edge obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }

  ~Edge() {
    Dispose();
  }

  public virtual void Dispose() {
    lock(this) {
      if(swigCPtr.Handle != IntPtr.Zero && swigCMemOwn) {
        swigCMemOwn = false;
        colaPINVOKE.delete_Edge(swigCPtr);
      }
      swigCPtr = new HandleRef(null, IntPtr.Zero);
      GC.SuppressFinalize(this);
    }
  }

  public uint id {
    set {
      colaPINVOKE.Edge_id_set(swigCPtr, value);
    } 
    get {
      uint ret = colaPINVOKE.Edge_id_get(swigCPtr);
      return ret;
    } 
  }

  public double idealLength {
    set {
      colaPINVOKE.Edge_idealLength_set(swigCPtr, value);
    } 
    get {
      double ret = colaPINVOKE.Edge_idealLength_get(swigCPtr);
      return ret;
    } 
  }

  public uint nSegments {
    set {
      colaPINVOKE.Edge_nSegments_set(swigCPtr, value);
    } 
    get {
      uint ret = colaPINVOKE.Edge_nSegments_get(swigCPtr);
      return ret;
    } 
  }

  public Edge(uint id, double idealLength, TopologyEdgePointPtrVector vs) : this(colaPINVOKE.new_Edge(id, idealLength, TopologyEdgePointPtrVector.getCPtr(vs)), true) {
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public double pathLength() {
    double ret = colaPINVOKE.Edge_pathLength(swigCPtr);
    return ret;
  }

  public void getPath(TopologyEdgePointConstPtrVector vs) {
    colaPINVOKE.Edge_getPath(swigCPtr, TopologyEdgePointConstPtrVector.getCPtr(vs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public bool assertConvexBends() {
    bool ret = colaPINVOKE.Edge_assertConvexBends(swigCPtr);
    return ret;
  }

  public bool cycle() {
    bool ret = colaPINVOKE.Edge_cycle(swigCPtr);
    return ret;
  }

}

}
