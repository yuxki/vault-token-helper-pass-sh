#!/bin/sh

#--------------------------------------------------------------------------------------------------
# install.sh -- install vault-token-helper-pass-sh into local environment.
#--------------------------------------------------------------------------------------------------
# Version: 1.0
# Author: yuxki
# Repository: https://github.com/yuxki/vault-token-helper-pass-sh
# Last Change: 2022/7/19
#--------------------------------------------------------------------------------------------------

pwd=`pwd`
dot_vault_path="$HOME/.vault"

# Checks  -----------------------------------------------------------------------------------------

# check see if required files exists at pwd
if [ ! -f $pwd/vault-token-helper-pass.sh ]; then
  echo "Error: vault-token-helper-pass.sh does not exists on current working directory." 1>&2
  exit 1
fi

# check see if required directory is exists.
if [ ! -d $HOME/.local/bin ]; then
  echo "Error: $HOME/.local/bin does not exists.

To solve this problem, please choose one of the following action:
  1. Run \"mkdir -p $HOME/.local/bin\", and add $HOME/.local/bin to PATH environment variable.
  2. Instead of running this install.sh, run bellow commands.
      sudo cp $pwd/vault-token-helper-pass.sh /usr/local/bin/vault-token-helper-pass-sh
      echo 'token_helper = \"/usr/local/bin/vault-token-helper-pass-sh\"' > $HOME/.vault
" 1>&2
  exit 1
fi

# check see if .vault already exists
if [ -e $dot_vault_path ]; then
  echo "Error: \"$HOME/.vault\" is already exists." 1>&2
  exit 1
fi

# Install -----------------------------------------------------------------------------------------

# put .vault file to home directory
install_path="$HOME/.local/bin/vault-token-helper-pass-sh"
line="token_helper ="
line="$line \"$install_path\""
echo "$line" > $dot_vault_path
if [ ! -f $dot_vault_path ]; then
  echo "Error: Create failed from \"$dot_vault_path\"." 1>&2
  exit 1
fi
echo "Info: Create \"$dot_vault_path\"."

# copy scripts to .local/bin directory
cp $pwd/vault-token-helper-pass.sh $install_path
if [ ! -f $HOME/.local/bin/vault-token-helper-pass-sh ]; then
  echo "Error: Copy failed from \"$pwd/vault-token-helper-pass.sh\" to \"$install_path\"." 1>&2
  exit 1
fi

echo "Info: Copy from \"$pwd/vault-token-helper-pass.sh\" to \"$install_path\"."

echo "Install Completed!."
