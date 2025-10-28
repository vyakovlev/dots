# vscode

## User settings
Navigate to the following directory based on your operating system:
- macOS: ~/Library/Application Support/Code/User/
- Windows: %APPDATA%\Code\User\
- Linux: ~/.config/Code/User/

Copy keybindings.json and settings.json


## Extensions
- Get extensions list:
```shell
code --list-extensions > vscode-extensions.txt
```

- Import extensions:
```shell
# Unix:
cat vscode-extensions.txt | xargs -L 1 echo code --install-extension
# Windows (PowerShell, e. g. using Visual Studio Code's integrated Terminal):
cat vscode-extensions.txt | % { "code --install-extension $_" }
```
