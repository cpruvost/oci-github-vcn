#!/bin/bash
set -e

TENANCY_OCPUS=1000

echo "::debug::Set the Output Variable"
echo "::set-output name=some_output::$TENANCY_OCPUS"
