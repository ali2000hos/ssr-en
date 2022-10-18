#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: iptables Port forwarding
#	Version: 1.1.1
#	Author: Toyo
#	Blog: https://doub.io/wlzy-20/
#=================================================
sh_ver="1.1.1"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[information]${Font_color_suffix}"
Error="${Red_font_prefix}[mistake]${Font_color_suffix}"
Tip="${Green_font_prefix}[Notice]${Font_color_suffix}"

check_iptables(){
	iptables_exist=$(iptables -V)
	[[ ${iptables_exist} = "" ]] && echo -e "${Error} iptables is not installed, please check!" && exit 1
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
	#bit=`uname -m`
}
install_iptables(){
	iptables_exist=$(iptables -V)
	if [[ ${iptables_exist} != "" ]]; then
		echo -e "${Info} has iptables installed, continue..."
	else
		echo -e "${Info} detected that iptables is not installed, start installing..."
		if [[ ${release}  == "centos" ]]; then
			yum update
			yum install -y iptables
		else
			apt-get update
			apt-get install -y iptables
		fi
		iptables_exist=$(iptables -V)
		if [[ ${iptables_exist} = "" ]]; then
			echo -e "${Error} failed to install iptables, please check!" && exit 1
		else
			echo -e "${Info} iptables installation complete!"
		fi
	fi
	echo -e "${Info} start configuring iptables !"
	Set_iptables
	echo -e "${Info} iptables configuration complete!"
}
Set_forwarding_port(){
	read -e -p "Please enter the remote port [1-65535] that iptables wants to forward to (supports the port range such as 2333-6666, the forwarding server):" forwarding_port
	[[ -z "${forwarding_port}" ]] && echo "Cancel..." && exit 1
	echo && echo -e "For forwarding port: ${Red_font_prefix}${forwarding_port}${Font_color_suffix}" && echo
}
Set_forwarding_ip(){
		read -e -p "Please enter the remote IP that iptables wants to forward to (the forwarded server):" forwarding_ip
		[[ -z "${forwarding_ip}" ]] && echo "Cancel..." && exit 1
		echo && echo -e "Forwarding server IP: ${Red_font_prefix}${forwarding_ip}${Font_color_suffix}" && echo
}
Set_local_port(){
	echo -e "Please enter the iptables local listening port [1-65535] (support port segment such as 2333-6666)"
	read -e -p "(default port: ${forwarding_port}):" local_port
	[[ -z "${local_port}" ]] && local_port="${forwarding_port}"
	echo && echo -e "Local listening port: ${Red_font_prefix}${local_port}${Font_color_suffix}" && echo
}
Set_local_ip(){
	read -e -p "Please enter the IP of the network card of this server (note that it is the IP bound to the network card, not just the public network IP, press Enter to automatically detect the external network IP):" local_ip
	if [[ -z "${local_ip}" ]]; then
		#local_ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
		local_ip=$(curl -4 icanhazip.com)
		if [[ -z "${local_ip}" ]]; then
			echo "${Error} cannot detect the public IP of this server, please enter it manually"
			read -e -p "Please enter the network card IP of this server (note the IP bound to the network card, not just the public network IP):" local_ip
			[[ -z "${local_ip}" ]] && echo "Cancel..." && exit 1
		fi
	fi
	echo && echo -e " Home IP address : ${Network_font_prefix}${local_ip}${Font_color_suffix}" && echo
}
Set_forwarding_type(){
	echo -e "Please enter a number to select the iptables forwarding type:
 1. TCP
 2. UDP
 3. TCP+UDP\n"
	read -e -p "(default: TCP+UDP):" forwarding_type_num
	[[ -z "${forwarding_type_num}" ]] && forwarding_type_num="3"
	if [[ ${forwarding_type_num} == "1" ]]; then
		forwarding_type="TCP"
	elif [[ ${forwarding_type_num} == "2" ]]; then
		forwarding_type="UDP"
	elif [[ ${forwarding_type_num} == "3" ]]; then
		forwarding_type="TCP+UDP"
	else
		forwarding_type="TCP+UDP"
	fi
}
Set_Config(){
	Set_forwarding_port
	Set_forwarding_ip
	Set_local_port
	Set_local_ip
	Set_forwarding_type
	echo && echo -e "——————————————————————————————
	Please check whether the iptables port forwarding rules are configured incorrectly!\n
	Local listening port: ${Green_font_prefix}${local_port}${Font_color_suffix}
	Default IP\t: ${Green_font_prefix}${local_ip}${Font_color_suffix}\n
	Port to be forwarded: ${Green_font_prefix}${forwarding_port}${Font_color_suffix}
	Default IP\t: ${Green_font_prefix}${forwarding_ip}${Font_color_suffix}
	Forwarding Type\t: ${Green_font_prefix}${forwarding_type}${Font_color_suffix}
——————————————————————————————\n"
	read -e -p "Press any key to continue, or use Ctrl+C to exit if there is a configuration error." var
}
Add_forwarding(){
	check_iptables
	Set_Config
	local_port=$(echo ${local_port} | sed 's/-/:/g')
	forwarding_port_1=$(echo ${forwarding_port} | sed 's/-/:/g')
	if [[ ${forwarding_type} == "TCP" ]]; then
		Add_iptables "tcp"
	elif [[ ${forwarding_type} == "UDP" ]]; then
		Add_iptables "udp"
	elif [[ ${forwarding_type} == "TCP+UDP" ]]; then
		Add_iptables "tcp"
		Add_iptables "udp"
	fi
	Save_iptables
    iptables -nL
	iptables -t nat -nL
	clear && echo && echo -e "——————————————————————————————
	The iptables port forwarding rule configuration is complete!\n
	Local listening port: ${Green_font_prefix}${local_port}${Font_color_suffix}
	Default IP\t: ${Green_font_prefix}${local_ip}${Font_color_suffix}\n
	Port to be forwarded: ${Green_font_prefix}${forwarding_port_1}${Font_color_suffix}
	Default IP\t: ${Green_font_prefix}${forwarding_ip}${Font_color_suffix}
	Forwarding Type\t: ${Green_font_prefix}${forwarding_type}${Font_color_suffix}
——————————————————————————————\n"
}
View_forwarding(){
	check_iptables
	forwarding_text=$(iptables -t nat -vnL PREROUTING|tail -n +3)
	[[ -z ${forwarding_text} ]] && echo -e "${Error} iptables port forwarding rule not found, please check!" && exit 1
	forwarding_total=$(echo -e "${forwarding_text}"|wc -l)
	forwarding_list_all=""
	for((integer = 1; integer <= ${forwarding_total}; integer++))
	do
		forwarding_type=$(echo -e "${forwarding_text}"|awk '{print $4}'|sed -n "${integer}p")
		forwarding_listen=$(echo -e "${forwarding_text}"|awk '{print $11}'|sed -n "${integer}p"|awk -F "dpt:" '{print $2}')
		[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}'|sed -n "${integer}p"|awk -F "dpts:" '{print $2}')
		forwarding_fork=$(echo -e "${forwarding_text}"| awk '{print $12}'|sed -n "${integer}p"|awk -F "to:" '{print $2}')
		forwarding_list_all=${forwarding_list_all}"${Green_font_prefix}"${integer}".${Font_color_suffix} type: ${Green_font_prefix}"${forwarding_type}"${Font_color_suffix} listening port: ${Red_font_prefix}"${forwarding_listen}"${Font_color_suffix} Forwarding IP and Port: ${Red_font_prefix}"${forwarding_fork}"${Font_color_suffix}\n"
	done
	echo && echo -e "Currently there are ${Green_background_prefix} "${forwarding_total}" ${Font_color_suffix} iptables port forwarding rules."
	echo -e ${forwarding_list_all}
}
Del_forwarding(){
	check_iptables
	while true
	do
	View_forwarding
	read -e -p "Please enter a number to select the iptables port forwarding rule to be deleted (press Enter to cancel by default):" Del_forwarding_num
	[[ -z "${Del_forwarding_num}" ]] && Del_forwarding_num="0"
	echo $((${Del_forwarding_num}+0)) &>/dev/null
	if [[ $? -eq 0 ]]; then
		if [[ ${Del_forwarding_num} -ge 1 ]] && [[ ${Del_forwarding_num} -le ${forwarding_total} ]]; then
			forwarding_type=$(echo -e "${forwarding_text}"| awk '{print $4}' | sed -n "${Del_forwarding_num}p")
			forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}' | sed -n "${Del_forwarding_num}p" | awk -F "dpt:" '{print $2}' | sed 's/-/:/g')
			[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}' |sed -n "${Del_forwarding_num}p" | awk -F "dpts:" '{print $2}')
			Del_iptables "${forwarding_type}" "${Del_forwarding_num}"
			Save_iptables
			echo && echo -e "${Info} iptables port forwarding rule deletion completed!" && echo
		else
			echo -e "${Error} Please enter the correct number!"
		fi
	else
		break && echo "Cancel..."
	fi
	done
}
Uninstall_forwarding(){
	check_iptables
	echo -e "Are you sure you want to clear all port forwarding rules in iptables? [y/N]"
	read -e -p "(default: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		forwarding_text=$(iptables -t nat -vnL PREROUTING|tail -n +3)
		[[ -z ${forwarding_text} ]] && echo -e "${Error} iptables port forwarding rule not found, please check!" && exit 1
		forwarding_total=$(echo -e "${forwarding_text}"|wc -l)
		for((integer = 1; integer <= ${forwarding_total}; integer++))
		do
			forwarding_type=$(echo -e "${forwarding_text}"|awk '{print $4}'|sed -n "${integer}p")
			forwarding_listen=$(echo -e "${forwarding_text}"|awk '{print $11}'|sed -n "${integer}p"|awk -F "dpt:" '{print $2}')
			[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}'|sed -n "${integer}p"|awk -F "dpts:" '{print $2}')
			# echo -e "${forwarding_text} ${forwarding_type} ${forwarding_listen}"
			Del_iptables "${forwarding_type}" "${integer}"
		done
		Save_iptables
		echo && echo -e "${Info} iptables has cleared all port forwarding rules!" && echo
	else
		echo && echo "Empty canceled..." && echo
	fi
}
Add_iptables(){
	iptables -t nat -A PREROUTING -p "$1" --dport "${local_port}" -j DNAT --to-destination "${forwarding_ip}":"${forwarding_port}"
	iptables -t nat -A POSTROUTING -p "$1" -d "${forwarding_ip}" --dport "${forwarding_port_1}" -j SNAT --to-source "${local_ip}"
	echo "iptables -t nat -A PREROUTING -p $1 --dport ${local_port} -j DNAT --to-destination ${forwarding_ip}:${forwarding_port}"
	echo "iptables -t nat -A POSTROUTING -p $1 -d ${forwarding_ip} --dport ${forwarding_port_1} -j SNAT --to-source ${local_ip}"
	echo "${local_port}"
	iptables -t nat -A POSTROUTING -j MASQUERADE
	#iptables -I INPUT -m state --state NEW -m "$1" -p "$1" --dport "${local_port}" -j ACCEPT
}
Del_iptables(){
	iptables -t nat -D POSTROUTING "$2"
	iptables -t nat -D PREROUTING "$2"
	iptables -D INPUT -m state --state NEW -m "$1" -p "$1" --dport "${forwarding_listen}" -j ACCEPT
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
	else
		iptables-save > /etc/iptables.up.rules
		service netfilter-persistent save
	fi
}
Set_iptables(){
	echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	sysctl -p
	if [[ ${release} == "centos" ]]; then
		service iptables save
		chkconfig --level 2345 iptables on
	else
		iptables-save > /etc/iptables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/iptables-pf.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} cannot link to Github !" && exit 0
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/iptables-pf.sh" && chmod +x iptables-pf.sh
	echo -e "The script has been updated to the latest version [ ${sh_new_ver} ] ! (Note: Because the update method is to directly overwrite the currently running script, some errors may be prompted below, just ignore it)" && exit 0
}
Basic_ipt(){
    apt install iptables-persistent -y
    service netfilter-persistent flush
    iptables -S
    iptables -N UDP
    iptables -N TCP
    iptables -N ICMP
    iptables -A TCP -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH"
    iptables -A TCP -p tcp --dport 80 -j ACCEPT -m comment --comment "HTTP"
    iptables -A TCP -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
    iptables -A UDP -p udp --dport 80 -j ACCEPT -m comment --comment "HTTP-UDP"
    iptables -A UDP -p udp --dport 443 -j ACCEPT -m comment --comment "HTTPS-UDP"
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
    iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
    iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
    iptables -A INPUT -p icmp -m conntrack --ctstate NEW -j ICMP
    iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
    iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
    iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable
    iptables -P INPUT DROP
    iptables -t nat -nL
    service netfilter-persistent save
    iptables -nL
    echo -e "Done!"
}
Add_ssr_iptables(){
    echo -e "Please enter the ShadowsocksR account port to be set"
	read -e -p "(exp: 2333):" ssr_port
	iptables -I TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-TCP"
	iptables -I UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-UDP"
	#ip6tables -I TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-TCP"
	#ip6tables -I UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-UDP"
}
Del_ssr_iptables(){
    echo -e "Please enter the ShadowsocksR account port to remove"
	read -e -p "(exp: 2333):" ssr_port
	iptables -D TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-TCP"
	iptables -D UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-UDP"
	#ip6tables -D TCP -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-TCP"
	#ip6tables -D UDP -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT -m comment --comment "SSR-UDP"
}

check_sys
echo && echo -e " iptables port forwarding one-click management script ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/wlzy-20 --
  
 ${Green_font_prefix}0.${Font_color_suffix} upgrade script
————————————
 ${Green_font_prefix}1.${Font_color_suffix} Install iptables
 ${Green_font_prefix}2.${Font_color_suffix} clear iptables port forwarding
————————————
 ${Green_font_prefix}3.${Font_color_suffix} View iptables port forwarding
 ${Green_font_prefix}4.${Font_color_suffix} add iptables port forwarding
 ${Green_font_prefix}5.${Font_color_suffix} delete iptables port forwarding
 ${Green_font_prefix}6.${Font_color_suffix} Basic Iptables config
 ${Green_font_prefix}7.${Font_color_suffix} Open an ssr port in iptables
 ${Green_font_prefix}8.${Font_color_suffix} Remove an ssr port in iptables
————————————
Note: Please be sure to execute ${Green_font_prefix}1. Install iptables ${Font_color_suffix}(not just install)" && echo
read -e -p "Please enter number [0-8]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	install_iptables
	;;
	2)
	Uninstall_forwarding
	;;
	3)
	View_forwarding
	;;
	4)
	Add_forwarding
	;;
	5)
	Del_forwarding
	;;
	6)
	Basic_ipt
	;;
	7)
	Add_ssr_iptables
	;;
	8)
	Del_ssr_iptables
	;;
	*)
	echo "Please enter the correct number [0-8]"
	;;
esac
