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
  docker build -t devops-vim -f vim.Dockerfile .
  ```
- Run vim from this image
  ```
  docker run --rm  -v <LocalVolume>:<Mount folder> -it devops-vim <file to be opened>
  ```

## Setup vim locally (Only Ubuntu Supported as of now)

cd vim/
./local_setup.sh

