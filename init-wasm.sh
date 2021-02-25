set -e
TOOLS=tools

git --version

# export ffmpeg env
. base.sh
# pull ffmpeg repo
echo "== pull ffmpeg base =="
sh $TOOLS/pull-repo-base.sh $FFMPEG_UPSTREAM $FFMPEG_LOCAL_REPO

# export emsdk env
EMSDK_UPSTREAM="https://github.com/emscripten-core/emsdk.git"
EMSDK_FORK="https://github.com/emscripten-core/emsdk.git"
EMSDK_LOCAL_REPO="wasm/tools/emsdk"
# pull emsdk repo
echo "== pull emsdk base =="
sh $TOOLS/pull-repo-base.sh $EMSDK_UPSTREAM $EMSDK_LOCAL_REPO

function pull_fork()
{
    echo "== pull ffmpeg wasm fork =="
    sh $TOOLS/pull-repo-ref.sh $FFMPEG_FORK wasm/ffmpeg-wasm $FFMPEG_LOCAL_REPO
    cd wasm/ffmpeg-wasm
    if ! git show-ref -q --heads wasm; then
        git checkout ${FFMPEG_COMMIT} -b wasm
    fi
    cd -
}

function init_emsdk()
{
    echo "== init emsdk =="
    sh $TOOLS/pull-repo-ref.sh $EMSDK_FORK $EMSDK_LOCAL_REPO $EMSDK_LOCAL_REPO

    cd wasm/tools/emsdk
    # Download and install the latest SDK tools.
    ./emsdk install latest
    # Make the "latest" SDK "active" for the current user. (writes .emscripten file)
    ./emsdk activate latest
    # Activate PATH and other environment variables in the current terminal
    source ./emsdk_env.sh
    cd -
}

pull_fork
init_emsdk
