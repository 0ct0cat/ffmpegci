#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Bilibili
# Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e
TOOLS=tools

git --version

echo "== pull ffmpeg base =="
. base.sh
sh $TOOLS/pull-repo-base.sh $FFMPEG_UPSTREAM $FFMPEG_LOCAL_REPO

function pull_fork()
{
    echo "== pull ffmpeg fork $1 =="
    sh $TOOLS/pull-repo-ref.sh $FFMPEG_FORK android/ffmpeg-$1 ${FFMPEG_LOCAL_REPO}
    cd android/ffmpeg-$1
    if ! git show-ref -q --heads android; then
        git checkout ${FFMPEG_COMMIT} -b android
    fi
    cd -
}

echo "== pull ffmpeg dep =="
echo "== dumy for pull ffmpeg dep =="
echo "== there is maybe different deps of ffmpeg on platform =="

pull_fork "armv7a"
pull_fork "arm64"
pull_fork "x86_64"
