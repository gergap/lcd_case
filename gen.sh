#!/bin/bash
parts="top bottom"
for part in $parts; do
    echo "Generating $part.stl..."
    openscad -o $part.stl $part.scad
done

