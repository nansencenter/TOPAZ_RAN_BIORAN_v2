#!/bin/bash
#
# download satellite altimetry data
#

python cmems_ssh_loader.py 20210101 MY "s3a,s3b" True
