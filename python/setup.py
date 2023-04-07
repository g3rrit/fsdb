from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

examples_extension = Extension(
    name="fsdb",
    sources=["fsdb.c", "bind.pyx"],
)
setup(
    name="fsdb",
    version="0.1",
    description="[FSDB] File System Database",
    long_description="[FSDB] File System Database",
    author="Gerrit Proessl",
    ext_modules=cythonize([examples_extension], language_level="3"),
    package_data={"fsdb": ["bind.pyx", "fsdb.c", "fsdb.h"]},
    include_package_data=True
)
