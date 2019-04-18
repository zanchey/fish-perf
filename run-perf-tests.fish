#! /usr/bin/fish
# run-perf-tests
# Copyright 2019 David Adam <zanchey@ucc.gu.uwa.edu.au>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

#set PROGNAME (status current-command)
set PROGNAME fish-perf-tests
# Set up this with `git clone https://github.com/fish-shell/fish-shell.git`
set -l FISH_SRCDIR /home/fishperf/src/fish-shell
# Set up this with `cmake -G Ninja $FISH_SRCDIR`
set -l BUILD_AREA /home/fishperf/build

###################
# Set up

umask 022

function fail
    echo "$PROGNAME: $argv[1] failed."
    exit 1
end

# check whether we have anything to do

cd $FISH_SRCDIR

git fetch --quiet origin; or fail "Git fetch"

set EXISTING_SHA (git rev-parse --short master)
set UPSTREAM_SHA (git rev-parse --short origin/master)

if test "$argv[1]" = "--force"
    set EXISTING_SHA force
end
if [ "$EXISTING_SHA" = "$UPSTREAM_SHA" ]
    exit 0
end

# update to the latest git tree

git clean --quiet --force -x
git checkout --quiet --force master; or fail "Git checkout"
git merge --ff-only --quiet origin/master; or fail "Git merge"
git clean --quiet --force -x

# build

cd $BUILD_AREA
ninja -j3 fish >/dev/null; or fail "Build"

# benchmark

set -x NINJA_STATUS NOPRINT
ninja benchmark 2>&1 | string match --invert --regex '^NOPRINT' | python3 upload.py UPSTREAM_SHA EXISTING_SHA
