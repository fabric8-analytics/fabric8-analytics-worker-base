#!/usr/bin/sh -e

# yum search mercator

# Required by Dockerfile or any built-time script in hack/
BUILD="python36-pip python2-pip wget which"

# - We need postgresql-devel and python3-devel for psycopg2 listed in f8a_worker/requirements.txt
# - Installing python-requests is a work-around for a conflict which happens when you do
#   'pip install requests; yum install python-requests' (while it's OK if you swap those)
#   It can be removed once gofedlib runs on Python 3.
# python36-pycurl is needed by kombu
REQUIREMENTS_TXT='postgresql-devel python36-devel python36-requests python36-pycurl libxml2-devel libxslt-devel python-requests python patch'

# hack/run-db-migrations.sh
DB_MIGRATIONS='postgresql'

# f8a_worker/process.py
PROCESS_PY='git unzip zip tar file findutils npm'

# DigesterTask
DIGESTER='ssdeep'

# mercator-go
MERCATOR="mercator"

GOLANG_SUPPORT="golang"

# for pcp pmcd metrics collector
PCP="pcp"

# tagger uses python wrapper above libarchive so install it explicitly
TAGGER_DEP="libarchive"

# Install all RPM deps
yum install -y --setopt=tsflags=nodocs \
    ${BUILD} \
    ${REQUIREMENTS_TXT} \
    ${DB_MIGRATIONS} \
    ${PROCESS_PY} \
    ${DIGESTER} \
    ${MERCATOR} \
    ${GOLANG_SUPPORT} \
    ${PCP} \
    ${TAGGER_DEP}
