# Haskell IDE Engine

## version

- [ghc 8.6.5](./Dockerfile)
- [ghc 8.6.4](./Dockerfile)

## Docker Hub

https://hub.docker.com/r/pyar6329/hie

## Usage

```bash
$ curl -L -o ~/.local/bin/hie_low_memory "https://raw.githubusercontent.com/pyar6329/docker-hie/master/sample/bin/hie_low_memory"
$ chmod +x ~/.local/bin/hie_low_memory
```

This docker image mount ~/.ssh on container because stack may do git clone in package.yaml.
However, if you want to use GitHub access token instead of ssh key, Set to environment variable like below.

```bash
# bash
$ echo 'export GITHUB_TOKEN="your GitHub access token"' >> ~/.bashrc

# zsh
$ echo 'export GITHUB_TOKEN="your GitHub access token"' >> ~/.zshrc
```

VSCode

```bash
$ cd $YOUR_STACK_PROJECT
$ mkdir .vscode
$ curl -L -o .vscode/settings.json "https://raw.githubusercontent.com/pyar6329/docker-hie/master/sample/.vscode/settings.json"
$ code .
```

Coc.nvim

```bash
$ cd $YOUR_STACK_PROJECT
$ curl -L -o ~/.vim/coc-settings.json "https://raw.githubusercontent.com/pyar6329/docker-hie/master/sample/.vim/coc-settings.json"
$ nvim
```
