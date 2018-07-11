#!/bin/bash -ex

REGISTRY="push.registry.devshift.net"

load_jenkins_vars() {
    if [ -e "jenkins-env.json" ]; then
        eval "$(./env-toolkit load -f jenkins-env.json \
                DEVSHIFT_TAG_LEN \
                QUAY_USERNAME \
                QUAY_PASSWORD \
                JENKINS_URL \
                GIT_BRANCH \
                GIT_COMMIT \
                BUILD_NUMBER \
                ghprbSourceBranch \
                ghprbActualCommit \
                BUILD_URL \
                ghprbPullId)"
    fi
}

prep() {
    yum -y update
    yum -y install docker git
    systemctl start docker
}

build_image() {
    make docker-build
}

tag_push() {
    local target=$1
    local source=$2
    docker tag ${source} ${target}
    docker push ${target}
}

docker_login() {
    if [ -n "${QUAY_USERNAME}" -a -n "${QUAY_PASSWORD}" ]; then
        docker login -u ${QUAY_USERNAME} -p ${QUAY_PASSWORD} ${REGISTRY}
    else
        echo "Could not login, missing credentials for the registry"
        exit 1
    fi
}

push_image() {
    local image_name
    local image_repository
    local short_commit

    image_name=$(make get-image-name)
    image_repository=$(make get-image-repository)
    short_commit=$(git rev-parse --short=$DEVSHIFT_TAG_LEN HEAD)

    if [ -n "${ghprbPullId}" ]; then
        # PR build
        pr_id="SNAPSHOT-PR-${ghprbPullId}"
        tag_push ${image_name}:${pr_id} ${image_name}
        tag_push ${image_name}:${pr_id}-${short_commit} ${image_name}
    else
        # master branch build
        tag_push ${image_name}:latest ${image_name}
        tag_push ${image_name}:${short_commit} ${image_name}
    fi

    echo 'CICO: Image pushed, ready to update deployed app'
}

load_jenkins_vars
prep
