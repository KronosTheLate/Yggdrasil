using BinaryBuilder, Pkg

name = "Octave"
version = v"9.2.0"

# Collection of sources required to build Octave
sources = [
   ArchiveSource("https://ftpmirror.gnu.org/octave/octave-$(version).tar.gz",
                  "0636554b05996997e431caad4422c00386d2d7c68900472700fecf5ffeb7c991"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/octave*

if [[ "${target}" == *-mingw* ]]; then
    LBT=blastrampoline-5
else
    LBT=blastrampoline
fi

# Base configure flags
FLAGS=(
    --prefix="$prefix"
    --build=${MACHTYPE}
    --host="${target}"
    --enable-shared
    --disable-static
    --with-blas="-L${libdir} -l${LBT}"
    --with-lapack="-L${libdir} -l${LBT}"
)

./configure "${FLAGS[@]}"
make -j${nproc} 
make install
"""

# build on all supported platforms
platforms = supported_platforms()
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    ExecutableProduct("octave", :octave),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("CompilerSupportLibraries_jll"),
    Dependency(PackageSpec(name="libblastrampoline_jll", uuid="8e850b90-86db-534c-a0d3-1478176c7d93"), compat="5.4.0"),
    Dependency("PCRE2_jll"),
    Dependency("Readline_jll"),
]

# Build the tarballs.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", clang_use_lld=false, preferred_gcc_version=v"9")
