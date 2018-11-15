FROM registry.centos.org/centos/centos:7

ENV LANG=en_US.UTF-8 \
    M2_CACHE='/m2_repo/' \
    SCANCODE_PATH='/opt/scancode-toolkit/'


RUN mkdir -p ${M2_CACHE}

# https://copr.fedorainfracloud.org/coprs/msrb/mercator/
# https://copr.fedorainfracloud.org/coprs/fche/pcp/
COPY hack/_copr_msrb-mercator-epel-7.repo hack/_copr_fche_pcp.repo /etc/yum.repos.d/

# Install RPM dependencies
COPY hack/install_deps_rpm.sh /tmp/install_deps/
RUN yum install -y epel-release && \
    /tmp/install_deps/install_deps_rpm.sh && \
    yum clean all

# Work-arounds & hacks:
# 'pip install --upgrade wheel': http://stackoverflow.com/questions/14296531
RUN pip3 install --upgrade 'pip>=10.0.0' && \
    pip install --upgrade wheel && \
    pip3 install alembic psycopg2

# Install javascript deps
COPY hack/install_deps_npm.sh /tmp/install_deps/
RUN /tmp/install_deps/install_deps_npm.sh

# Install ScanCode-toolkit for license scan
COPY hack/install_scancode.sh /tmp/install_deps/
RUN /tmp/install_deps/install_scancode.sh

# Install gofedlib needed for Go support
RUN pip2 install --egg git+https://github.com/gofed/gofedlib.git@369a23443374dc4fdbe2aa8fed69348c706da36b

# Create & set pcp dirs
RUN mkdir -p /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp  && \
    chgrp -R root /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp && \
    chmod -R g+rwX /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp

# Not-yet-upstream-released patches
COPY hack/patches/* /tmp/install_deps/patches/
# Apply patches here to be able to patch selinon as well
RUN /tmp/install_deps/patches/apply_patches.sh

# Cache few Maven plugins and dependencies
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && \
    mvn -Dmaven.repo.local=${M2_CACHE} clean verify org.apache.maven.plugins:maven-help-plugin:3.1.0:effective-pom && \
    rm /tmp/pom.xml && \
    chown -R 999:999 ${M2_CACHE} && \
    find ${M2_CACHE} -exec chmod 1777 {} +

