FROM debian:bullseye as build
LABEL name="vim-devops" \
      version="0.1" \
      maintainer="Rajnesh Kumar Siwal"

# Set Version for the Plugins
ARG DEBIAN_FRONTEND=noninteractive
ARG vim_version="v8.2.3354"
ARG sqllint_version="v0.0.19"
ARG shfmt_version="v3.3.1"
ARG tflint_version="v0.31.0"
ARG sqllint_version="v0.0.19"
ARG shfmt_version="v3.3.1"
ARG tflint_version="v0.31.0"
ARG ale_version="v3.1.0"
ARG coc_nvim_version="release"
ARG gruvbox_version="v3.0.1-rc.0"
ARG rainbow_version="v3.3.1"
ARG vim_airline_version="v0.11"
ARG vim_commentary_version="master"
ARG vim_fugitive_version="v3.3"
ARG nerdtree_version="6.10.11"
ARG vim_devicons_version="v0.11.0"
ARG nerd_fonts_version="v2.1.0"
ARG preview_markdown_vim_version="master"
ARG mdr_version="v0.2.5"
ARG nodejs_major_version="16"
ARG npm_version="7.20.6"
ARG terraform_lsp_version="0.0.12"
ARG tfenv_version="v2.2.2"
ARG terraform_version="1.0.4"
ARG terragrunt_version="v0.31.4"
ARG vim_plugins="neoclide/coc.nvim morhetz/gruvbox luochen1990/rainbow vim-airline/vim-airline tpope/vim-commentary dense-analysis/ale preservim/nerdtree ryanoasis/vim-devicons skanehira/preview-markdown.vim"

ENV TERM=xterm-256color
ENV PATH=/opt/tfenv/bin/:${PATH}

RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN apt-get update && \
    apt-get -y install software-properties-common curl apt-utils git gcc make libncurses-dev unzip python3 python3-dev libpython3-dev

RUN git -c advice.detachedHead=false clone -b ${vim_version} https://github.com/vim/vim.git /opt/vim && \
    cd /opt/vim && \
    ./configure --enable-python3interp && make && make install

# Install nodejs and Yarn required packages
RUN curl -fsSL https://deb.nodesource.com/setup_${nodejs_major_version}.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y nodejs yarn && \
    npm install -g npm@${npm_version}

 RUN mkdir -p /root/.config/coc

# Setting up LSP for Code Completion for terraform
RUN curl -LO https://github.com/juliosueiras/terraform-lsp/releases/download/v${terraform_lsp_version}/terraform-lsp_${terraform_lsp_version}_linux_amd64.tar.gz && \
     tar zxvf terraform-lsp_${terraform_lsp_version}_linux_amd64.tar.gz && \
     mv terraform-lsp /usr/local/bin/ && \
     chmod +x /usr/local/bin/terraform-lsp

# Setting up tfenv , terraform and terragrunt
RUN git -c advice.detachedHead=false clone -b ${tfenv_version} https://github.com/tfutils/tfenv.git /opt/tfenv && \
    /opt/tfenv/bin/tfenv install ${terraform_version} && \
    /opt/tfenv/bin/tfenv use ${terraform_version} && \
    curl -L https://github.com/gruntwork-io/terragrunt/releases/download/${terragrunt_version}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt


COPY vimrc /root/.vim/
SHELL ["/bin/bash", "-c"]
RUN mkdir -p /root/.vim/pack/plugins/start/ && \
    cd /root/.vim/pack/plugins/start/ && \
    for plugin in ${vim_plugins} ; \
      do  \
        plugin_name=$(echo $plugin | cut -d/ -f2) \
        plugin_version_name=$(echo $plugin_name | sed 's/-/_/g;s/\./_/g;s/$/_version/') ;\
        git -c advice.detachedHead=false clone -b ${!plugin_version_name} https://github.com/${plugin}.git ;\
      done

# Install Coc Extensions
RUN vim -c 'CocInstall -sync coc-eslint coc-prettier coc-json coc-tsserver coc-sql coc-python coc-phpls coc-json coc-docker  coc-snippets coc-prettier coc-json coc-yaml coc-sql coc-sh|qa'

RUN apt-get -y update && \
    apt-get -y install gcc ccls clang-tidy cppcheck clang-format


# Install SQLLint for linting sql files
RUN curl -LO https://github.com/joereynolds/sql-lint/releases/download/${sqllint_version}/sql-lint-linux && \
    mv sql-lint-linux /usr/local/bin/sql-lint && \
    chmod +x /usr/local/bin/sql-lint && \
    apt-get install -y sqlformat

# Bash linter
RUN apt-get -y install shellcheck
RUN curl -LO https://github.com/mvdan/sh/releases/download/${shfmt_version}/shfmt_${shfmt_version}_linux_amd64 && \
    mv shfmt_${shfmt_version}_linux_amd64 /usr/local/bin/shfmt && \
    chmod +x /usr/local/bin/shfmt

# Setting up Python
RUN apt-get -y install python3-pip && \
    pip3 install jedi flake8 black pylint

# TFLint for terraform
RUN curl -LO https://github.com/terraform-linters/tflint/releases/download/${tflint_version}/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip && \
    mv tflint /usr/local/bin/ && \
    chmod +x /usr/local/bin/tflint

# Supporting php linting
RUN apt-get -y install php-codesniffer phpmd

# Support Ansible lint
RUN pip3 install ansible-lint && \
    pip3 install yamllint spectral && \
    npm install -g prettier

# Support Markdown renderer
RUN curl -L https://github.com/MichaelMure/mdr/releases/download/${mdr_version}/mdr_linux_amd64 -o /usr/local/bin/mdr && \
    chmod +x /usr/local/bin/mdr
COPY coc-settings.json /root/.vim/
ENTRYPOINT [ "/usr/local/bin/vim" ]
