#!/bin/bash
##############################
# Creates dirs, links files
##############################

export GREEN="\033[1;32m"
export RED="\033[1;31m"
export YELLOW="\033[1;33m"
export CLEAR="\033[0m"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

function start_installation(){
    echo -e ${GREEN}"Installing $1 config..."${CLEAR}
}

function finish_installation(){
    echo -e ${GREEN}"Done $1 config."${CLEAR}
}

function test_and_update_file(){
    local program="$1"
    local cfg_file="$2"
    local src_file="$3"
    start_installation ${program}
    if [[ -f "${cfg_file}" ]]; then
        echo -e ${YELLOW}"Diff between \"${src_file}\" \"${cfg_file}\"..."${CLEAR}
        diff "${src_file}" "${cfg_file}"
        read -p "Override ${cfg_file}? [y/N]? " confirm
        if [[ $confirm == [Yy] ]]; then
            cp -f "${src_file}" "${cfg_file}"
        fi
    else
        cp "${src_file}" "${cfg_file}"
    fi
    finish_installation ${program}
}

function test_and_update_dir(){
    local program="$1"
    local cfg_dir="$2"
    local src_dir="$3"
    start_installation ${program}
    if [[ ! -d "${cfg_dir}" ]]; then
        mkdir -p "${cfg_dir}"
    fi
    read -p "Sync ${cfg_dir} from code? [y/N]? " confirm
    if [[ $confirm == [Yy] ]]; then
        rsync -avz -h --update "${src_dir}/" "${cfg_dir}/"
    fi
    finish_installation ${program}
}

echo -e ${GREEN}"This script installs configurations from \`configs\` dir..."${CLEAR}

# Copy VIM settings
test_and_update_file VIM "${HOME}/.vimrc" "${SCRIPT_DIR}/configs/.vimrc"

# Copy ZSH settings
test_and_update_file ZSH "${HOME}/.zshrc" "${SCRIPT_DIR}/configs/.zshrc"

# Copy TMUX settings
test_and_update_file TMUX "${HOME}/.tmux.conf" "${SCRIPT_DIR}/configs/.tmux.conf"
echo -e ${YELLOW}"In order to reload TMUX server, run \`tmux source-file ~/.tmux.conf\`, then install plugins with prefix + I "${CLEAR}

# Copy K9S settings
echo -e ${YELLOW}"Make sure to put the following to your shell profile or run:"${CLEAR}
echo -e "echo \"export K9S_CONFIG_DIR=${HOME}/k9s\" >> ~/.zshrc\n"
test_and_update_dir K9S "${HOME}/k9s" "${SCRIPT_DIR}/configs/k9s"

