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
#### 1. install to ~/.local/bin
```
# It is assumed that ~/.local/bin exists and
# PATH environment variable includes $HOME/.local/bin.
git clone https://github.com/yuxki/vault-token-helper-pass-sh.git
cd vault-token-helper-pass-sh
./install.sh
```
#### 2. install to /usr/local/bin
```
git clone https://github.com/yuxki/vault-token-helper-pass-sh.git
cd vault-token-helper-pass-sh
sudo cp vault-token-helper-pass.sh /usr/local/bin/vault-token-helper-pass-sh 
echo 'token_helper = "/usr/local/bin/vault-token-helper-pass-sh"' > $HOME/.vault 
```
