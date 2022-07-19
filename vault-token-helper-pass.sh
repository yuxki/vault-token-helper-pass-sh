#!/bin/sh

#--------------------------------------------------------------------------------------------------
# vault-token-helper-pass-sh -- Token helper script for Hashicorp Vault client.
#                               get, store, erase vault token with gpg encryption "pass"
#                               password manager.
#--------------------------------------------------------------------------------------------------
# Version: 1.0
# Author: yuxki
# Repository: https://github.com/yuxki/vault-token-helper-pass-sh
# Last Change: 2022/7/19
# License:
# MIT License
#
# Copyright (c) 2022 Yuxki
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#--------------------------------------------------------------------------------------------------

version="1.0"
usage="Usage: vault-token-helper-pass-sh <pass operation>

  pass operatons:
      These operatios are command helper that runs \"pass <command> <path>\".
      <path> is SHA1 hash that computed by VAULT_ADDR environment variable.

      get:            Decrypt and show the vault token with \"pass show <path>\" command.
      store:          Encrypt and store the vault token with \"pass insert <path>\" command.
      erase:          Remove vault token and with \"pass insert <path>\" command.
                      And also, the VAULT_ADDR to SHA1 map is deleted.
      ls:             Show all VAULT_ADDR to SHA1 maps.

  Other commands:
      -h, --help:     Show usage.
      -v, --version:  Show version of this shell script.

    Required environment variable:
      VAULT_ADDR:     Computed SHA1 and use the hash for path name.
                      You can switch token by setting this environment variable.
                      VAULT_ADDR to SHA1 maps are saved at \"~/.vault-token-helper-pass-sh-map\".
"

# Option ------------------------------------------------------------------------------------------
if [ -z "$1" ]; then
  echo "$usage"
  exit 1
fi

case "$1" in
  --version|-v)
    echo "Version $version"
    exit 0
    ;;
  --help|-h)
    echo "$usage"
    exit 0
    ;;
esac

# Checks for pass operation -----------------------------------------------------------------------
if [ -z "$VAULT_ADDR" ]; then
  echo "Error: No VAULT_ADDR environment variable set."
  exit 1
fi

map_file_path="$HOME/.vault-token-helper-pass-sh-map"
if [ ! -e $map_file_path ]; then
  touch $map_file_path
  chmod -077 $map_file_path
fi

# Map Addr to SHA1 --------------------------------------------------------------------------------
sha1hash=`echo $VAULT_ADDR | sha1sum - | sed "s/ *-$//"`
is_exists=`grep "$sha1hash$" $map_file_path`
if [ -z "$is_exists" ]; then
  echo "$VAULT_ADDR,$sha1hash" >> $map_file_path
fi

# Main --------------------------------------------------------------------------------------------
pass_dir="vault-token-helper-pass-sh"
path="$pass_dir/$sha1hash"
case "$1" in
  get)
    pass show $path | tr -d '\n'
    exit 0
    ;;
  store)
    read token
    echo -n "$token" | pass insert -e $path
    exit 0
    ;;
  erase)
    sed "/$sha1hash/d" -i $map_file_path
    pass rm -f $path
    exit 0
    ;;
  ls)
    if [ $1 = "ls" ] ; then
      pass ls $pass_dir |
      cat $map_file_path - |
      awk '
        /^vault-token-helper-pass-sh/ {
          print $0
          lsFlag = 1
          next
        }
        # make mapping database until starting "pass ls" lines
        !lsFlag {
          records[i++] = $0
        }
        # search sha1 from mapping database and print formatted line
        lsFlag {
          for ( idx in records) {
            split(records[idx], record, ",")
            if ($0 ~ record[2]) {
              split($0, line, " ")
              print line[1] " " record[1] " (sha1:" line[2] ")"
            }
          }
        }'
    fi
    exit 0
    ;;
esac

echo "Error: Unexpected error occured."
exit 1
