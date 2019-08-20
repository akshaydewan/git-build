# Copyright 2019 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM centos:7
RUN yum install -y rpm-build rpmdevtools readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel byacc nano which git gettext centos-release-scl
RUN yum groupinstall -y "Development Tools"
RUN yum install -y rh-ruby23
RUN scl enable rh-ruby23 bash
RUN cp /opt/rh/rh-ruby23/enable /etc/profile.d/rh-ruby23.sh; source /opt/rh/rh-ruby23/enable; gem install bundler
