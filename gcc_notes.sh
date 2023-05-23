git tag -n0 --points-at | sed "s/releases\///g" || exit "gcc version string error"

PACKAGE_INSTALLATION_PATH=/opt/pkg

GCC_VERSION=$(git tag -n0 --points-at | sed "s/releases\/gcc-//g")
../configure --disable-multilib \
  --quiet \
  --prefix="${PACKAGE_INSTALLATION_PATH}/gcc/gcc_${GCC_VERSION}"
  
make -s -j8 && echo -e "\033[32;1m-- DONE BUILDING '${GCC_VERSION}'\033[0m"

GCC_VERSION=$(cd gcc && git tag -n0 --points-at | sed -e "s/releases\/gcc-//g")
generate-modulefile \
--package=gcc \
--version=${GCC_VERSION} \
--bindir \
--libdir=lib64 \
--include=include/c++/${GCC_VERSION} \
--manpath


