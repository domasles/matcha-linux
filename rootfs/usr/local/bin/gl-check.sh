#!/bin/sh

GL=$(glxinfo 2>/dev/null | grep -m1 "OpenGL version string:")

case "$GL" in
    *"OpenGL ES"*) RE=0 ;;
    *" 4."[3-6]*) RE=1 ;;
    *) RE=0 ;;
esac

if [ "$RE" -eq 0 ]; then
    dbus-update-activation-environment LIBGL_ALWAYS_SOFTWARE=1
fi
