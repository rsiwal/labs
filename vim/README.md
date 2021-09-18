# VIM Customization

## Introduction

vim is a great tool for editing and allows editing of the files very fast
Its very exensible and I am a fan of [VIM Awsome](https://vimawesome.com/) that provides a huge number of plugins that make the life easy for the developers.

## vim.Dockerfile

This Dockerfile has been created with some plugins that make life easy for developers. It has the following features:

- AutoCompletion, Linting & Fixing of Code
  - Terraform
  - Ansible
  - C , C++
  - K8s manifests
  - Kustomize
  - Bash
  - PHP

## Using vim.Dockerfile

- Create the image.
  ```
  cd vim/
  make build
  ```
- Run vim from this image
  ```
  docker run -e COLUMNS=`tput cols` -e LINES=`tput lines` --rm  -v <LocalVolume>:/mnt -it vim-devops <file to be opened should be mounted on docker container>
  ```

## Setup vim locally (Only Ubuntu Supported as of now)

```
cd vim/
./local_setup.sh
```

