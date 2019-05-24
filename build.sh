#!/bin/bash

# Check that NetCDF variable is set
if [ -z "$NETCDF" ]; then
    echo "\$NETCDF variable not set"
    echo "Aborting build"
    exit 1
fi

# Compile SPEEDY and delete source files
echo 'Compiling SPEEDY'
if [ "$1" = "--profile" ]; then
    FoBiS.py build -mode profile
else
    FoBiS.py build
fi
