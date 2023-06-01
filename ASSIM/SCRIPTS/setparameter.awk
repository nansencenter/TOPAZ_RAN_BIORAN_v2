#!/bin/awk

# This script replaces the value of specified parameter in a parameter
# file with parameters in a forn of FORTRAN name list values
#
# The parameters entries are supposed to be in the following form:
#
# &<list name>
# [TAB] <parameter 1 name> = <parameter 1 value>
# ...
# [TAB] <parameter N name> = parameter N value>
# /
#
# For example:
#
# &moderation
# 	infl = 1.01
#	rfactor = 1.0
#	rfactor2 = 2.0
#	kfactor = 2.0
# /
#
# Note that the spaces around "=" are essential.
#
# Then to set parameter value for inflation one needs to run:
#
# <bash prompt>cat <prm file> | awk -f <this script>  -v PRM=<parameter name>
#  -v <VAL>=<parameter value>
#
# For example:
#
# >cat enkf.in | awk -f setparameter.awk -v PRM=infl -v VAL=1.02 > enkf.prm
# >cat enkf.in | awk -f setparameter.awk -v PRM=jmapfname -v VAL=\"jmap.txt\" > enkf.prm

{
    if (PRM == $1)
	print "\t" PRM " = " VAL;
    else
	print $0
}
