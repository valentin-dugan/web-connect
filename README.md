
![pic](assets/web-connect.svg)

# Web-connect (BETA)

- is a CLI utility designed to help sysadmins to easily access a web interface for which is required a vpn connection or executed a portforwarding command.
- it can open URL in a browser
- works on macos and linux
- is published under the GNU General Public License (GPL). For details, please refer to the [LICENSE](./LICENSE.GPL) file.
- under the hood uses fzf and openvpn

## Get started

1. Clone repository on your local machine
2. Set alias

    ```bash
    cd web-connect/

    # Check what shell your are using
    echo $SHELL

    # If using bash shell run command
    grep -q 'alias web' "${HOME}/.bashrc" || alias web="${PWD}/run.sh" >> "${HOME}/.bashrc"

    # If using zsh shell run commnad
    grep -q 'alias web' "${HOME}/.zshrc" || alias web="${PWD}/run.sh" >> "${HOME}/.zshrc"
    ```

3. In a new terminal run command `web`

### Add a record
```bash
web --new default --title 'Youtube' --url 'https://youtube.com'
```

### Edit settings
```bash
web --settings
```

### Get help
```bash
web --help
```
