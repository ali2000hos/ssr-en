#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#	Description: Install the ShadowsocksR server
#	Version: 2.0.38
#	Author: Toyo - English version : Ali2000hos
#	Blog: https://doub.io/ss-jc42/
#=================================================

sh_ver="2.0.38"
filepath=$(cd "$(dirname "$0")"; pwd)
file=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
ssr_folder="/usr/local/shadowsocksr"
ssr_ss_file="${ssr_folder}/shadowsocks"
config_file="${ssr_folder}/config.json"
config_folder="/etc/shadowsocksr"
config_user_file="${config_folder}/user-config.json"
ssr_log_file="${ssr_ss_file}/ssserver.log"
Libsodiumr_file="/usr/local/lib/libsodium.so"
Libsodiumr_ver_backup="1.0.13"
Server_Speeder_file="/serverspeeder/bin/serverSpeeder.sh"
LotServer_file="/appex/bin/serverSpeeder.sh"
BBR_file="${file}/bbr.sh"
jq_file="${ssr_folder}/jq"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[info]${Font_color_suffix}"
Error="${Red_font_prefix}[ERROR]${Font_color_suffix}"
Tip="${Green_font_prefix}[Notice]${Font_color_suffix}"
Separator_1="——————————————————————————————"

check_root(){
[[ $EUID != 0 ]] && echo -e "${Error} The current account is not ROOT (or does not have ROOT privileges) and cannot continue the operation, please use ${Green_background_prefix} sudo su ${Font_color_suffix} to obtain temporary ROOT privileges (You will be prompted to enter the password of the current account after execution)." && exit 1
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}
SSR_installation_status(){
[[ ! -e ${config_user_file} ]] && echo -e "${Error} ShadowsocksR configuration file not found, please check !" && exit 1
[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR folder not found, please check !" && exit 1
}
Server_Speeder_installation_status(){
[[ ! -e ${Server_Speeder_file} ]] && echo -e "${Error} Server Speeder is not installed, please check !" && exit 1
}
LotServer_installation_status(){
[[ ! -e ${LotServer_file} ]] && echo -e "${Error} LotServer is not installed, please check !" && exit 1
}
BBR_installation_status(){
if [[ ! -e ${BBR_file} ]]; then
echo -e "${Error} BBR script not found, start downloading..."
cd "${file}"
if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh; then
echo -e "${Error} BBR script download failed !" && exit 1
else
echo -e "${Info} BBR script download complete!"
chmod +x bbr.sh
fi
fi
}
# set firewall rules
Add_iptables(){
	iptables -I TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR"
	iptables -I UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR"
	ip6tables -I TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR"
	ip6tables -I UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR"
}
Del_iptables(){
	iptables -D TCP -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT -m comment --comment "SSR"
	iptables -D UDP -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT -m comment --comment "SSR"
	ip6tables -D TCP -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT -m comment --comment "SSR"
	ip6tables -D UDP -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT -m comment --comment "SSR"
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
	fi
}
Set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
		chkconfig --level 2345 iptables on
		chkconfig --level 2345 ip6tables on
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules\n/sbin/ip6tables-restore < /etc/ip6tables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
# read configuration information
Get_IP(){
	ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
	if [[ -z "${ip}" ]]; then
		ip=$(wget -qO- -t1 -T2 api.ip.sb/ip)
		if [[ -z "${ip}" ]]; then
			ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
			if [[ -z "${ip}" ]]; then
				ip="VPS_IP"
			fi
		fi
	fi
}
Get_User(){
	[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ parser does not exist, please check !" && exit 1
	port=`${jq_file} '.server_port' ${config_user_file}`
	password=`${jq_file} '.password' ${config_user_file} | sed 's/^.//;s/.$//'`
	method=`${jq_file} '.method' ${config_user_file} | sed 's/^.//;s/.$//'`
	protocol=`${jq_file} '.protocol' ${config_user_file} | sed 's/^.//;s/.$//'`
	obfs=`${jq_file} '.obfs' ${config_user_file} | sed 's/^.//;s/.$//'`
	protocol_param=`${jq_file} '.protocol_param' ${config_user_file} | sed 's/^.//;s/.$//'`
	speed_limit_per_con=`${jq_file} '.speed_limit_per_con' ${config_user_file}`
	speed_limit_per_user=`${jq_file} '.speed_limit_per_user' ${config_user_file}`
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
}
urlsafe_base64(){
	date=$(echo -n "$1"|base64|sed ':a;N;s/\n/ /g;ta'|sed 's/ //g;s/=//g;s/+/-/g;s/\//_/g')
	echo -e "${date}"
}
ss_link_qr(){
	SSbase64=$(urlsafe_base64 "${method}:${password}@${ip}:${port}")
	SSurl="ss://${SSbase64}"
	SSQRcode="http://doub.pw/qr/qr.php?text=${SSurl}"
    ss_link=" SS Link : ${Green_font_prefix}${SSurl}${Font_color_suffix} \n SS QR Code : ${Green_font_prefix}${SSQRcode}${Font_color_suffix}"
}
ssr_link_qr(){
	SSRprotocol=$(echo ${protocol} | sed 's/_compatible//g')
	SSRobfs=$(echo ${obfs} | sed 's/_compatible//g')
	SSRPWDbase64=$(urlsafe_base64 "${password}")
	SSRbase64=$(urlsafe_base64 "${ip}:${port}:${SSRprotocol}:${method}:${SSRobfs}:${SSRPWDbase64}")
	SSRurl="ssr://${SSRbase64}"
	SSRQRcode="http://doub.pw/qr/qr.php?text=${SSRurl}"
    ssr_link="SSR link: ${Red_font_prefix}${SSRurl}${Font_color_suffix} \n SSR QR code: ${Red_font_prefix}${SSRQRcode}${Font_color_suffix} \n "
}
ss_ssr_determine(){
	protocol_suffix=`echo ${protocol} | awk -F "_" '{print $NF}'`
	obfs_suffix=`echo ${obfs} | awk -F "_" '{print $NF}'`
	if [[ ${protocol} = "origin" ]]; then
		if [[ ${obfs} = "plain" ]]; then
			ss_link_qr
			ssr_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				ss_link=""
			else
				ss_link_qr
			fi
		fi
	else
		if [[ ${protocol_suffix} != "compatible" ]]; then
			ss_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				if [[ ${obfs_suffix} = "plain" ]]; then
					ss_link_qr
				else
					ss_link=""
				fi
			else
				ss_link_qr
			fi
		fi
	fi
	ssr_link_qr
}
# show configuration information
View_User(){
	SSR_installation_status
	Get_IP
	Get_User
	now_mode=$(cat "${config_user_file}"|grep '"port_password"')
	[[ -z ${protocol_param} ]] && protocol_param="0(unlimited)"
	if [[ -z "${now_mode}" ]]; then
		ss_ssr_determine
		clear && echo "===================================================" && echo
        echo -e "ShadowsocksR account configuration information:" && echo
        echo -e " I P\t : ${Green_font_prefix}${ip}${Font_color_suffix}"
        echo -e "port\t : ${Green_font_prefix}${port}${Font_color_suffix}"
        echo -e "password\t : ${Green_font_prefix}${password}${Font_color_suffix}"
        echo -e "Encrypt\t : ${Green_font_prefix}${method}${Font_color_suffix}"
        echo -e "protocol\t : ${Red_font_prefix}${protocol}${Font_color_suffix}"
        echo -e "Confusion\t : ${Red_font_prefix}${obfs}${Font_color_suffix}"
        echo -e "Device limit: ${Green_font_prefix}${protocol_param}${Font_color_suffix}"
        echo -e "Single thread speed limit: ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"
        echo -e "Port total speed limit: ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}"
        echo -e "${ss_link}"
        #echo -e "${ssr_link}"
        echo -e " ${Green_font_prefix} Hint: ${Font_color_suffix}
In the browser, open the QR code link to see the QR code picture.
The [ _compatible ] after the protocol and obfuscation refers to compatibility with the original protocol/obfuscation. "
		echo && echo "==================================================="
	else
		user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
		[[ ${user_total} = "0" ]] && echo -e "${Error} No multiport user found, please check !" && exit 1
		clear && echo "===================================================" && echo
        echo -e "ShadowsocksR account configuration information:" && echo
        echo -e " I P\t : ${Green_font_prefix}${ip}${Font_color_suffix}"
        echo -e "Encrypt\t : ${Green_font_prefix}${method}${Font_color_suffix}"
        echo -e "protocol\t : ${Red_font_prefix}${protocol}${Font_color_suffix}"
        echo -e "Confusion\t : ${Red_font_prefix}${obfs}${Font_color_suffix}"
        echo -e "Device limit: ${Green_font_prefix}${protocol_param}${Font_color_suffix}"
        echo -e "Single thread speed limit: ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"
        echo -e " Port total speed limit: ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}" && echo
		for((integer = ${user_total}; integer >= 1; integer--))
		do
			port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
			password=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $2}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
			ss_ssr_determine
			echo -e ${Separator_1}
            echo -e "port\t : ${Green_font_prefix}${port}${Font_color_suffix}"
            echo -e "password\t : ${Green_font_prefix}${password}${Font_color_suffix}"
			echo -e "${ss_link}"
			#echo -e "${ssr_link}"
		done
		echo -e " ${Green_font_prefix} hint: ${Font_color_suffix}
    In the browser, open the QR code link to see the QR code picture.
    The [ _compatible ] after the protocol and obfuscation refers to compatibility with the original protocol/obfuscation. "
		echo && echo "==================================================="
	fi
}
# set configuration information
Set_config_port(){
	while true
	do
	echo -e "Please enter the ShadowsocksR account port to be set"
	read -e -p "(default: 2333):" ssr_port
	[[ -z "$ssr_port" ]] && ssr_port="2333"
	echo $((${ssr_port}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_port} -ge 1 ]] && [[ ${ssr_port} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "Port: ${Green_font_prefix}${ssr_port}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} Please enter the correct number (1-65535)"
		fi
	else
		echo -e "${Error} Please enter the correct number (1-65535)"
	fi
	done
}
Set_config_password(){
	echo "Please enter the ShadowsocksR account password to be set"
	read -e -p "(default: doub.io):" ssr_password
	[[ -z "${ssr_password}" ]] && ssr_password="doub.io"
	echo && echo ${Separator_1} && echo -e "Password: ${Green_font_prefix}${ssr_password}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_method(){
	echo -e "Please select the ShadowsocksR account to set encryption method
	
 ${Green_font_prefix} 1.${Font_color_suffix} none
 ${Tip} If you use the auth_chain_a protocol, please select none for the encryption method, and the confusion is optional (recommended plain)
 
 ${Green_font_prefix} 2.${Font_color_suffix} rc4
 ${Green_font_prefix} 3.${Font_color_suffix} rc4-md5
 ${Green_font_prefix} 4.${Font_color_suffix} rc4-md5-6
 
 ${Green_font_prefix} 5.${Font_color_suffix} aes-128-ctr
 ${Green_font_prefix} 6.${Font_color_suffix} aes-192-ctr
 ${Green_font_prefix} 7.${Font_color_suffix} aes-256-ctr
 
 ${Green_font_prefix} 8.${Font_color_suffix} aes-128-cfb
 ${Green_font_prefix} 9.${Font_color_suffix} aes-192-cfb
 ${Green_font_prefix}10.${Font_color_suffix} aes-256-cfb
 
 ${Green_font_prefix}11.${Font_color_suffix} aes-128-cfb8
 ${Green_font_prefix}12.${Font_color_suffix} aes-192-cfb8
 ${Green_font_prefix}13.${Font_color_suffix} aes-256-cfb8
 
 ${Green_font_prefix}14.${Font_color_suffix} salsa20
 ${Green_font_prefix}15.${Font_color_suffix} chacha20
 ${Green_font_prefix}16.${Font_color_suffix} chacha20-ietf
 ${Tip} For salsa20/chacha20-* series encryption methods, additional dependencies need to be installed libsodium , otherwise ShadowsocksR will not be able to start!" && echo
	read -e -p "(default: 5. aes-128-ctr):" ssr_method
	[[ -z "${ssr_method}" ]] && ssr_method="5"
	if [[ ${ssr_method} == "1" ]]; then
		ssr_method="none"
	elif [[ ${ssr_method} == "2" ]]; then
		ssr_method="rc4"
	elif [[ ${ssr_method} == "3" ]]; then
		ssr_method="rc4-md5"
	elif [[ ${ssr_method} == "4" ]]; then
		ssr_method="rc4-md5-6"
	elif [[ ${ssr_method} == "5" ]]; then
		ssr_method="aes-128-ctr"
	elif [[ ${ssr_method} == "6" ]]; then
		ssr_method="aes-192-ctr"
	elif [[ ${ssr_method} == "7" ]]; then
		ssr_method="aes-256-ctr"
	elif [[ ${ssr_method} == "8" ]]; then
		ssr_method="aes-128-cfb"
	elif [[ ${ssr_method} == "9" ]]; then
		ssr_method="aes-192-cfb"
	elif [[ ${ssr_method} == "10" ]]; then
		ssr_method="aes-256-cfb"
	elif [[ ${ssr_method} == "11" ]]; then
		ssr_method="aes-128-cfb8"
	elif [[ ${ssr_method} == "12" ]]; then
		ssr_method="aes-192-cfb8"
	elif [[ ${ssr_method} == "13" ]]; then
		ssr_method="aes-256-cfb8"
	elif [[ ${ssr_method} == "14" ]]; then
		ssr_method="salsa20"
	elif [[ ${ssr_method} == "15" ]]; then
		ssr_method="chacha20"
	elif [[ ${ssr_method} == "16" ]]; then
		ssr_method="chacha20-ietf"
	else
		ssr_method="aes-128-ctr"
	fi
	echo && echo ${Separator_1} && echo -e "	encryption : ${Green_font_prefix}${ssr_method}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_protocol(){
	echo -e "Please select the ShadowsocksR account protocol plugin to be set
	
 ${Green_font_prefix}1.${Font_color_suffix} origin
 ${Green_font_prefix}2.${Font_color_suffix} auth_sha1_v4
 ${Green_font_prefix}3.${Font_color_suffix} auth_aes128_md5
 ${Green_font_prefix}4.${Font_color_suffix} auth_aes128_sha1
 ${Green_font_prefix}5.${Font_color_suffix} auth_chain_a
 ${Green_font_prefix}6.${Font_color_suffix} auth_chain_b
 ${Tip} If you use the auth_chain_a protocol, please select none for the encryption method, and the confusion is optional (recommended plain)" && echo
	read -e -p "(default: 2. auth_sha1_v4):" ssr_protocol
	[[ -z "${ssr_protocol}" ]] && ssr_protocol="2"
	if [[ ${ssr_protocol} == "1" ]]; then
		ssr_protocol="origin"
	elif [[ ${ssr_protocol} == "2" ]]; then
		ssr_protocol="auth_sha1_v4"
	elif [[ ${ssr_protocol} == "3" ]]; then
		ssr_protocol="auth_aes128_md5"
	elif [[ ${ssr_protocol} == "4" ]]; then
		ssr_protocol="auth_aes128_sha1"
	elif [[ ${ssr_protocol} == "5" ]]; then
		ssr_protocol="auth_chain_a"
	elif [[ ${ssr_protocol} == "6" ]]; then
		ssr_protocol="auth_chain_b"
	else
		ssr_protocol="auth_sha1_v4"
	fi
	echo && echo ${Separator_1} && echo -e " Enter : ${Green_font_prefix}${ssr_protocol}${Font_color_suffix}" && echo ${Separator_1} && echo
	if [[ ${ssr_protocol} != "origin" ]]; then
		if [[ ${ssr_protocol} == "auth_sha1_v4" ]]; then
			read -e -p "Whether to set the protocol plugin to be compatible with the original version(_compatible)？[Y/n]" ssr_protocol_yn
			[[ -z "${ssr_protocol_yn}" ]] && ssr_protocol_yn="y"
			[[ $ssr_protocol_yn == [Yy] ]] && ssr_protocol=${ssr_protocol}"_compatible"
			echo
		fi
	fi
}
Set_config_obfs(){
	echo -e "Please select the ShadowsocksR account you want to set up Obfuscation plugin
	
 ${Green_font_prefix}1.${Font_color_suffix} plain
 ${Green_font_prefix}2.${Font_color_suffix} http_simple
 ${Green_font_prefix}3.${Font_color_suffix} http_post
 ${Green_font_prefix}4.${Font_color_suffix} random_head
 ${Green_font_prefix}5.${Font_color_suffix} tls1.2_ticket_auth
 ${Tip} If you use ShadowsocksR to accelerate the game, please choose obfuscated compatible original or plain obfuscation, and then the client chooses plain, otherwise it will increase the delay!
 In addition, if you choose tls1.2_ticket_auth, then the client can choose tls1.2_ticket_fastauth, so that it can pretend without increasing the delay!
 If you are building in popular areas such as Japan and the United States, then choosing plain may be less likely to be confused by walls!" && echo
	read -e -p "(default: 1. plain):" ssr_obfs
	[[ -z "${ssr_obfs}" ]] && ssr_obfs="1"
	if [[ ${ssr_obfs} == "1" ]]; then
		ssr_obfs="plain"
	elif [[ ${ssr_obfs} == "2" ]]; then
		ssr_obfs="http_simple"
	elif [[ ${ssr_obfs} == "3" ]]; then
		ssr_obfs="http_post"
	elif [[ ${ssr_obfs} == "4" ]]; then
		ssr_obfs="random_head"
	elif [[ ${ssr_obfs} == "5" ]]; then
		ssr_obfs="tls1.2_ticket_auth"
	else
		ssr_obfs="plain"
	fi
	echo && echo ${Separator_1} && echo -e " Type : ${Green_font_prefix}${ssr_obfs}${Font_color_suffix}" && echo ${Separator_1} && echo
	if [[ ${ssr_obfs} != "plain" ]]; then
			read -e -p "Do you set the obfuscation plugin to be compatible with the original version (_compatible)? [Y/n]" ssr_obfs_yn
			[[ -z "${ssr_obfs_yn}" ]] && ssr_obfs_yn="y"
			[[ $ssr_obfs_yn == [Yy] ]] && ssr_obfs=${ssr_obfs}"_compatible"
			echo
	fi
}
Set_config_protocol_param(){
	while true
	do
	echo -e "Please enter the number of devices to be limited by the ShadowsocksR account to be set (${Green_font_prefix} auth_* series protocols are not compatible with the original version only valid ${Font_color_suffix})"
	echo -e "${Tip} device limit: the number of clients that can be connected to each port at the same time (multi-port mode, each port is calculated independently), at least 2 are recommended."
	read -e -p "(default: unlimited):" ssr_protocol_param
	[[ -z "$ssr_protocol_param" ]] && ssr_protocol_param="" && echo && break
	echo $((${ssr_protocol_param}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_protocol_param} -ge 1 ]] && [[ ${ssr_protocol_param} -le 9999 ]]; then
			echo && echo ${Separator_1} && echo -e " Environment : ${Green_font_prefix}${ssr_protocol_param}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} please enter the correct number (1-9999)"
		fi
	else
		echo -e "${Error} please enter the correct number (1-9999)"
	fi
	done
}
Set_config_speed_limit_per_con(){
	while true
	do
	echo -e "Please enter the upper limit of the single thread speed limit for each port to be set (unit: KB/S)"
	echo -e "${Tip} single thread speed limit: the upper limit of the speed limit of a single thread per port, multi-threading is invalid."
	read -e -p "(default: unlimited):" ssr_speed_limit_per_con
	[[ -z "$ssr_speed_limit_per_con" ]] && ssr_speed_limit_per_con=0 && echo && break
	echo $((${ssr_speed_limit_per_con}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_con} -ge 1 ]] && [[ ${ssr_speed_limit_per_con} -le 131072 ]]; then
			echo && echo ${Separator_1} && echo -e " Environment : ${Green_font_prefix}${ssr_speed_limit_per_con}KB/S${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} please enter the correct number (1-131072)"
		fi
	else
		echo -e "${Error} please enter the correct number (1-131072)"
	fi
	done
}
Set_config_speed_limit_per_user(){
	while true
	do
	echo
	echo -e "Please enter the total speed limit of each port to be set (unit: KB/S)"
	echo -e "${Tip} total port speed limit: the upper limit of the total speed limit of each port, and the overall speed limit of a single port."
	read -e -p "(default: unlimited):" ssr_speed_limit_per_user
	[[ -z "$ssr_speed_limit_per_user" ]] && ssr_speed_limit_per_user=0 && echo && break
	echo $((${ssr_speed_limit_per_user}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_user} -ge 1 ]] && [[ ${ssr_speed_limit_per_user} -le 131072 ]]; then
			echo && echo ${Separator_1} && echo -e " Environment : ${Green_font_prefix}${ssr_speed_limit_per_user} KB/S${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} please enter the correct number (1-131072)"
		fi
	else
		echo -e "${Error} please enter the correct number (1-131072)"
	fi
	done
}
Set_config_all(){
	Set_config_port
	Set_config_password
	Set_config_method
	Set_config_protocol
	Set_config_obfs
	Set_config_protocol_param
	Set_config_speed_limit_per_con
	Set_config_speed_limit_per_user
}
# Modify configuration information
Modify_config_port(){
	sed -i 's/"server_port": '"$(echo ${port})"'/"server_port": '"$(echo ${ssr_port})"'/g' ${config_user_file}
}
Modify_config_password(){
	sed -i 's/"password": "'"$(echo ${password})"'"/"password": "'"$(echo ${ssr_password})"'"/g' ${config_user_file}
}
Modify_config_method(){
	sed -i 's/"method": "'"$(echo ${method})"'"/"method": "'"$(echo ${ssr_method})"'"/g' ${config_user_file}
}
Modify_config_protocol(){
	sed -i 's/"protocol": "'"$(echo ${protocol})"'"/"protocol": "'"$(echo ${ssr_protocol})"'"/g' ${config_user_file}
}
Modify_config_obfs(){
	sed -i 's/"obfs": "'"$(echo ${obfs})"'"/"obfs": "'"$(echo ${ssr_obfs})"'"/g' ${config_user_file}
}
Modify_config_protocol_param(){
	sed -i 's/"protocol_param": "'"$(echo ${protocol_param})"'"/"protocol_param": "'"$(echo ${ssr_protocol_param})"'"/g' ${config_user_file}
}
Modify_config_speed_limit_per_con(){
	sed -i 's/"speed_limit_per_con": '"$(echo ${speed_limit_per_con})"'/"speed_limit_per_con": '"$(echo ${ssr_speed_limit_per_con})"'/g' ${config_user_file}
}
Modify_config_speed_limit_per_user(){
	sed -i 's/"speed_limit_per_user": '"$(echo ${speed_limit_per_user})"'/"speed_limit_per_user": '"$(echo ${ssr_speed_limit_per_user})"'/g' ${config_user_file}
}
Modify_config_connect_verbose_info(){
	sed -i 's/"connect_verbose_info": '"$(echo ${connect_verbose_info})"'/"connect_verbose_info": '"$(echo ${ssr_connect_verbose_info})"'/g' ${config_user_file}
}
Modify_config_all(){
	Modify_config_port
	Modify_config_password
	Modify_config_method
	Modify_config_protocol
	Modify_config_obfs
	Modify_config_protocol_param
	Modify_config_speed_limit_per_con
	Modify_config_speed_limit_per_user
}
Modify_config_port_many(){
	sed -i 's/"'"$(echo ${port})"'":/"'"$(echo ${ssr_port})"'":/g' ${config_user_file}
}
Modify_config_password_many(){
	sed -i 's/"'"$(echo ${password})"'"/"'"$(echo ${ssr_password})"'"/g' ${config_user_file}
}
# write configuration information
Write_configuration(){
	cat > ${config_user_file}<<-EOF
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "server_port": ${ssr_port},
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "password": "${ssr_password}",
    "method": "${ssr_method}",
    "protocol": "${ssr_protocol}",
    "protocol_param": "${ssr_protocol_param}",
    "obfs": "${ssr_obfs}",
    "obfs_param": "",
    "speed_limit_per_con": ${ssr_speed_limit_per_con},
    "speed_limit_per_user": ${ssr_speed_limit_per_user},

    "additional_ports" : {},
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 0,
    "redirect": "",
    "fast_open": false
}
EOF
}
Write_configuration_many(){
	cat > ${config_user_file}<<-EOF
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "port_password":{
        "${ssr_port}":"${ssr_password}"
    },
    "method": "${ssr_method}",
    "protocol": "${ssr_protocol}",
    "protocol_param": "${ssr_protocol_param}",
    "obfs": "${ssr_obfs}",
    "obfs_param": "",
    "speed_limit_per_con": ${ssr_speed_limit_per_con},
    "speed_limit_per_user": ${ssr_speed_limit_per_user},

    "additional_ports" : {},
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 0,
    "redirect": "",
    "fast_open": false
}
EOF
}
Check_python(){
	python_ver=`python -h`
	if [[ -z ${python_ver} ]]; then
		echo -e "${Info} does not have Python installed, start installing..."
		if [[ ${release} == "centos" ]]; then
			yum install -y python
		else
			apt-get install -y python
		fi
	fi
}
Centos_yum(){
	yum update
	cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
	if [[ $? = 0 ]]; then
		yum install -y vim unzip net-tools
	else
		yum install -y vim unzip
	fi
}
Debian_apt(){
	apt-get update
	cat /etc/issue |grep 9\..*>/dev/null
	if [[ $? = 0 ]]; then
		apt-get install -y vim unzip net-tools
	else
		apt-get install -y vim unzip
	fi
}
# Download ShadowsocksR
Download_SSR(){
	cd "/usr/local/"
	wget -N --no-check-certificate "https://github.com/ToyoDAdoubiBackup/shadowsocksr/archive/manyuser.zip"
	#git config --global http.sslVerify false
	#env GIT_SSL_NO_VERIFY=true git clone -b manyuser https://github.com/ToyoDAdoubiBackup/shadowsocksr.git
	#[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR server download failed!" && exit 1
	[[ ! -e "manyuser.zip" ]] && echo -e "${Error} ShadowsocksR server zip download failed!" && rm -rf manyuser.zip && exit 1
	unzip "manyuser.zip"
	[[ ! -e "/usr/local/shadowsocksr-manyuser/" ]] && echo -e "${Error} ShadowsocksR server decompression failed!" && rm -rf manyuser.zip && exit 1
	mv "/usr/local/shadowsocksr-manyuser/" "/usr/local/shadowsocksr/"
	[[ ! -e "/usr/local/shadowsocksr/" ]] && echo -e "${Error} ShadowsocksR server rename failed!" && rm -rf manyuser.zip && rm -rf "/usr/local/ shadowsocksr-manyuser/" && exit 1
	rm -rf manyuser.zip
	[[ -e ${config_folder} ]] && rm -rf ${config_folder}
	mkdir ${config_folder}
	[[ ! -e ${config_folder} ]] && echo -e "${Error} ShadowsocksR configuration file folder creation failed!" && exit 1
	echo -e "${Info} ShadowsocksR server download complete!"
}
Service_SSR(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/ssr_centos -O /etc/init.d/ssr; then
			echo -e "${Error} ShadowsocksR service management script download failed!" && exit 1
		fi
		chmod +x /etc/init.d/ssr
		chkconfig --add ssr
		chkconfig ssr on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/ssr_debian -O /etc/init.d/ssr; then
			echo -e "${Error} ShadowsocksR service management script download failed!" && exit 1
		fi
		chmod +x /etc/init.d/ssr
		update-rc.d -f ssr defaults
	fi
	echo -e "${Info} ShadowsocksR service management script download complete!"
}
# Install JQ parser
JQ_install(){
	if [[ ! -e ${jq_file} ]]; then
		cd "${ssr_folder}"
		if [[ ${bit} = "x86_64" ]]; then
			mv "jq-linux64" "jq"
			#wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
		else
			mv "jq-linux32" "jq"
			#wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
		fi
		[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ parser rename failed, please check!" && exit 1
		chmod +x ${jq_file}
		echo -e "${Info} JQ parser installation completed, continue..."
	else
		echo -e "${Info} JQ parser installed, continue..."
	fi
}
# install dependencies
Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		cents_yum
	else
		Debian_apt
	fi
	[[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} depends on unzip (unzipping the compressed package), the installation failed, most of it is a problem with the package source, please check!" && exit 1
	Check_python
	#echo "nameserver 8.8.8.8" > /etc/resolv.conf
	#echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}
Install_SSR(){
	check_root
	[[ -e ${config_user_file} ]] && echo -e "${Error} ShadowsocksR configuration file already exists, please check (if installation fails or there is an old version, please uninstall first) !" && exit 1
	[[ -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR folder already exists, please check (if installation failed or there is an old version, please uninstall first) !" && exit 1
	echo -e "${Info} starts setting up ShadowsocksR account configuration..."
	Set_config_all
	echo -e "${Info} starts installing/configuring ShadowsocksR dependencies..."
	Installation_dependency
	echo -e "${Info} starts downloading/installing ShadowsocksR files..."
	Download_SSR
	echo -e "${Info} start downloading/installing ShadowsocksR service script (init)..."
	Service_SSR
	echo -e "${Info} start downloading/installing JSNO parser JQ..."
	JQ_install
	echo -e "${Info} starts writing ShadowsocksR configuration files..."
	Write_configuration
	echo -e "${Info} start setting up iptables firewall..."
	Set_iptables
	echo -e "${Info} starts adding iptables firewall rules..."
	Add_iptables
	echo -e "${Info} start saving iptables firewall rules..."
	Save_iptables
	echo -e "${Info} All steps are installed, start ShadowsocksR server..."
	Start_SSR
}
Update_SSR(){
	SSR_installation_status
	echo -e "This function is temporarily disabled due to Powa's suspension of updating the ShadowsocksR server."
	#cd ${ssr_folder}
	#git pull
	#Restart_SSR
}
Uninstall_SSR(){
	[[ ! -e ${config_user_file} ]] && [[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR is not installed, please check!" && exit 1
	echo "Are you sure you want to uninstall ShadowsocksR? [y/N]" && echo
	read -e -p "(default: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z "${PID}" ]] && kill -9 ${PID}
		if [[ -z "${now_mode}" ]]; then
			port=`${jq_file} '.server_port' ${config_user_file}`
			del_iptables
			Save_iptables
		else
			user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
				del_iptables
			done
			Save_iptables
		fi
		if [[ ${release} = "centos" ]]; then
			chkconfig --del ssr
		else
			update-rc.d -f ssr remove
		fi
		rm -rf ${ssr_folder} && rm -rf ${config_folder} && rm -rf /etc/init.d/ssr
		echo && echo "Uninstallation of ShadowsocksR completed!" && echo
	else
		echo && echo "Uninstall cancelled..." && echo
	fi
}
Check_Libsodium_ver(){
	echo -e "${Info} started getting the latest version of libsodium..."
	Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
	[[ -z ${Libsodiumr_ver} ]] && Libsodiumr_ver=${Libsodiumr_ver_backup}
	echo -e "${Info} libsodium latest version is ${Green_font_prefix}${Libsodiumr_ver}${Font_color_suffix} !"
}
Install_Libsodium(){
	if [[ -e ${Libsodiumr_file} ]]; then
		echo -e "${Error} libsodium is already installed, do you want to overwrite the installation (update)? [y/N]"
		read -e -p "(default: n):" yn
		[[ -z ${in} ]] && in="n"
		if [[ ${in} == [Nn] ]]; then
			echo "Canceled..." && exit 1
		fi
	else
		echo -e "${Info} libsodium not installed, start installing..."
	fi
	Check_Libsodium_ver
	if [[ ${release} == "centos" ]]; then
		yum update
		echo -e "${Info} install dependencies..."
		yum -y groupinstall "Development Tools"
		echo -e "${Info} download..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}-RELEASE/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} unpack..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} compile and install..."
		./configure --disable-maintainer-mode && make -j2 && make install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	else
		apt-get update
		echo -e "${Info} install dependencies..."
		apt-get install -y build-essential
		echo -e "${Info} download..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}-RELEASE/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} unpack..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} compile and install..."
		./configure --disable-maintainer-mode && make -j2 && make install
	fi
	ldconfig
	cd .. && rm -rf libsodium-${Libsodiumr_ver}.tar.gz && rm -rf libsodium-${Libsodiumr_ver}
	[[ ! -e ${Libsodiumr_file} ]] && echo -e "${Error} libsodium installation failed!" && exit 1
	echo && echo -e "${Info} libsodium installed successfully!" && echo
}
# show connection info
debian_View_user_connection_info(){
	format_1=$1
	if [[ -z "${now_mode}" ]]; then
		now_mode="single port" && user_total="1"
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_port=`${jq_file} '.server_port' ${config_user_file}`
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep ":${user_port} " |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" `
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${format_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_list_all="Port: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t Total link IP: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t Current link IP: ${Green_font_prefix}$ {user_IP}${Font_color_suffix}\n"
		user_IP=""
		echo -e "Current mode: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} Total link IP: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix}"
		echo -e "${user_list_all}"
	else
		now_mode="multiple ports" && user_total=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' | wc -l`
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_list_all=""
		for((integer = ${user_total}; integer >= 1; integer--))
		do
			user_port=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' |awk -F ":" '{print $1}' |sed -n "${integer}p" |sed -r 's/.*\"(.+)\".*/\1/'`
			user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep "${user_port}" |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
			if [[ -z ${user_IP_1} ]]; then
				user_IP_total="0"
			else
				user_IP_total=`echo -e "${user_IP_1}"|wc -l`
				if [[ ${format_1} == "IP_address" ]]; then
					get_IP_address
				else
					user_IP=`echo -e "\n${user_IP_1}"`
				fi
			fi
			user_list_all=${user_list_all}"port: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t Total number of link IPs: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t 当前链接IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
			user_IP=""
		done
		echo -e "Current mode: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} Total number of users: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Total number of link IPs: ${Green_background_prefix} "${IP_total }" ${Font_color_suffix} "
		echo -e "${user_list_all}"
	fi
}
centos_View_user_connection_info(){
	format_1=$1
	if [[ -z "${now_mode}" ]]; then
		now_mode="single port" && user_total="1"
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' |grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_port=`${jq_file} '.server_port' ${config_user_file}`
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' |grep ":${user_port} " | grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${format_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_list_all="Port: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t Total link IP: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t Current link IP: ${Green_font_prefix}$ {user_IP}${Font_color_suffix}\n"
		user_IP=""
		echo -e "Current mode: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} Total link IP: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix}"
		echo -e "${user_list_all}"
	else
		now_mode="multiple ports" && user_total=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' | wc -l`
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' | grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_list_all=""
		for((integer = 1; integer <= ${user_total}; integer++))
		do
			user_port=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' |awk -F ":" '{print $1}' |sed -n "${integer}p" |sed -r 's/.*\"(.+)\".*/\1/'`
			user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' |grep "${user_port}"|grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" `
			if [[ -z ${user_IP_1} ]]; then
				user_IP_total="0"
			else
				user_IP_total=`echo -e "${user_IP_1}"|wc -l`
				if [[ ${format_1} == "IP_address" ]]; then
					get_IP_address
				else
					user_IP=`echo -e "\n${user_IP_1}"`
				fi
			fi
			user_list_all=${user_list_all}"port: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t 链接IP总数: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t 当前链接IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
			user_IP=""
		done
		echo -e "Current mode: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} Total number of users: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Total number of link IPs: ${Green_background_prefix} "${IP_total }" ${Font_color_suffix} "
		echo -e "${user_list_all}"
	fi
}
View_user_connection_info(){
	SSR_installation_status
	echo && echo -e "Please select the format to display:
 ${Green_font_prefix}1.${Font_color_suffix} display IP format
 ${Green_font_prefix}2.${Font_color_suffix} Display IP+IP attribution format" && echo
	read -e -p "(default: 1):" ssr_connection_info
	[[ -z "${ssr_connection_info}" ]] && ssr_connection_info="1"
	if [[ ${ssr_connection_info} == "1" ]]; then
		View_user_connection_info_1 ""
	elif [[ ${ssr_connection_info} == "2" ]]; then
		echo -e "${Tip} detects the IP location (ipip.net), if there are more IPs, it may take a long time..."
		View_user_connection_info_1 "IP_address"
	else
		echo -e "${Error} please enter the correct number (1-2)" && exit 1
	fi
}
View_user_connection_info_1(){
	format=$1
	if [[ ${release} = "centos" ]]; then
		cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
		if [[ $? = 0 ]]; then
			debian_View_user_connection_info "$format"
		else
			centos_View_user_connection_info "$format"
		fi
	else
		debian_View_user_connection_info "$format"
	fi
}
get_IP_address(){
	#echo "user_IP_1=${user_IP_1}"
	if [[ ! -z ${user_IP_1} ]]; then
	#echo "user_IP_total=${user_IP_total}"
		for((integer_1 = ${user_IP_total}; integer_1 >= 1; integer_1--))
		do
			IP=`echo "${user_IP_1}" |sed -n "$integer_1"p`
			#echo "IP=${IP}"
			IP_address=`wget -qO- -t1 -T2 http://freeapi.ipip.net/${IP}|sed 's/\"//g;s/,//g;s/\[//g;s/\]//g'`
			#echo "IP_address=${IP_address}"
			user_IP="${user_IP}\n${IP}(${IP_address})"
			#echo "user_IP=${user_IP}"
			sleep 1s
		done
	fi
}
# Modify user configuration
Modify_Config(){
	SSR_installation_status
	if [[ -z "${now_mode}" ]]; then
		echo && echo -e "Current mode: single port, what are you doing?
 ${Green_font_prefix}1.${Font_color_suffix} Modify user port
 ${Green_font_prefix}2.${Font_color_suffix} Modify user password
 ${Green_font_prefix}3.${Font_color_suffix} Modify encryption method
 ${Green_font_prefix}4.${Font_color_suffix} Modify protocol plugin
 ${Green_font_prefix}5.${Font_color_suffix} Modify the obfuscation plugin
 ${Green_font_prefix}6.${Font_color_suffix} Modify device limit
 ${Green_font_prefix}7.${Font_color_suffix} Modify single thread speed limit
 ${Green_font_prefix}8.${Font_color_suffix} Modify the total port speed limit
 ${Green_font_prefix}9.${Font_color_suffix} Modify all configurations" && echo
		read -e -p "(default: cancel):" ssr_modify
		[[ -z "${ssr_modify}" ]] && echo "Canceled..." && exit 1
		Get_User
		if [[ ${ssr_modify} == "1" ]]; then
			Set_config_port
			Modify_config_port
			Add_iptables
			del_iptables
			Save_iptables
		elif [[ ${ssr_modify} == "2" ]]; then
			Set_config_password
			Modify_config_password
		elif [[ ${ssr_modify} == "3" ]]; then
			Set_config_method
			Modify_config_method
		elif [[ ${ssr_modify} == "4" ]]; then
			Set_config_protocol
			Modify_config_protocol
		elif [[ ${ssr_modify} == "5" ]]; then
			Set_config_obfs
			Modify_config_obfs
		elif [[ ${ssr_modify} == "6" ]]; then
			Set_config_protocol_param
			Modify_config_protocol_param
		elif [[ ${ssr_modify} == "7" ]]; then
			Set_config_speed_limit_per_con
			Modify_config_speed_limit_per_con
		elif [[ ${ssr_modify} == "8" ]]; then
			Set_config_speed_limit_per_user
			Modify_config_speed_limit_per_user
		elif [[ ${ssr_modify} == "9" ]]; then
			Set_config_all
			Modify_config_all
		else
			echo -e "${Error} please enter the correct number (1-9)" && exit 1
		fi
	else
		echo && echo -e "Current mode: Multiport, what are you doing?
 ${Green_font_prefix}1.${Font_color_suffix} add user configuration
 ${Green_font_prefix}2.${Font_color_suffix} delete user configuration
 ${Green_font_prefix}3.${Font_color_suffix} Modify user configuration
——————————
 ${Green_font_prefix}4.${Font_color_suffix} Modify encryption method
 ${Green_font_prefix}5.${Font_color_suffix} Modify protocol plugin
 ${Green_font_prefix}6.${Font_color_suffix} Modify the obfuscation plugin
 ${Green_font_prefix}7.${Font_color_suffix} Modify device limit
 ${Green_font_prefix}8.${Font_color_suffix} Modify single thread speed limit
 ${Green_font_prefix}9.${Font_color_suffix} Modify the total port speed limit
 ${Green_font_prefix}10.${Font_color_suffix}Modify all configurations" && echo
		read -e -p "(default: cancel):" ssr_modify
		[[ -z "${ssr_modify}" ]] && echo "Canceled..." && exit 1
		Get_User
		if [[ ${ssr_modify} == "1" ]]; then
			Add_multi_port_user
		elif [[ ${ssr_modify} == "2" ]]; then
			Del_multi_port_user
		elif [[ ${ssr_modify} == "3" ]]; then
			Modify_multi_port_user
		elif [[ ${ssr_modify} == "4" ]]; then
			Set_config_method
			Modify_config_method
		elif [[ ${ssr_modify} == "5" ]]; then
			Set_config_protocol
			Modify_config_protocol
		elif [[ ${ssr_modify} == "6" ]]; then
			Set_config_obfs
			Modify_config_obfs
		elif [[ ${ssr_modify} == "7" ]]; then
			Set_config_protocol_param
			Modify_config_protocol_param
		elif [[ ${ssr_modify} == "8" ]]; then
			Set_config_speed_limit_per_con
			Modify_config_speed_limit_per_con
		elif [[ ${ssr_modify} == "9" ]]; then
			Set_config_speed_limit_per_user
			Modify_config_speed_limit_per_user
		elif [[ ${ssr_modify} == "10" ]]; then
			Set_config_method
			Set_config_protocol
			Set_config_obfs
			Set_config_protocol_param
			Set_config_speed_limit_per_con
			Set_config_speed_limit_per_user
			Modify_config_method
			Modify_config_protocol
			Modify_config_obfs
			Modify_config_protocol_param
			Modify_config_speed_limit_per_con
			Modify_config_speed_limit_per_user
		else
			echo -e "${Error} please enter the correct number (1-9)" && exit 1
		fi
	fi
	Restart_SSR
}
# show multiport user configuration
List_multi_port_user(){
	user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
	[[ ${user_total} = "0" ]] && echo -e "${Error} No multiport user found, please check!" && exit 1
	user_list_all=""
	for((integer = ${user_total}; integer >= 1; integer--))
	do
		user_port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
		user_password=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $2}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
		user_list_all=${user_list_all}"Port: "${user_port}" Password: "${user_password}"\n"
	done
	echo && echo -e "Total users ${Green_font_prefix}"${user_total}"${Font_color_suffix}"
	echo -e ${user_list_all}
}
# Add multi-port user configuration
Add_multi_port_user(){
	Set_config_port
	Set_config_password
	sed -i "8 i \"        \"${ssr_port}\":\"${ssr_password}\"," ${config_user_file}
	sed -i "8s/^\"//" ${config_user_file}
	Add_iptables
	Save_iptables
	echo -e "${Info} multi-port user added ${Green_font_prefix}[port: ${ssr_port} , password: ${ssr_password}]${Font_color_suffix} "
}
# Modify multi-port user configuration
Modify_multi_port_user(){
	List_multi_port_user
	echo && echo -e "Please enter the user port to be modified"
	read -e -p "(default: cancel):" modify_user_port
	[[ -z "${modify_user_port}" ]] && echo -e "Cancelled..." && exit 1
	del_user=`cat ${config_user_file}|grep '"'"${modify_user_port}"'"'`
	if [[ ! -z "${del_user}" ]]; then
		port="${modify_user_port}"
		password=`echo -e ${del_user}|awk -F ":" '{print $NF}'|sed -r 's/.*\"(.+)\".*/\1/'`
		Set_config_port
		Set_config_password
		sed -i 's/"'$(echo ${port})'":"'$(echo ${password})'"/"'$(echo ${ssr_port})'":"'$(echo ${ssr_password})'"/g' ${config_user_file}
		del_iptables
		Add_iptables
		Save_iptables
		echo -e "${Inof} multi-port user modification done ${Green_font_prefix}[old: ${modify_user_port} ${password} , new: ${ssr_port} ${ssr_password}]${Font_color_suffix} "
	else
		echo -e "${Error} Please enter the correct port!" && exit 1
	fi
}
# Delete multi-port user configuration
Del_multi_port_user(){
	List_multi_port_user
	user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
	[[ "${user_total}" = "1" ]] && echo -e "${Error} There is only 1 multi-port user left and cannot be deleted!" && exit 1
	echo -e "Please enter the user port to delete"
	read -e -p "(default: cancel):" del_user_port
	[[ -z "${del_user_port}" ]] && echo -e "Cancelled..." && exit 1
	del_user=`cat ${config_user_file}|grep '"'"${del_user_port}"'"'`
	if [[ ! -z ${del_user} ]]; then
		port=${del_user_port}
		del_iptables
		Save_iptables
		del_user_determine=`echo ${del_user:((${#del_user} - 1))}`
		if [[ ${del_user_determine} != "," ]]; then
			del_user_num=$(sed -n -e "/${port}/=" ${config_user_file})
			echo $((${ssr_protocol_param}+0)) &>/dev/null
			del_user_num=$(echo $((${del_user_num}-1)))
			sed -i "${del_user_num}s/,//g" ${config_user_file}
		fi
		sed -i "/${port}/d" ${config_user_file}
		echo -e "${Info} multi-port user deletion completed ${Green_font_prefix} ${del_user_port} ${Font_color_suffix} "
	else
		echo "${Error} Please enter the correct port!" && exit 1
	fi
}
# Manually modify user configuration
Manually_Modify_Config(){
	SSR_installation_status
	port=`${jq_file} '.server_port' ${config_user_file}`
	vi ${config_user_file}
	if [[ -z "${now_mode}" ]]; then
		ssr_port=`${jq_file} '.server_port' ${config_user_file}`
		del_iptables
		Add_iptables
	fi
	Restart_SSR
}
# switch port mode
Port_mode_switching(){
	SSR_installation_status
	if [[ -z "${now_mode}" ]]; then
		echo && echo -e "Current mode: ${Green_font_prefix}Single port ${Font_color_suffix}" && echo
		echo -e "Are you sure you want to switch to multiport mode? [y/N]"
		read -e -p "(default: n):" mode_yn
		[[ -z ${mode_yn} ]] && mode_yn="n"
		if [[ ${mode_yn} == [Yy] ]]; then
			port=`${jq_file} '.server_port' ${config_user_file}`
			Set_config_all
			Write_configuration_many
			del_iptables
			Add_iptables
			Save_iptables
			Restart_SSR
		else
			echo && echo "Cancelled..." && echo
		fi
	else
		echo && echo -e "Current mode: ${Green_font_prefix}Multiport ${Font_color_suffix}" && echo
		echo -e "Are you sure you want to switch to single port mode? [y/N]"
		read -e -p "(default: n):" mode_yn
		[[ -z ${mode_yn} ]] && mode_yn="n"
		if [[ ${mode_yn} == [Yy] ]]; then
			user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
				del_iptables
			done
			Set_config_all
			Write_configuration
			Add_iptables
			Restart_SSR
		else
			echo && echo "Cancelled..." && echo
		fi
	fi
}
Start_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR is running!" && exit 1
	/etc/init.d/ssr start
	check_pid
	[[ ! -z ${PID} ]] && View_User
}
Stop_SSR(){
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} ShadowsocksR is not running!" && exit 1
	/etc/init.d/ssr stop
}
Restart_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssr stop
	/etc/init.d/ssr start
	check_pid
	[[ ! -z ${PID} ]] && View_User
}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} ShadowsocksR log file does not exist!" && exit 1
	echo && echo -e "${Tip} Press ${Red_font_prefix}Ctrl+C${Font_color_suffix} to stop viewing the log" && echo -e "If you need to view the complete log content, please use ${Red_font_prefix}cat ${ssr_log_file}$ {Font_color_suffix} command." && echo
	tail -f ${ssr_log_file}
}
# sharp speed
Configure_Server_Speeder(){
	echo && echo -e "What are you doing?
 ${Green_font_prefix}1.${Font_color_suffix} install Swift
 ${Green_font_prefix}2.${Font_color_suffix} Uninstall Sharpspeed
————————
 ${Green_font_prefix}3.${Font_color_suffix} enable sharp speed
 ${Green_font_prefix}4.${Font_color_suffix} stop sharpening
 ${Green_font_prefix}5.${Font_color_suffix} restart sharp speed
 ${Green_font_prefix}6.${Font_color_suffix} View sharp speed status
 
 Note: Sharp Speed ​​and LotServer cannot be installed/started at the same time! " && echo
	read -e -p "(default: cancel):" server_speeder_num
	[[ -z "${server_speeder_num}" ]] && echo "Canceled..." && exit 1
	if [[ ${server_speeder_num} == "1" ]]; then
		Install_ServerSpeeder
	elif [[ ${server_speeder_num} == "2" ]]; then
		Server_Speeder_installation_status
		Uninstall_ServerSpeeder
	elif [[ ${server_speeder_num} == "3" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} start
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "4" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} stop
	elif [[ ${server_speeder_num} == "5" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} restart
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "6" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} status
	else
		echo -e "${Error} please enter the correct number (1-6)" && exit 1
	fi
}
Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} Server Speeder installed!" && exit 1
	cd /root
	#borrowing the happy version of 91yun.rog's sharp speed
	wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder.sh
	[[ ! -e "serverspeeder.sh" ]] && echo -e "${Error} Swift installation script download failed!" && exit 1
	bash serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /root/serverspeeder.sh
		rm -rf /root/91yunserverspeeder
		rm -rf /root/91yunserverspeeder.tar.gz
		echo -e "${Info} Server Speeder installation completed!" && exit 1
	else
		echo -e "${Error} Server Speeder installation failed!" && exit 1
	fi
}
Uninstall_ServerSpeeder(){
	echo "Are you sure you want to uninstall Server Speeder? [y/N]" && echo
	read -e -p "(default: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Enter..." && exit
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "Server Speeder uninstall completed!" && echo
	fi
}
# LotServer
Configure_LotServer(){
	echo && echo -e "What are you doing?
 ${Green_font_prefix}1.${Font_color_suffix} Enable LotServer
 ${Green_font_prefix}2.${Font_color_suffix} uninstall LotServer
————————
 ${Green_font_prefix}3.${Font_color_suffix} Local LotServer
 ${Green_font_prefix}4.${Font_color_suffix} Enable LotServer
 ${Green_font_prefix}5.${Font_color_suffix} reboot LotServer
 ${Green_font_prefix}6.${Font_color_suffix} View LotServer status
 
 Note: Sharp Speed ​​and LotServer cannot be installed/started at the same time! " && echo
	read -e -p "(default: cancel):" lotserver_num
	[[ -z "${lotserver_num}" ]] && echo "Canceled..." && exit 1
	if [[ ${lotserver_num} == "1" ]]; then
		Install_LotServer
	elif [[ ${lotserver_num} == "2" ]]; then
		LotServer_installation_status
		Uninstall_LotServer
	elif [[ ${lotserver_num} == "3" ]]; then
		LotServer_installation_status
		${LotServer_file} start
		${LotServer_file} status
	elif [[ ${lotserver_num} == "4" ]]; then
		LotServer_installation_status
		${LotServer_file} stop
	elif [[ ${lotserver_num} == "5" ]]; then
		LotServer_installation_status
		${LotServer_file} restart
		${LotServer_file} status
	elif [[ ${lotserver_num} == "6" ]]; then
		LotServer_installation_status
		${LotServer_file} status
	else
		echo -e "${Error} please enter the correct number (1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer installed!" && exit 1
	#Github: https://github.com/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh"
	[[ ! -e "/tmp/appex.sh" ]] && echo -e "${Error} LotServer installation script download failed!" && exit 1
	bash /tmp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo -e "${Info} LotServer installation completed!" && exit 1
	else
		echo -e "${Error} LotServer installation failed!" && exit 1
	fi
}
Uninstall_LotServer(){
	echo "Are you sure you want to uninstall LotServer? [y/N]" && echo
	read -e -p "(default: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Enter..." && exit
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
		echo && echo "LotServer uninstall completed!" && echo
	fi
}
# BBR
Configure_BBR(){
	echo && echo -e " What are you going to do?
	
 ${Green_font_prefix}1.${Font_color_suffix} Enable BBR
————————
 ${Green_font_prefix}2.${Font_color_suffix} Enter BBR
 ${Green_font_prefix}3.${Font_color_suffix} New BBR
 ${Green_font_prefix}4.${Font_color_suffix} View BBR status" && echo
echo -e "${Green_font_prefix} [Please note before installation] ${Font_color_suffix}
1. To install and open BBR, the kernel needs to be replaced, and there are risks such as replacement failure (cannot boot after restarting)
2. This script only supports kernel replacement for Debian / Ubuntu systems, OpenVZ and Docker do not support kernel replacement
3. Debian will prompt [whether to terminate the uninstallation of the kernel] during the kernel replacement process, please select ${Green_font_prefix} NO ${Font_color_suffix}" && echo
	read -e -p "(default: cancel):" bbr_num
	[[ -z "${bbr_num}" ]] && echo "Canceled..." && exit 1
	if [[ ${bbr_num} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_num} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_num} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_num} == "4" ]]; then
		Status_BBR
	else
		echo -e "${Error} please enter the correct number (1-4)" && exit 1
	fi
}
Install_BBR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} This script does not support installing BBR on CentOS !" && exit 1
	BBR_installation_status
	bash "${BBR_file}"
}
Start_BBR(){
	BBR_installation_status
	bash "${BBR_file}" start
}
Stop_BBR(){
	BBR_installation_status
	bash "${BBR_file}" stop
}
Status_BBR(){
	BBR_installation_status
	bash "${BBR_file}" status
}
# Other functions
Other_functions(){
	echo && echo -e " What are you going to do?
	
  ${Green_font_prefix}1.${Font_color_suffix} Note BBR
  ${Green_font_prefix}2.${Font_color_suffix} Placement ServerSpeeder
  ${Green_font_prefix}3.${Font_color_suffix} Configure LotServer (Ruispeed parent company)
  Note: Rush/LotServer/BBR does not support OpenVZ!
  Note: Rush/LotServer/BBR cannot coexist!
————————————
  ${Green_font_prefix}4.${Font_color_suffix} One-click block BT/PT/SPAM (iptables)
  ${Green_font_prefix}5.${Font_color_suffix} One-click unblock BT/PT/SPAM (iptables)
  ${Green_font_prefix}6.${Font_color_suffix} switch ShadowsocksR log output mode
  ——Description: SSR only outputs error logs by default, this item can be switched to output detailed access logs" && echo
	read -e -p "(default: cancel):" other_num
	[[ -z "${other_num}" ]] && echo "Canceled..." && exit 1
	if [[ ${other_num} == "1" ]]; then
		Configure_BBR
	elif [[ ${other_num} == "2" ]]; then
		Configure_Server_Speeder
	elif [[ ${other_num} == "3" ]]; then
		Configure_LotServer
	elif [[ ${other_num} == "4" ]]; then
		BanBTPTSPAM
	elif [[ ${other_num} == "5" ]]; then
		UnBanBTPTSPAM
	elif [[ ${other_num} == "6" ]]; then
		Set_config_connect_verbose_info
	else
		echo -e "${Error} please enter the correct number [1-6]" && exit 1
	fi
}
# Ban BT PT SPAM
BanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh banall
	rm -rf ban_iptables.sh
}
# Unblock BT PT SPAM
UnBanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh unbanall
	rm -rf ban_iptables.sh
}
Set_config_connect_verbose_info(){
	SSR_installation_status
	Get_User
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "Current log mode: ${Green_font_prefix}Simple mode (only output error log) ${Font_color_suffix}" && echo
		echo -e "Are you sure you want to switch to ${Green_font_prefix} verbose mode (output verbose connection log + error log) ${Font_color_suffix}? [y/N]"
		read -e -p "(default: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="1"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "Cancelled..." && echo
		fi
	else
		echo && echo -e "Current log mode: ${Green_font_prefix} verbose mode (output verbose connection log + error log) ${Font_color_suffix}" && echo
		echo -e "Are you sure you want to switch to ${Green_font_prefix} simple mode (only output error log) ${Font_color_suffix}?[y/N]"
		read -e -p "(default: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="0"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "Cancelled..." && echo
		fi
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} cannot link to Github !" && exit 0
	if [[ -e "/etc/init.d/ssr" ]]; then
		rm -rf /etc/init.d/ssr
		Service_SSR
	fi
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh" && chmod +x ssr.sh
	echo -e "The script has been updated to the latest version [ ${sh_new_ver} ] ! (Note: Because the update method is to directly overwrite the currently running script, some errors may be prompted below, just ignore it)" && exit 0
}
# show menu status
menu_status(){
	if [[ -e ${config_user_file} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e "Current status: ${Green_font_prefix} installed ${Font_color_suffix} and ${Green_font_prefix} enabled ${Font_color_suffix}"
		else
			echo -e "Current status: ${Green_font_prefix} has ${Font_color_suffix} installed but ${Red_font_prefix} is not enabled ${Font_color_suffix}"
		fi
		now_mode=$(cat "${config_user_file}"|grep '"port_password"')
		if [[ -z "${now_mode}" ]]; then
			echo -e "Current mode: ${Green_font_prefix}single port ${Font_color_suffix}"
		else
			echo -e "Current mode: ${Green_font_prefix}Multiport ${Font_color_suffix}"
		fi
	else
		echo -e "Current Status: ${Font_color_suffix} is not installed in ${Red_font_prefix}"
	fi
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} This script does not support the current system ${release} !" && exit 1
echo -e " ShadowsocksR one-click management script ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- Toyo | doub.io/ss-jc42 ----

  ${Green_font_prefix}1.${Font_color_suffix} Install ShadowsocksR
  ${Green_font_prefix}2.${Font_color_suffix} Update ShadowsocksR
  ${Green_font_prefix}3.${Font_color_suffix} Uninstall ShadowsocksR
  ${Green_font_prefix}4.${Font_color_suffix} Install libsodium(chacha20)
————————————
  ${Green_font_prefix}5.${Font_color_suffix} View account information
  ${Green_font_prefix}6.${Font_color_suffix} display connection information
  ${Green_font_prefix}7.${Font_color_suffix} User Configuration Settings
  ${Green_font_prefix}8.${Font_color_suffix} Manually modify the configuration
  ${Green_font_prefix}9.${Font_color_suffix} Multi port mode
————————————
 ${Green_font_prefix}10.${Font_color_suffix} Start ShadowsocksR
 ${Green_font_prefix}11.${Font_color_suffix} Stop ShadowsocksR
 ${Green_font_prefix}12.${Font_color_suffix} Restart ShadowsocksR
 ${Green_font_prefix}13.${Font_color_suffix} View ShadowsocksR logs
————————————
 ${Green_font_prefix}14.${Font_color_suffix} Other functions
 ${Green_font_prefix}15.${Font_color_suffix} Upgrade script
 "
menu_status
echo && read -e -p "Please enter number [1-15]:" num
case "$num" in
	1)
	Install_SSR
	;;
	2)
	Update_SSR
	;;
	3)
	Uninstall_SSR
	;;
	4)
	Install_Libsodium
	;;
	5)
	View_User
	;;
	6)
	View_user_connection_info
	;;
	7)
	Modify_Config
	;;
	8)
	Manually_Modify_Config
	;;
	9)
	Port_mode_switching
	;;
	10)
	Start_SSR
	;;
	11)
	Stop_SSR
	;;
	12)
	Restart_SSR
	;;
	13)
	View_Log
	;;
	14)
	Other_functions
	;;
	15)
	Update_Shell
	;;
	*)
	echo -e "${Error} please enter the correct number [1-15]"
	;;
esac
