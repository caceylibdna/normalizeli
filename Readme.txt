windows git:warning: LF will be replaced by CRLF
windows CRLF, linux LF:
$ rm -rf .git  // remove .git  
$ git config --global core.autocrlf false  //disable to transfer the return line from linux LF to windows CRLF.

initiate the git:
$ git init    
$ git add .  

git config --global core.whitespace cr-at-eol //disable to diff return line from linux LF to windows CRLF.
