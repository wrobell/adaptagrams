/*
 * Some additional stuff required to make the Python bindings work. This stuff
 * is included from python-libavoid.cpp
 */
#include <Python.h>
#include <libvpsc/assertions.h>
#include <exception>

static void LibavoidExn2PyErr() {
  try {
    if (PyErr_Occurred())
      ; // let the latest Python exn pass through and ignore the current one
    else
      throw;
  } catch (const vpsc::CriticalFailure& exn) {
    PyErr_SetString(PyExc_RuntimeError, exn.what().c_str());
/******
  } catch (const std::invalid_argument& exn) {
    // Catch a handful of different errors here and turn them into the
    // equivalent Python errors.
    // Change invalid_argument to ValueError
    PyErr_SetString(PyExc_ValueError, exn.what());
  } catch (const std::out_of_range& exn) {
    // Change out_of_range to IndexError
    PyErr_SetString(PyExc_IndexError, exn.what());
  } catch (const std::exception& exn) {
    PyErr_SetString(PyExc_RuntimeError, exn.what());
 ******/
  }
  catch (...)
  {
    PyErr_SetString(PyExc_RuntimeError, "Unknown exception");
  }
}

