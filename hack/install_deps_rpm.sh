#!/usr/bin/sh -e

# Required by Dockerfile or any built-time script in hack/
BUILD="python34-pip python2-pip wget which"

# - We need postgresql-devel and python3-devel for psycopg2 listed in f8a_worker/requirements.txt
# - Installing python-requests is a work-around for a conflict which happens when you do
#   'pip install requests; yum install python-requests' (while it's OK if you swap those)
#   It can be removed once gofedlib runs on Python 3.
# python34-pycurl is needed by kombu
REQUIREMENTS_TXT='postgresql-devel python34-devel python34-requests python34-pycurl libxml2-devel libxslt-devel python-requests python patch'

# hack/run-db-migrations.sh
DB_MIGRATIONS='postgresql'

# f8a_worker/process.py
PROCESS_PY='git unzip zip tar file findutils npm'

# DigesterTask
DIGESTER='ssdeep'

# mercator-go
MERCATOR="mercator-1-32.el7.x86_64"

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

