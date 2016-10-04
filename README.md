[![Build Status](https://snap-ci.com/snap-ci/git-build/branch/master/build_image)](https://snap-ci.com/snap-ci/git-build/branch/master)

This repo contains scripts needed to build deb and rpms for various versions of git. To report an issue, [please contact the Snap.ci support team.](https://snap-ci.com/contact-us)

# CentOS/RHEL

<pre>
$ yum install -y rpm-build rpmdevtools readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel byacc
$ bundle install --path .bundle
</pre>

# Ubuntu

<pre>
$ apt-get install build-essentials dpkg-dev
$ apt-get install gettext
$ bundle install --path .bundle
</pre>

# How to build one of the packages

<pre>
$ rake
</pre>
