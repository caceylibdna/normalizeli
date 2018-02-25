windows git: warning LF will be replaced by CRLF
windows CRLF, linux LF:
$ rm -rf .git  // remove .git  
$ git config --global core.autocrlf false  //disable to transfer the return line from linux LF to windows CRLF.

initiate the git:
$ git init    
$ git add .  

git config --global core.whitespace cr-at-eol //disable to diff return line from linux LF to windows CRLF.


Administrator@WIN-6J782U2JBTB MINGW64 ~
$ ssh-keygen.exe -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/c/Users/Administrator/.ssh/id_rsa):
Created directory '/c/Users/Administrator/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /c/Users/Administrator/.ssh/id_rsa.
Your public key has been saved in /c/Users/Administrator/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:4BBhidzsoaPmesjYGnQrxlQfi5YgppG/st0falcFcPw Administrator@WIN-6J782U2JBTB
The key's randomart image is:
+---[RSA 2048]----+
| . ++o.o.        |
| .o.=. .o        |
|+o +.o.  o       |
|+o= =oo.  E      |
|.+.* o. S.       |
|=.o..   .        |
|B*..  ..         |
|+B+.....         |
|=o..oo.          |
+----[SHA256]-----+

