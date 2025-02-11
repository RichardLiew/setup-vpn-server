# Run command:
1. `nohup /bin/bash -c "$(curl -fsSL https://github.com/RichardLiew/setup-vpn-server/raw/master/setup.sh)" >> ./setup-vpn-server.log 2>&1 &`

    安装完成后，在云服务器安全组设置放行「 500/udp 和 4500/udp」端口（类型为“自定义”，来源为“0.0.0.0”或者全部“ipv4 地址”，协议为“UDP”）
    需要记住的客户端登录信息：IP, Username, Password, IpsecPSK
   
  ~~2. `nohub /bin/bash -c "$(curl -fsSL https://get.vpnsetup.net)" >> ./setup-vpn-server.log 2>&1 &`~~

  ~~3. `nohub /bin/bash -c "$(curl -fsSL https://github.com/hwdsl2/setup-ipsec-vpn/raw/master/vpnsetup.sh)" >> ./setup-vpn-server.log 2>&1 &`~~
