#!/bin/bash -e

# Plasma's build: prints the Ivy file that goes beside libmpv-<version>.aar on
# a release, so that Gradle fetches the AAR with GET requests alone. Without
# it, Gradle first asks whether the AAR exists with a HEAD request, and
# GitHub's file host has answered HEAD for this repository's assets with 401.
# Usage: ./ivy-xml.sh <version>

version=${1:?usage: ivy-xml.sh <version>}
cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ivy-module version="2.0">
  <info organisation="ca.gureet.plasma" module="libmpv" revision="$version" status="release"/>
  <configurations>
    <conf name="default"/>
  </configurations>
  <publications>
    <artifact name="libmpv" type="aar" ext="aar" conf="default"/>
  </publications>
</ivy-module>
EOF
