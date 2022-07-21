## vault-token-helper-pass-sh
Token helper script for Hashicorp Vault client. get, store, erase vault token with gpg encryption by "pass" password manager.

## Installation
### Install pass
This scirpt run `pass` command, so please install `pass` first.\
 (https://www.passwordstore.org)
```
sudo apt-get install pass
```

### Install vault-token-helper-pass-sh
There are 2 ways to install `vault-token-helper-pass-sh`.
#### 1. Install to ~/.local/bin
```
# It is assumed that ~/.local/bin exists and
# PATH environment variable includes $HOME/.local/bin.
git clone https://github.com/yuxki/vault-token-helper-pass-sh.git
cd vault-token-helper-pass-sh
./install.sh
```
#### 2. Install to /usr/local/bin
```
git clone https://github.com/yuxki/vault-token-helper-pass-sh.git
cd vault-token-helper-pass-sh
sudo cp vault-token-helper-pass.sh /usr/local/bin/vault-token-helper-pass-sh 
echo 'token_helper = "/usr/local/bin/vault-token-helper-pass-sh"' > $HOME/.vault 
```

## Usage: vault-token-helper-pass-sh \<pass operation\>
### pass operations
These operations are command helper that runs `pass <command> <path>`.
\<path\> is SHA1 hash that computed by VAULT_ADDR environment variable.

#### store
Encrypt and store the vault token with `pass insert <path>` command.\
And add the VAULT_ADDR to SHA1 map is added to "~/.vault-token-helper-pass-sh-map".
```
$ export VAULT_ADDR=http://127.0.0.1:8200
$ echo foo | vault-token-helper-pass-sh store
$ pass ls
Password Store
`-- vault-token-helper-pass-sh
    `-- 490650718a8022ff97742a7e0745c0ec326c07a8
```
```
$ cat ~/.vault-token-helper-pass-sh-map 
http://127.0.0.1:8200,490650718a8022ff97742a7e0745c0ec326c07a8
```
#### get
Decrypt and show the vault token with `pass show <path>` command.
```
$ export VAULT_ADDR=http://127.0.0.1:8200
$ vault-token-helper-pass-sh get
foo
```

#### erase
Remove vault token and with `pass insert <path>` command.\
And the VAULT_ADDR to SHA1 map is deleted from "~/.vault-token-helper-pass-sh-map".
```
$ export VAULT_ADDR=http://127.0.0.1:8200
$ vault-token-helper-pass-sh erase
$ pass ls
Password Store
```
```
$ cat ~/.vault-token-helper-pass-sh-map 
```
#### ls
Show all VAULT_ADDR to SHA1 maps.
```
$ vault-token-helper-pass-sh ls
vault-token-helper-pass-sh
|-- http://127.0.0.1:8200 (sha1:490650718a8022ff97742a7e0745c0ec326c07a8)
\`-- http://localhost:8200 (sha1:f4246400c1e86c77d9315da81e281cca3528c4bd)
```
### Required environment variable
#### VAULT_ADDR
Computed SHA1 and use the hash for path name.
You can switch token by setting this environment variable.
VAULT_ADDR to SHA1 maps are saved at \"~/.vault-token-helper-pass-sh-map\".
