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
    echo -e "Done with $1."${CLEAR}
}

function test_and_update_file(){
    local program="$1"
    local cfg_file="$2"
    local src_file="$3"
    start_installation ${program}
    if [[ -f "${cfg_file}" ]]; then
        if diff -q "${src_file}" "${cfg_file}" >/dev/null; then
            echo "Already up to date."
            return
        fi
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

echo -e "Checking if fzf is present..."
if ! which fzf 1>/dev/null 2>&1; then
    echo -e "${YELLOW}fzf is NOT present${CLEAR}, install it with homebrew or follow these steps for linux:"
    echo "curl -L -o /tmp/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_amd64.tar.gz"
    echo "sudo tar -C /usr/local/bin -xf /tmp/fzf.tar.gz && sudo chmod +x /usr/local/bin/fzf && rm /tmp/fzf.tar.gz"
    sleep 1
fi

echo -e "Checking if direnv is present..."
if ! which direnv 1>/dev/null 2>&1; then
    echo -e "${YELLOW}direnv is NOT present${CLEAR}, install it with homebrew or follow these steps for linux:"
    echo "curl -sfL https://direnv.net/install.sh | bash"
    echo "Direnv below 2.37 has issues with Python deprecations, so a deb package will not work unless it's Ubuntu 26."
    sleep 1
fi

echo -e "Checking if uv is present..."
if ! which uv 1>/dev/null 2>&1; then
    echo -e "${YELLOW}uv is NOT present${CLEAR}, install it with homebrew or follow these steps for linux:"
    echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
    sleep 1
fi

# Copy VIM settings
test_and_update_file VIM "${HOME}/.vimrc" "${SCRIPT_DIR}/configs/.vimrc"

# Copy DIRCOLORS settings
test_and_update_dir DIRCOLORS "${HOME}/.dircolors" "${SCRIPT_DIR}/configs/dircolors"

# Copy ZSH settings
test_and_update_file ZSH "${HOME}/.zshrc" "${SCRIPT_DIR}/configs/.zshrc"
echo -e ${YELLOW}"In order to reload ZSH, run \`source ~/.zshrc\`"${CLEAR}

# Copy TMUX settings
test_and_update_file TMUX "${HOME}/.tmux.conf" "${SCRIPT_DIR}/configs/.tmux.conf"
test_and_update_dir TMUX-PLUGINS "${HOME}/.tmux" "${SCRIPT_DIR}/configs/tmux"
echo -e ${YELLOW}"In order to reload TMUX server, run \`tmux source-file ~/.tmux.conf\`, then install plugins with prefix + I "${CLEAR}

# Copy K9S settings
echo -e ${YELLOW}"Make sure to put the following to your shell profile or run:"${CLEAR}
echo -e "echo \"export K9S_CONFIG_DIR=${HOME}/k9s\" >> ~/.zshrc\n"
test_and_update_dir K9S "${HOME}/k9s" "${SCRIPT_DIR}/configs/k9s"

