### Fedora as server
* Operate on local cp the frp over because frp might not be able to open on server using tar directly
  `scp -r frp_0.27.0_linux_amd64 x.x.x.x:download`
* Operate on server
  ```zsh
  # enable ports
  firewall-cmd --permanent --add-port=6000-7000/tcp
  firewall-cmd --reload
  firewall-cmd --list-ports
  # start server
  cd ~/download/frp_0.27.0_linux_amd64
  ./frps -c ./frps.ini
  ```

###  MacOS as target

  ```zsh
  brew install frpc 
  # replace server addr and the remote port on
  sed -i '' -e 's/server_addr.*/server_addr = x.x.x.x/' -e 's/remote_port.*/remote_port = 6000/' 
  /usr/local/etc/frp/frpc.ini 
  # turn ssh on
  sudo systemsetup -getremotelogin 
  sudo systemsetup -setremotelogin on
  sudo systemsetup -setremotelogin off
  # start the client
  frpc -c /usr/local/etc/frp/frpc.ini
  ```

### ssh over from local
```zsh
ssh -p6000 user@x.x.x.x
```

