
from distutils.core import setup
#from setuptools import setup #, find_packages
from distutils.extension import Extension
from Cython.Distutils import build_ext

sources = [
    'libavoid.pyx',
]

#examples = [
#    'test_multiconnact',
#    'test_example',
#]
#
#example_extensions = [Extension(
#    example,
#    sources=[example + '.pyx'],
#    language="c++",
#    include_dirs=['.', '..'],
#    #extra_link_args=[...],
#    library_dirs=['../libavoid/.libs'],
#    libraries=['avoid']
#    ) for example in examples]


setup(
    name='libavoid',
    version='0.1',

    author="Arjan J. Molenaar",
    author_email='gaphor@gmail.com',
    
#    setup_requires = [
#     'nose >= 0.10.4',
#     'setuptools-git >= 0.3.4'
#    ],
#
#    test_suite = 'nose.collector',
    
    ext_modules = [Extension(
        "libavoid",
        sources=sources,
        language="c++",
        include_dirs=['.', '..'],
        #extra_link_args=[...],
        library_dirs=['../libavoid/.libs'],
        libraries=['avoid']
        )], # + example_extensions,

#    zip_safe=False,

    cmdclass = {'build_ext': build_ext}
)

# vim:sw=4:et:ai
