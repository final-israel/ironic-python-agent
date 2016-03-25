#!/bin/bash -xe
#
# From a base-trusty node, this should build a CoreOS IPA image
# suitable for use in testing or production.
#

BRANCH_PATH=${BRANCH_PATH:-master}

if [ -x "/usr/bin/apt-get" ]; then
    sudo -E apt-get update
    sudo -E apt-get install -y docker.io
elif [ -x "/usr/bin/yum" ]; then
    sudo -E yum install -y docker-io gpg
else
    echo "No supported package manager installed on system. Supported: apt, yum"
    exit 1
fi

imagebuild/coreos/build_coreos_image.sh

BUILD_DIR=imagebuild/coreos/UPLOAD
if [ "$BRANCH_PATH" != "master" ]; then
    # add the branch name
    mv $BUILD_DIR/coreos_production_pxe_image-oem.cpio.gz $BUILD_DIR/coreos_production_pxe_image-oem-$BRANCH_PATH.cpio.gz
    mv $BUILD_DIR/coreos_production_pxe.vmlinuz $BUILD_DIR/coreos_production_pxe-$BRANCH_PATH.vmlinuz
else
    # in the past, we published master without branch name
    # copy the files in this case such that both are published
    cp $BUILD_DIR/coreos_production_pxe_image-oem.cpio.gz $BUILD_DIR/coreos_production_pxe_image-oem-$BRANCH_PATH.cpio.gz
    cp $BUILD_DIR/coreos_production_pxe.vmlinuz $BUILD_DIR/coreos_production_pxe-$BRANCH_PATH.vmlinuz
fi

tar czf ipa-coreos-$BRANCH_PATH.tar.gz $BUILD_DIR/coreos_production_pxe_image-oem-$BRANCH_PATH.cpio.gz $BUILD_DIR/coreos_production_pxe-$BRANCH_PATH.vmlinuz
if [ "$BRANCH_PATH" = "master" ]; then
    # again, publish with and without the branch on master for historical reasons
    cp ipa-coreos-$BRANCH_PATH.tar.gz ipa-coreos.tar.gz
fi
