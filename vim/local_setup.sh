#!/bin/bash
#
# Setup the vim ide on the local host machine
#
# We need to install some vim plugins
sqllint_version="v0.0.19"
shfmt_version="v3.3.1"
tflint_version="v0.31.0"
ale_version="v3.1.0"
coc_nvim_version="v0.0.80"
gruvbox_version="v3.0.1-rc.0"
rainbow_version="v3.3.1"
vim_airline_version="v0.11"
vim_commentary_version="master"
vim_fugitive_version="v3.3"
nerdtree_version="6.10.11"
vim_devicons_version="v0.11.0"
nerd_fonts_version="v2.1.0"
vim_highlightedyank_version="master"
preview_markdown_vim_version="master"
nodejs_version="v14.17.5"
terraform_lsp_version="0.0.12"
terraform_version="1.0.4"
terragrunt_version="v0.31.4"
vim_plugins="neoclide/coc.nvim morhetz/gruvbox luochen1990/rainbow vim-airline/vim-airline tpope/vim-commentary tpope/vim-fugitive dense-analysis/ale preservim/nerdtree ryanoasis/vim-devicons machakann/vim-highlightedyank skanehira/preview-markdown.vim"
this_dir=$(dirname $(realpath $0))

# Create the .local/bin folder where we will store all the binaries
mkdir -p "${HOME}/.local/bin"

function install_fonts_for_devicons() {
  cd /tmp/
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_fonts_version}/Hack.zip
  mkdir ${HOME}/.local/share/fonts
  unzip -o Hack.zip -d ${HOME}/.local/share/fonts/
  # Clear and regenerate Cache
  fc-cache -f -v
}
function update_path() {
  export PATH=${HOME}/.local/bin:${PATH}
  grep -s '\${HOME}/.local/bin' ${HOME}/.bashrc || echo "PATH=\${HOME}/.local/bin:\${PATH}" >>${HOME}/.bashrc
  export PATH=${HOME}/node_modules/.bin/:${PATH}
  grep -s '\${HOME}/node_modules/.bin/' ${HOME}/.bashrc || echo "PATH=\${HOME}/node_modules/.bin/:\${PATH}" >>${HOME}/.bashrc
  source ${HOME}/.bashrc
}

function install_terraform_lsp() {
  cd /tmp/
  curl -LO https://github.com/juliosueiras/terraform-lsp/releases/download/v${terraform_lsp_version}/terraform-lsp_${terraform_lsp_version}_linux_amd64.tar.gz
  tar zxvf terraform-lsp_${terraform_lsp_version}_linux_amd64.tar.gz
  mv terraform-lsp ${HOME}/.local/bin/
  chmod +x ${HOME}/.local/bin/terraform-lsp
}

function install_terraform() {
  cd /tmp/
  curl -LO https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
  unzip terraform_${terraform_version}_linux_amd64.zip
  mv terraform ${HOME}/.local/bin/
  chmod +x ${HOME}/.local/bin/terraform
}

function install_terragrunt() {
  cd /tmp/
  curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/${terragrunt_version}/terragrunt_linux_amd64
  mv terragrunt_linux_amd64 ${HOME}/.local/bin/terragrunt
  chmod +x ${HOME}/.local/bin/terragrunt
}

function install_nodejs() {
  current_node_version=$(node --version 2/dev/null)
  if [ "x$current_node_version" != "x${nodejs_version}" ]; then
    mkdir -p "${HOME}/.local/lib/nodejs"
    cd /tmp/
    curl -L https://nodejs.org/dist/${nodejs_version}/node-${nodejs_version}-linux-x64.tar.xz -o node-${nodejs_version}-linux-x64.tar.xz
    tar -xJvf node-${nodejs_version}-linux-x64.tar.xz -C ${HOME}/.local/lib/nodejs
    [ ! -L ${HOME}/.local/bin ] && ln -s ${HOME}/.local/lib/nodejs/node-${nodejs_version}-linux-x64/bin/node ${HOME}/.local/bin/node
    [ ! -L ${HOME}/.local/bin ] && ln -s ${HOME}/.local/lib/nodejs/node-${nodejs_version}-linux-x64/bin/npm ${HOME}/.local/bin/npm
    [ ! -L ${HOME}/.local/bin ] && ln -s ${HOME}/.local/lib/nodejs/node-${nodejs_version}-linux-x64/bin/npx ${HOME}/.local/bin/npx
  fi
}

function install_coc_extentions() {
  echo "Installing CocExtentions (For command completion for various languages)"
  mkdir -p ${HOME}/.config/coc/extensions
  cd ${HOME}/.config/coc/extensions
  [ ! -f package.json ] && echo '{"dependencies":{}}' >package.json
  npm install coc-snippets coc-prettier coc-json coc-yaml coc-sql coc-sh coc-python coc-phpls coc-json coc-docker --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
  #npm install swaglint prettier

  # Fix NPM Vulnerabilities
  npm audit fix
}

function install_vim_plugins() {
  # Install vim plugins
  mkdir -p ${HOME}/.vim/pack/plugins/start/
  cd ${HOME}/.vim/pack/plugins/start/
  for plugin in $vim_plugins; do
    plugin_name=$(echo $plugin | cut -d/ -f2)
    plugin_version_name=$(echo $plugin_name | sed 's/-/_/g;s/\./_/g;s/$/_version/')
    if [ ! -d $plugin_name ]; then
      git -c advice.detachedHead=false clone -b ${!plugin_version_name} https://github.com/${plugin}.git
    else
      cd $plugin_name
      git -c advice.detachedHead=false checkout ${!plugin_version_name}
      cd ..
    fi
  done
}

if [ ! -f /etc/lsb-release ]; then
  echo "Only Ubuntu is supported as of now"
else
  . /etc/lsb-release
  if [ $DISTRIB_ID != "Ubuntu" ]; then
    echo "OS NOT supported"
  else
    echo "Install basic packages"
    sudo apt install vim-nox git curl python3-pip
    install_nodejs
  fi
fi

if [ x$DISTRIB_ID != "xUbuntu" ]; then
  echo "Only Ubuntu is supported for additional linters and fixer"
fi

# Create a local directory for all binaries
mkdir -p ${HOME}/.local/bin/
if [ -f ${HOME}/.bashrc ]; then
  update_path
else
  touch ${HOME}/.bashrc
  update_path
fi
install_vim_plugins
install_coc_extentions

# Install Conqueror Of Code ( Code Completion)
mkdir -p ${HOME}/.config/coc/extensions
cd ${HOME}/.config/coc/extensions
[ ! -f package.json ] && echo '{"dependencies":{}}' >package.json

case $DISTRIB_ID in
Ubuntu)

  # Install linters & fixers for c
  sudo apt update
  sudo apt-get -y install git gcc ccls clang-tidy cppcheck clang-format

  # Install SQLLint for linting sql files
  curl -LO https://github.com/joereynolds/sql-lint/releases/download/${sqllint_version}/sql-lint-linux
  mv sql-lint-linux ${HOME}/.local/bin/sql-lint
  chmod +x ${HOME}/.local/bin/sql-lint
  pip3 install sqlformat

  # Bash linter
  sudo apt -y install shellcheck
  curl -LO https://github.com/mvdan/sh/releases/download/${shfmt_version}/shfmt_${shfmt_version}_linux_amd64
  mv shfmt_${shfmt_version}_linux_amd64 ${HOME}/.local/bin/shfmt
  chmod +x ${HOME}/.local/bin/shfmt

  # Setting up Python
  sudo apt -y install python3-pip
  pip3 install jedi flake8 black pylint

  # TFLint for terraform
  curl -LO https://github.com/terraform-linters/tflint/releases/download/${tflint_version}/tflint_linux_amd64.zip
  unzip tflint_linux_amd64.zip
  mv tflint ${HOME}/.local/bin/
  chmod +x ${HOME}/.local/bin/tflint

  # Supporting php linting
  sudo apt -y install php-codesniffer phpmd

  # Support Ansible & its linters
  pip3 install ansible ansible-lint yamllint

  # Install terraform-lsp
  install_terraform_lsp
  install_terraform
  install_terragrunt

  # Finally update vimrc and coc-settings.json
  cp ${this_dir}/coc-settings.json ${HOME}/.vim/coc-settings.json
  cp ${this_dir}/vimrc ${HOME}/.vim/

  # Setup the patched fonts for devicons
  install_fonts_for_devicons
  echo "Please Update your terminal (Konsole or gnome-terminal to use Hack NERD fonts to have a better stusline with icons)"
  echo "For Konsole : Settings => Edit Current Profile => Appearance => Font => Choose (Hack NERD Font)"

  # Install Markdown renderer
  curl -L https://github.com/MichaelMure/mdr/releases/download/${mdr_version}/mdr_linux_amd64 -o ${HOME}/.local/bin/mdr
  chmod +x ${HOME}/.local/bin/mdr

  ;;
*)
  echo "OS NOT supported for installing "
  ;;
esac
