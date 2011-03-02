
#from distutils.core import setup
from setuptools import setup #, find_packages
from distutils.extension import Extension
from Cython.Distutils import build_ext

sources = [
    'libavoid.pyx',
    'libavoid/connectionpin.cpp',
    'libavoid/connector.cpp',
    'libavoid/connend.cpp',
    'libavoid/geometry.cpp',
    'libavoid/geomtypes.cpp',
    'libavoid/graph.cpp',
    'libavoid/junction.cpp',
    'libavoid/makepath.cpp',
    'libavoid/obstacle.cpp',
    'libavoid/orthogonal.cpp',
    'libavoid/router.cpp',
    'libavoid/shape.cpp',
    'libavoid/timer.cpp',
    'libavoid/vertices.cpp',
    'libavoid/viscluster.cpp',
    'libavoid/visibility.cpp',
    'libavoid/vpsc.cpp',
    ]

setup(
    name='pylibavoid',
    version='0.1',

    author="Arjan J. Molenaar",
    author_email='gaphor@gmail.com',
    
    setup_requires = [
     'nose >= 0.10.4',
     'setuptools-git >= 0.3.4'
    ],

    test_suite = 'nose.collector',
    
    #cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension(
        "libavoid",
        sources,
        language="c++",
        include_dirs=['.'],
        #extra_link_args=[...],
        )],

    zip_safe=False,

    cmdclass = {'build_ext': build_ext}
)

# vim:sw=4:et:ai
