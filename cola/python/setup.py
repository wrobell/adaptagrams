
from distutils.core import setup
#from setuptools import setup #, find_packages
from distutils.extension import Extension
from Cython.Distutils import build_ext

sources = [
        'rectangle.pyx',
        'src/Rectangle.cpp'
]

setup(
#    name='libavoid',
#    version='0.1',
#
#    author="Arjan J. Molenaar",
#    author_email='gaphor@gmail.com',
#    
#    setup_requires = [
#     'nose >= 0.10.4',
#     'setuptools-git >= 0.3.4'
#    ],
#
#    test_suite = 'nose.collector',
    
    #cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension(
        "rectangle",                 # name of extension
        sources=sources,
        language="c++",              # this causes Cython to create C++ source
        #include_dirs=['.', '..'],          # usual stuff
        #extra_link_args=[...],       # if needed
        )],

#    zip_safe=False,

    cmdclass = {'build_ext': build_ext}
)

# vim:sw=4:et:ai
