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

public class BoundaryConstraint : CompoundConstraint {
  private HandleRef swigCPtr;

  internal BoundaryConstraint(IntPtr cPtr, bool cMemoryOwn) : base(colaPINVOKE.BoundaryConstraintUpcast(cPtr), cMemoryOwn) {
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr(BoundaryConstraint obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }

  ~BoundaryConstraint() {
    Dispose();
  }

  public override void Dispose() {
    lock(this) {
      if(swigCPtr.Handle != IntPtr.Zero && swigCMemOwn) {
        swigCMemOwn = false;
        colaPINVOKE.delete_BoundaryConstraint(swigCPtr);
      }
      swigCPtr = new HandleRef(null, IntPtr.Zero);
      GC.SuppressFinalize(this);
      base.Dispose();
    }
  }

  public BoundaryConstraint(double pos) : this(colaPINVOKE.new_BoundaryConstraint(pos), true) {
  }

  public override void updatePosition() {
    colaPINVOKE.BoundaryConstraint_updatePosition(swigCPtr);
  }

  public override void generateVariables(SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vars) {
    colaPINVOKE.BoundaryConstraint_generateVariables(swigCPtr, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vars));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public override void generateSeparationConstraints(SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t vars, SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t cs) {
    colaPINVOKE.BoundaryConstraint_generateSeparationConstraints(swigCPtr, SWIGTYPE_p_std__vectorT_vpsc__Variable_p_t.getCPtr(vars), SWIGTYPE_p_std__vectorT_vpsc__Constraint_p_t.getCPtr(cs));
    if (colaPINVOKE.SWIGPendingException.Pending) throw colaPINVOKE.SWIGPendingException.Retrieve();
  }

  public double position {
    set {
      colaPINVOKE.BoundaryConstraint_position_set(swigCPtr, value);
    } 
    get {
      double ret = colaPINVOKE.BoundaryConstraint_position_get(swigCPtr);
      return ret;
    } 
  }

  public OffsetList leftOffsets {
    set {
      colaPINVOKE.BoundaryConstraint_leftOffsets_set(swigCPtr, OffsetList.getCPtr(value));
    } 
    get {
      IntPtr cPtr = colaPINVOKE.BoundaryConstraint_leftOffsets_get(swigCPtr);
      OffsetList ret = (cPtr == IntPtr.Zero) ? null : new OffsetList(cPtr, false);
      return ret;
    } 
  }

  public OffsetList rightOffsets {
    set {
      colaPINVOKE.BoundaryConstraint_rightOffsets_set(swigCPtr, OffsetList.getCPtr(value));
    } 
    get {
      IntPtr cPtr = colaPINVOKE.BoundaryConstraint_rightOffsets_get(swigCPtr);
      OffsetList ret = (cPtr == IntPtr.Zero) ? null : new OffsetList(cPtr, false);
      return ret;
    } 
  }

  public SWIGTYPE_p_vpsc__Variable variable {
    set {
      colaPINVOKE.BoundaryConstraint_variable_set(swigCPtr, SWIGTYPE_p_vpsc__Variable.getCPtr(value));
    } 
    get {
      IntPtr cPtr = colaPINVOKE.BoundaryConstraint_variable_get(swigCPtr);
      SWIGTYPE_p_vpsc__Variable ret = (cPtr == IntPtr.Zero) ? null : new SWIGTYPE_p_vpsc__Variable(cPtr, false);
      return ret;
    } 
  }

}

}
