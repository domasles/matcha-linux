#!/bin/sh

GL_VERSION=$(glxinfo 2>/dev/null | grep -m1 "OpenGL version string:" | awk '{print substr($4,1,3)}' | tr -d '.')

if [ -z "$GL_VERSION" ] || [ "$GL_VERSION" -lt 43 ]; then
    dbus-update-activation-environment LIBGL_ALWAYS_SOFTWARE=1
fi

rm -f "$0"
