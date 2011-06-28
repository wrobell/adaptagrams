"""
libavoid - Fast, Incremental, Object-avoiding Line Router
"""

__long_doc__ = """
Libavoid is a cross-platform C++ library providing fast,
object-avoiding connector routing for use in interactive
diagram editors.
"""

from distutils.core import setup
from distutils.extension import Extension

# Fallback, in case Cython is not installed.
try:
    from Cython.Distutils import build_ext
    extra_args = { 'cmdclass': {'build_ext': build_ext} }
    python_sources = [
        'libavoid/python-libavoid.pyx',
    ]
except ImportError:
    extra_args = {}
    python_sources = [
        'libavoid/python-libavoid.cpp',
    ]


sources = python_sources + [
    'libavoid/connectionpin.cpp',
    'libavoid/connector.cpp',
    'libavoid/connend.cpp',
    'libavoid/geometry.cpp',
    'libavoid/geomtypes.cpp',
    'libavoid/graph.cpp',
    'libavoid/hyperedge.cpp',
    'libavoid/hyperedgetree.cpp',
    'libavoid/junction.cpp',
    'libavoid/makepath.cpp',
    'libavoid/mtst.cpp',
    'libavoid/obstacle.cpp',
    'libavoid/orthogonal.cpp',
    'libavoid/router.cpp',
    'libavoid/shape.cpp',
    'libavoid/timer.cpp',
    'libavoid/vertices.cpp',
    'libavoid/viscluster.cpp',
    'libavoid/visibility.cpp',
    'libavoid/vpsc.cpp'
]

setup(
    name='pylibavoid',
    version='0.1',
    description=__doc__,
    long_description=__long_doc__,
    url='http://github.com/amolenaar/adaptagrams/tree/cython',
    
    author="Tim Dwyer, Michael Wybrow, Arjan Molenaar (Python bindings)",
    author_email='gaphor@gmail.com',
    
    classifiers = [
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX',
        'Programming Language :: Python',
        'Programming Language :: C++',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],

    ext_modules=[Extension(
        "libavoid",
        sources=sources,
        language="c++",
        include_dirs=['.'],
        define_macros=[("USE_ASSERT_EXCEPTIONS", None)],
        undef_macros=["NDEBUG"]
        )],

    **extra_args
)

# vim:sw=4:et:ai
