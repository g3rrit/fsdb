from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import shutil
import os

if not os.path.isfile("fsdb.c"):
    shutil.copy("../../src/fsdb.c", "fsdb.c")
if not os.path.isfile("fsdb.h"):
    shutil.copy("../../include/fsdb.h", "fsdb.h")

examples_extension = Extension(
    name="fsdb",
    sources=["fsdb.c", "bind.pyx"],
    #include_dirs=["../../include"]
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
