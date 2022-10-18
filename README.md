#A  funny script written by funny

![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg)
[![GitHub stars](https://img.shields.io/github/stars/ToyoDAdoubi/doubi.svg?style=popout&label=Stars)](https://github.com/ToyoDAdoubi/doubi/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ToyoDAdoubi/doubi.svg?style=popout&label=Fork)](https://github.com/ToyoDAdoubi/doubi/fork)
##  Script index

* [ ***Agent related*** ](#Agent related)
  * [ss-go.sh](#ss_gosh)
  * [ssr.sh](#ssrsh)
  * [ssrmu.sh](#ssrmush)
  * [brook.sh](#brooksh)
  * [goflyway.sh](#goflywaysh)
  * [daze.sh](#dazesh)
  * [lightsocks.sh](#lightsockssh)
  * [mtproxy.sh](#mtproxysh)
  * [mtproxy_go.sh](#mtproxy_gosh)
* [ ***Transfer related*** ](#Transfer related)
  * [iptables-pf.sh](#iptables-pfsh)
  * [brook-pf.sh](#brook-pfsh)
  * [haproxy.sh](#haproxysh)
  * [ socat.sh ](#socatsh)
  * [tinymapper.sh](#tinymappersh)
* [ ***BT download related*** ](#bt download related)
  * [aria2.sh](#aria2sh)
  * [cloudt.sh](#cloudtsh)
  * [pserver.sh](#pserversh)
* [ ***Server related*** ](#Server related)
  * [bbr.sh](#bbrsh)
  * [status.sh](#statussh)
  * [ban_iptables.sh](#ban_iptablessh)
  * [ ssh_port.sh ](#ssh_portsh)
* [ ***VPN related*** ](#vpn related)
  * [ocserv.sh](#ocservsh)
* [ ***DNS related*** ](#dns related)
  * [dowsdns.sh](#dowsdnssh)
* [ ***HTTP related*** ](#http related)
  * [caddy_install.sh](#caddy_installsh)
  * [pythonhttp.sh](#pythonhttpsh)
* [ ***Other*** ](#Other)
  * [adbyby.sh](#adbybysh)
  * [gfw_push.sh](#gfw_pushsh)
  * [libsodium.sh](#libsodiumsh)
  * [ssrstatus.sh](#ssrstatussh)
  * [ssr_check.sh](#ssr_checksh)
  * [ssr_ip_check.sh](#ssr_ip_checksh)

---

##  Agent related

## ss_go.sh

-Script description: Shadowsocks one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/ss-jc67/
-Project address: https://github.com/shadowsocks/go-shadowsocks2

####  Script Features:
At present, each Shadowsocks script on the Internet basically only has basic functions such as installation/startup/restart, which is still not simple and convenient for Xiaobai. Since it is a one-click script, it must be as simple as possible, and Xiaobai is easier to accept and use!

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ss-go.sh && chmod +x ss-go.sh && bash ss-go.sh
```

---
## ssr.sh

-Script description: ShadowsocksR one - click installation management script, supports single-port/multi-port switching and management
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/ss-jc42/
-Project address: https://github.com/ToyoDAdoubiBackup/shadowsocksr

####  Script Features:
At present, each ShadowsocksR script on the Internet basically only has basic functions such as installation/startup/restart, which is still not simple and convenient for Xiaobai. Since it is a one-click script, it must be as simple as possible, and Xiaobai is easier to accept and use!

- Support to limit user speed
- Support to limit the number of port devices
- Support to display the current connection IP
- Support to display SS/SSR connection + QR code
- Support switching management single/multi-port
- Support one-click installation of sharp speed
- Support one-click installation of BBR
- Support one-click ban spam (SMAP)/BT/PT

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh && chmod +x ssr.sh && bash ssr.sh
```

---
## ssrmu.sh

-Script description: ShadowsocksR one - click installation management script, supports flow control
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/ss-jc60/
-Project address: https://github.com/ToyoDAdoubiBackup/shadowsocksr

####  Script Features:
At present, each ShadowsocksR script on the Internet basically only has basic functions such as installation/startup/restart, which is still not simple and convenient for Xiaobai. Since it is a one-click script, it must be as simple as possible, and Xiaobai is easier to accept and use!

- Support to limit user speed
- Support to limit the number of user devices
- Support to limit total user traffic
- Supports timed traffic clearing
- Support to display the current connection IP
- Support to display SS/SSR connection + QR code
- Support one-click installation of sharp speed
- Support one-click installation of BBR
- Support one-click ban spam (SMAP)/BT/PT

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssrmu.sh && chmod +x ssrmu.sh && bash ssrmu.sh
```

---
## brook.sh

-Script description: Brook one - click installation management script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/brook-jc3/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/brook.sh && chmod +x brook.sh && bash brook.sh
```

---
## goflyway.sh

-Script description: GoFlyway one - click installation management script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/goflyway-jc2/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/goflyway.sh && chmod +x goflyway.sh && bash goflyway.sh
```

---
## lightsocks.sh

-Script description: LightSocks one - click installation management script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/lightsocks-jc1/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/lightsocks.sh && chmod +x lightsocks.sh && bash lightsocks.sh
```

---
## daze.sh

-Script description: DAZE one - click installation management script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/daze-jc3/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/daze.sh && chmod +x daze.sh && bash daze.sh
```

---
## mtproxy.sh

-Script description: Mtproto Proxy one - click installation management script
-System Support : CentOS7 / Debian7+ / Ubuntu14+
-How to use: https://doub.io/shell-jc7/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh
```

---
## mtproxy_go.sh

-Script description: Mtproto Proxy Go version one-click installation management script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/shell-jc9/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/mtproxy_go.sh && chmod +x mtproxy_go.sh && bash mtproxy_go.sh
```

---

##  Transfer related

## iptables-pf.sh

-Script description: iptables port forwarding one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-20/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/iptables-pf.sh && chmod +x iptables-pf.sh && bash iptables-pf.sh
```

---
## brook-pf.sh

-Script description: Brook port forwarding one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-37/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/brook-pf.sh && chmod +x brook-pf.sh && bash brook-pf.sh
```

---
## haproxy.sh

-Script description: HaProxy one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-19/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/haproxy.sh && chmod +x haproxy.sh && bash haproxy.sh
```

---
##  shocked.sh

-Script description: Socat one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-18/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/socat.sh && chmod +x socat.sh && bash socat.sh
```

---
## tinymapper.sh

-Script description: tinyPortMapper one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-36/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/tinymapper.sh && chmod +x tinymapper.sh && bash tinymapper.sh
```

---

##  BT download related

## aria2.sh

-Script description: Aria2 one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
- How to use: https://doub.io/shell-jc4/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/aria2.sh && chmod +x aria2.sh && bash aria2.sh
```

---
## cloudt.sh

-Script description: Cloud Torrent one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-12/
-Project address: https://github.com/jpilora/cloud-torrent

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/cloudt.sh && chmod +x cloudt.sh && bash cloudt.sh
```

---
## pserver.sh

-Script description: Peerflix Server one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-13/
-Project address: https://github.com/asapach/peerflix-server

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/pserver.sh && chmod +x pserver.sh && bash pserver.sh
```

---

##  Server related

## bbr.sh

-Script description: BBR one - click installation management script
-System support : Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-16/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh && chmod +x bbr.sh && bash bbr.sh
```

---
## status.sh

-Script description: ServerStatus one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
- How to use: https://doub.io/shell-jc3/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/status.sh && chmod +x status.sh && bash status.sh
```

---
## ban_iptables.sh

-Script description: iptables spam (SPAM)/BT/PT one-click ban script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/shell-jc2/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh
```

---
## ssh_port.sh

-Script description: SSH one - click modification port script
-System support : Debian6+ / Ubuntu14+
-How to use: https://doub.io/linux-jc11/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssh_port.sh && chmod +x ssh_port.sh && bash ssh_port.sh
```

---

##  VPN related

## ocserv.sh

-Script description: Ocserv AnyConnect one - click installation management script
-System Support : Debian7+ / Ubuntu14+
- How to use: https://doub.io/vpnzy-7/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ocserv.sh && chmod +x ocserv.sh && bash ocserv.sh
```

---

##  DNS related

## dowsdns.sh

-Script description: DowsDNS one - click installation management script
-System Support : CentOS7 / Debian7+ / Ubuntu14+
-How to use: https://doub.io/dowsdns-jc3/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/dowsdns.sh && chmod +x dowsdns.sh && bash dowsdns.sh
```

---

##  HTTP related

## caddy_install.sh

-Script description: Caddy one - click installation script
-System Support : CentOS6+ / Debian7+ / Ubuntu14+
-How to use: https://doub.io/shell-jc1

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh
 #Install the plugin:
 bash caddy_install.sh xxx,xxx
  #For example, install the http.filemanager and http.webdav plugins at the same time:
  bash caddy_install.sh http.filemanager,http.webdav
  # Plugins and Caddy are integrated (single binary), multiple plugins must be installed at the same time.
#Uninstall command:
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh && chmod +x caddy_install.sh && caddy_install.sh uninstall
```

---
## pythonhttp.sh

-Script description: SimpleHTTPServer one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-8/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/pythonhttp.sh && chmod +x pythonhttp.sh && bash pythonhttp.sh
```

---

##  Other

## adbyby.sh

-Script description: ADbyby one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/adbyby-jc2/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/adbyby.sh && chmod +x adbyby.sh && bash adbyby.sh
```

## gfw_push.sh

-Script description: One - click script to monitor whether the server IP is blocked and push it to Telegram
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/shell-jc8/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/gfw_push.sh && chmod +x gfw_push.sh && bash gfw_push.sh
```

---
## libsodium.sh

-Script description: libsodium one - click installation management script
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/shell-jc6/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/libsodium.sh && chmod +x libsodium.sh && bash libsodium.sh
```

---
## ssr_check.sh

-Script description: ShadowsocksR batch quickly verify account availability
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/ss-jc56/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr_check.sh && chmod +x ssr_check.sh
```

---
## ssrstatus.sh

-Script description: ShadowsocksR account online monitoring website
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/shell-jc5/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssrstatus.sh && chmod +x ssrstatus.sh && bash ssrstatus
```

---
## ssr_ip_check.sh

-Script description: ShadowsocksR detects the IP number of each port link
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/ss-jc50/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr_ip_check.sh && chmod +x ssr_ip_check.sh
```

---
## ~~pipes.sh~~

-Script description: PipeSocks one - click installation management script (the software has been stopped)
-System Support : CentOS7 / Debian7+ / Ubuntu14+
-How to use: https://doub.io/pipesocks-jc2/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/pipesocks/install/master/install.sh && mv install.sh pipes.sh && chmod +x pipes.sh && bash pipes.sh
```

---
##  ~~gogo.sh~~

-Script description: GoGo Tunnel one - click installation management script (the software has been stopped)
-System Support : CentOS6+ / Debian6+ / Ubuntu14+
-How to use: https://doub.io/wlzy-24/

####  Download and install:
``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/gogo.sh && chmod +x gogo.sh && bash gogo.sh
```

---
Copyright (C) 2016-2018 Toyo <https://doub.io>
