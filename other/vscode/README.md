# vscode
Export extensions:
```bash
code --list-extensions > vscode-extensions.txt
```

Import extensions:
```bash
# Unix:
cat file | xargs -L 1 echo code --install-extension
# Windows (PowerShell, e. g. using Visual Studio Code's integrated Terminal):
cat file | % { "code --install-extension $_" }
```
