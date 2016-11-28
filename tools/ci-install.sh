#!/bin/bash

# Copyright © 2015-2016 Collabora Ltd.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail
set -x

NULL=
: "${ci_distro:=ubuntu}"
: "${ci_host:=native}"
: "${ci_suite:=trusty}"

if [ $(id -u) = 0 ]; then
    sudo=
else
    sudo=sudo
fi

case "$ci_distro" in
    (debian|ubuntu)
        # travis-ci has a sources list for Chrome which doesn't support i386
        : | $sudo tee /etc/apt/sources.list.d/google-chrome.list

        if [ "$ci_host" = mingw ]; then
            $sudo dpkg --add-architecture i386
        fi

        $sudo apt-get -qq -y update

        if [ "$ci_host" = mingw ]; then
            $sudo apt-get -qq -y install \
                binutils-mingw-w64-i686 \
                g++-mingw-w64-i686 \
                wine:i386 \
                ${NULL}
        fi

        $sudo apt-get -qq -y build-dep dbus

        $sudo apt-get -qq -y install \
            automake \
            autotools-dev \
            debhelper \
            dh-autoreconf \
            doxygen \
            dpkg-dev \
            gnome-desktop-testing \
            libapparmor-dev \
            libaudit-dev \
            libcap-ng-dev \
            libexpat-dev \
            libglib2.0-dev \
            libselinux1-dev \
            libx11-dev \
            python \
            python-dbus \
            python-gi \
            valgrind \
            xauth \
            xmlto \
            xsltproc \
            xvfb \
            ${NULL}

        case "$ci_suite" in
            (trusty|jessie)
                # Ubuntu 14.04's autoconf-archive is too old
                wget http://snapshot.debian.org/archive/debian/20160905T163745Z/pool/main/a/autoconf-archive/autoconf-archive_20160320-1_all.deb
                $sudo dpkg -i autoconf-archive_*_all.deb
                rm autoconf-archive_*_all.deb
                ;;
        esac
        ;;

    (*)
        echo "Don't know how to set up ${ci_distro}" >&2
        exit 1
        ;;
esac

# vim:set sw=4 sts=4 et:
