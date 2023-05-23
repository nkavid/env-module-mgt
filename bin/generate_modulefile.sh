#!/bin/bash

function generate_modulefile()
{
  OPT_PKG="/opt/pkg"
  OUTPUT_FILE="output_modulefile.tcl"

  function log()
  {
    echo -e "\x1B[1m-- $1:\x1B[0m $2"
  }

  function error()
  {
    echo -e "\x1B[31;1m-- $1:\x1B[0m $2"
  }

  function warning()
  {
    echo -e "\x1B[33;1m-- $1:\x1B[0m $2"
  }

  function success()
  {
    echo -e "\x1B[32;1m-- $1:\x1B[0m $2"
  }

  function usage()
  {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Description:"
    echo "  Generates a modulefile '${OUTPUT_FILE}'"
    echo "  in current working directory."
    echo "  '--<option>' without '=' sets Default"
    echo ""
    echo "Required arguments:"
    echo "  --package          Installed package name"
    echo "  --version          Installed package version"
    echo ""
    echo "Optional arguments:"
    echo "  --prefix           Installed package path"
    echo "                     (Default: /opt/pkg/<package>/<package>_<version>)"
    echo ""
    echo "Optional relative paths appended to prefix"
    echo "  --bindir=<path>         (Default: bin)"
    echo "  --libdir=<path>         (Default: lib)"
    echo "  --include=<path>        (Default: include)"
    echo "  --cmake=<path>          (Default: <libdir>/cmake)"
    echo "  --pkgconfig=<path>      (Default: <libdir>/pkgconfig)"
    echo "  --manpath=<path>        (Default: share/man)"
  }

  PACKAGE_PREFIX=""
  PACKAGE_NAME=""

  PACKAGE_BIN=""
  PACKAGE_LIB=""
  PACKAGE_INCLUDE=""

  PACKAGE_CMAKE=""
  PACKAGE_PKGCONFIG=""
  PACKAGE_MANPATH=""

  for opt do
    optval="${opt#*=}"
    case "$opt" in
      --prefix=*)
        PACKAGE_PREFIX=${optval}
      ;;
      --package=*)
        PACKAGE_NAME=${optval}
      ;;
      --version=*)
        PACKAGE_VERSION=${optval}
      ;;
      --bindir=*)
        PACKAGE_BIN=${optval}
      ;;
      --bindir)
        PACKAGE_BIN="bin"
      ;;
      --include=*)
        PACKAGE_INCLUDE=${optval}
      ;;
      --include)
        PACKAGE_INCLUDE="include"
      ;;
      --libdir=*)
        PACKAGE_LIB=${optval}
      ;;
      --libdir)
        PACKAGE_LIB="lib"
      ;;
      --cmake=*)
        PACKAGE_CMAKE=${optval}
      ;;
      --cmake)
        PACKAGE_CMAKE="\$libdir/cmake"
      ;;
      --pkgconfig=*)
        PACKAGE_PKGCONFIG=${optval}
      ;;
      --pkgconfig)
        PACKAGE_PKGCONFIG="\$libdir/pkgconfig"
      ;;
      --manpath=*)
        PACKAGE_MANPATH=${optval}
      ;;
      --manpath)
        PACKAGE_MANPATH="\$prefix/share/man"
      ;;
      --help)
        usage && exit 0
      ;;
    esac
  done

  if [[ -z "${PACKAGE_NAME}" ]]; then
    error "Missing package name" "set with '--package=<name>'"
    exit 1
  fi

  if [[ -z "${PACKAGE_VERSION}" ]]; then
    error "Missing module name" "set with '--version=<x.y.z_stuff>'"
    exit 1
  fi

  if [[ -z "${PACKAGE_PREFIX}" ]]; then
    PACKAGE_PREFIX="${OPT_PKG}/${PACKAGE_NAME}/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    log "Set default prefix path" "use --prefix=<path> if incorrect"
  fi

  if [[ ! -d "${OPT_PKG}/${PACKAGE_NAME}/modulefiles" ]]; then
    error "Missing modulefiles directory" "mkdir ${OPT_PKG}/${PACKAGE_NAME}/modulefiles"
    exit 1
  fi

  if [[ ! -d "${PACKAGE_PREFIX}" ]]; then
    error "Did not find package" "${PACKAGE_PREFIX}"
    log "Found these directories" "in ${OPT_PKG}/${PACKAGE_NAME}"
    ls -1Q "${OPT_PKG}/${PACKAGE_NAME}" -I "modulefiles"
    exit 1
  else
    success "Found installed package" "${PACKAGE_PREFIX}"
  fi

  cat > ${OUTPUT_FILE} << EOF
#%Module
# ${PACKAGE_NAME} modulefile

set prefix ${PACKAGE_PREFIX}

set bindir \$prefix/${PACKAGE_BIN}
set libdir \$prefix/${PACKAGE_LIB}
set incdir \$prefix/${PACKAGE_INCLUDE}

EOF

[[ -n ${PACKAGE_BIN} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path PATH            \$bindir
EOF

[[ -n ${PACKAGE_LIB} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path LIBRARY_PATH    \$libdir
prepend-path LD_LIBRARY_PATH \$libdir
EOF

[[ -n ${PACKAGE_INCLUDE} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path CPATH           \$incdir
EOF

cat << EOF >> ${OUTPUT_FILE}

EOF

[[ -n ${PACKAGE_CMAKE} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path CMAKE_PREFIX_PATH  ${PACKAGE_CMAKE}
EOF

[[ -n ${PACKAGE_PKGCONFIG} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path PKG_CONFIG_PATH    ${PACKAGE_PKGCONFIG}
EOF

[[ -n ${PACKAGE_MANPATH} ]] && cat << EOF >> ${OUTPUT_FILE}
prepend-path MANPATH            ${PACKAGE_MANPATH}
EOF

cat << EOF >> ${OUTPUT_FILE}

conflict ${PACKAGE_NAME}

EOF

  log "Dumping contents of:" "$(realpath ${OUTPUT_FILE})"
  echo "---------------------------------"
  cat ${OUTPUT_FILE}
  echo "---------------EOF---------------"

  NEW_MODULEFILE="${PACKAGE_NAME}/${PACKAGE_VERSION}"
  
  SPECIFIC_PACKAGE_MODULEFILES="${OPT_PKG}/${PACKAGE_NAME}/modulefiles/${NEW_MODULEFILE}"
  ALL_PACKAGES_MODULEFILES="${OPT_PKG}/modulefiles/${NEW_MODULEFILE}"
    
  [[ -f ${SPECIFIC_PACKAGE_MODULEFILES} ]] \
    && warning "Module file installed" "${SPECIFIC_PACKAGE_MODULEFILES}"
    
  [[ -f ${ALL_PACKAGES_MODULEFILES} ]] \
    && warning "Module file installed" "${ALL_PACKAGES_MODULEFILES}"

  success "Call one of the following commands if OK"
  echo "sudo mv ${OUTPUT_FILE} ${SPECIFIC_PACKAGE_MODULEFILES}"
  echo ""
  echo "sudo mv ${OUTPUT_FILE} ${ALL_PACKAGES_MODULEFILES}"
  echo ""

  log "$(basename "$0")" "Done"

}
