#!/bin/sh

GL_VERSION=$(glxinfo 2>/dev/null | grep -oP 'OpenGL version string:\s+\K[0-9.]+' | tr -d '.')

if [ -z "$GL_VERSION" ] || [ "$GL_VERSION" -lt 430 ]; then
    dbus-update-activation-environment LIBGL_ALWAYS_SOFTWARE=1
fi

rm -f "$0"
