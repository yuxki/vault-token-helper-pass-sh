#!/bin/bash

set -e

declare_test_start() {
  echo "[START]: $1"
}

# check see if exit 0 even if the path not found ==================================================
declare_test_start "Get from empty store."
export VAULT_ADDR=http://localhost:8200
vault-token-helper-pass-sh get
exit_code=$?
if [ ! $exit_code -eq 0 ]; then
  echo "[ERROR]: Exit code is not 0, when the SHA1 path not found."
  exit 1
fi

# check see if store and get are working collectoly -----------------------------------------------
store_error_msg="[ERROR]: Exit code is not 0, when store input."

declare_test_start "Store to http://localhost:8200."
expect_a="aaaa"
export VAULT_ADDR=http://localhost:8200; echo "$expect_a" | vault-token-helper-pass-sh store
exit_code=$?
if [ ! $exit_code -eq 0 ]; then
  echo "$store_error_msg"
  exit 1
fi

declare_test_start "Store to http://127.0.0.1:8200."
expect_b="bbbb"
export VAULT_ADDR=http://127.0.0.1:8200; echo "$expect_b" | vault-token-helper-pass-sh store
exit_code=$?
if [ ! $exit_code -eq 0 ]; then
  echo "$store_error_msg"
  exit 1
fi

result_a=$(export VAULT_ADDR=http://localhost:8200; vault-token-helper-pass-sh get)
result_b=$(export VAULT_ADDR=http://127.0.0.1:8200; vault-token-helper-pass-sh get)

if [ "$result_a" != "$expect_a" ]; then
  echo "[ERROR]: Expected to get \"$expect_a\" but \"$result_a\" is stored for http://localhost:8200."
  exit 1
fi
if [ "$result_b" != "$expect_b" ]; then
  echo "[ERROR]: Expected to get \"$expect_b\" but \"$result_b\" is stored for http://127.0.0.1:8200."
  exit 1
fi

# check see if "ls" is working collectoly ---------------------------------------------------------
declare_test_start "Check see if ls result is collect."
expect_ls="vault-token-helper-pass-sh
|-- http://127.0.0.1:8200 (sha1:490650718a8022ff97742a7e0745c0ec326c07a8)
\`-- http://localhost:8200 (sha1:f4246400c1e86c77d9315da81e281cca3528c4bd)"

result_ls=$(vault-token-helper-pass-sh ls)
if [ "$expect_ls" != "$result_ls" ]; then
  echo "[ERROR]: Expected that \"ls\" outputs \"$expect_ls\" but \"$result_ls\" returned."
  exit 1
fi

# check see if "erase" is working collectoly -------------------------------------------------------
declare_test_start "Check see if erase from http://localhost:8200."
export VAULT_ADDR=http://localhost:8200; vault-token-helper-pass-sh erase

declare_test_start "Erase from http://127.0.0.1:8200."
export VAULT_ADDR=http://127.0.0.1:8200; vault-token-helper-pass-sh erase

declare_test_start "Check see if ls result is collect."
expect_ls="There is no vault token that this script manages."

result_ls=$(vault-token-helper-pass-sh ls)
if [ "$expect_ls" != "$result_ls" ]; then
  echo "[ERROR]: Expected that all token is erased, but returned \"$result_ls\""
  exit 1
fi
