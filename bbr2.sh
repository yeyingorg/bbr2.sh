#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error! You must be root to run this script!"
    echo "錯誤！你必須要以root身份運行此腳本！"
    exit 1
fi

this_file_path=$(readlink -f $0)
this_file_dir=$(dirname $(readlink -f $0))
red_color="\033[31m"
green_color="\033[32m"
color_end="\033[0m"

cat /etc/issue | grep -q "CentOS"
if [ $? -eq 0 ]; then
    echo "    Oh Nononononono! You are using CentOS?
    Unfortunately, this script only works for Debian.
    But fortunately, other person has made a script that could be also use on CentOS.
    Would you like to download that script and run?"
    echo "    哦不不不不不不！你正在使用CentOS？
    不幸的是，這個腳本只適用於Debian。
    但幸運的是，有別的大佬寫了一個也可以在CentOS上使用的腳本。
    您要下載該腳本並運行嗎？"

	read -p "Use xiya233's script? 使用xiya233的腳本？[Y/n] : " use_xiya233_scrpit
	[ -z "$use_xiya233_scrpit" ] && use_xiya233_scrpit="n"
	if [[ $use_xiya233_scrpit == [Yy] ]]; then
		wget --no-check-certificate -q -O bbr2_xiya233.sh "https://github.com/xiya233/bbr2/raw/master/bbr2.sh" && chmod +x bbr2_xiya233.sh && bash bbr2_xiya233.sh
	fi
    exit 0
fi

install_rc.local() {
    [ -f "/etc/rc.local" ] && echo "Error! /etc/rc.local already exist." && echo "錯誤！/etc/rc.local 已經存在。" && exit 1
    systemctl stop rc-local
    cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
    chmod +x /etc/rc.local
    systemctl start rc-local
}
add_to_rc.local() {
    [ ! -f "/etc/rc.local" ] && install_rc.local
    sed -i "s/will \"exit 0\" on/will \"exit yeying.org\" on/g" /etc/rc.local
    sed -i "/exit 0/d" /etc/rc.local
    sed -i "s/will \"exit yeying.org\" on/will \"exit 0\" on/g" /etc/rc.local
    echo "$1" >> /etc/rc.local
    echo 'exit 0' >> /etc/rc.local
}

check_environment() {
    unset environment_debian
    unset environment_x64
    unset environment_headers
    unset environment_image
    unset environment_kernel
    unset environment_bbr2
    unset environment_ecn
    unset environment_otherkernels
    cat /etc/issue | grep -q "Debian" && [ $? -eq 0 ] && environment_debian="true"
    cat /etc/issue | grep -q "Ubuntu" && [ $? -eq 0 ] && environment_debian="true"
    uname -a | grep -q "x86_64" && [ $? -eq 0 ] && environment_x64="true"
    dpkg -l | grep linux-headers | awk '{print $2}' | grep -q "linux-headers-5.4.0-rc6" && [ $? -eq 0 ] && environment_headers="true"
    dpkg -l | grep linux-image | awk '{print $2}' | grep -q "linux-image-5.4.0-rc6" && [ $? -eq 0 ] && environment_image="true"
    uname -r | grep -q "5.4.0-rc6" && [ $? -eq 0 ] && environment_kernel="true"
    cat /etc/sysctl.conf | grep -q "bbr2" && [ $? -eq 0 ] && lsmod | grep -q "tcp_bbr2" && [ $? -eq 0 ] && environment_bbr2="true"
    cat /etc/sysctl.conf | grep -q "net.ipv4.tcp_ecn" && [ $? -eq 0 ] && [[ "$(cat /sys/module/tcp_bbr2/parameters/ecn_enable)" = "Y" ]] && cat /etc/rc.local | grep -q "echo 1 > /sys/module/tcp_bbr2/parameters/ecn_enable" && [ $? -eq 0 ] && environment_ecn="true"
    other_linux_images=$(dpkg -l | grep linux-image | awk '{print $2}') && other_linux_images=${other_linux_images/"linux-image-5.4.0-rc6"/} && [ ! -z "$other_linux_images" ] && environment_otherkernels="true"
    other_linux_headers=$(dpkg -l | grep linux-headers | awk '{print $2}') && other_linux_headers=${other_linux_headers/"linux-headers-5.4.0-rc6"/} && [ ! -z "$other_linux_headers" ] && environment_otherkernels="true"

    [[ "$environment_debian" != "true" ]] && echo "Error! Your OS is not Debian! This script is only suitable for Debian 9/10." && echo "錯誤！你的系統不是Debian，此腳本只適用於Debian 9/10！" && exitone="true"
    [[ "$environment_x64" != "true" ]] && echo "Error! Your OS is not x86_64! This script is only suitable for x86_64 OS." && echo "錯誤！你的系統不是64位系統，此腳本只適用於64位系統(x86_64)！" && exitone="true"

    [[ "$exitone" = "true" ]] && exit 1
}

analyze_environment() {
    if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]]; then
        if [[ "$environment_kernel" = "true" ]]; then
            echo -e "Kernel: ${green_color}Installed${color_end}-${green_color}Using${color_end} | 內核: ${green_color}已安裝${color_end}-${green_color}使用中${color_end}"
        else
            echo -e "Kernel: ${green_color}Installed${color_end}-${red_color}Not using${color_end} | 內核: ${green_color}已安裝${color_end}-${red_color}未使用${color_end}"
        fi
    else
        echo -e "Kernel: ${red_color}Not installed${color_end} | 內核: ${red_color}未安裝${color_end}"
    fi

    if [[ "$environment_bbr2" = "true" ]]; then
        echo -e "BBR2: ${green_color}Enabled${color_end} | BBR2: ${green_color}已啟用${color_end}"
    elif [[ "$environment_kernel" = "true" ]]; then
        echo -e "BBR2: ${red_color}Disabled${color_end} | BBR2: ${red_color}已禁用${color_end}"
    fi

    if [[ "$environment_ecn" = "true" ]]; then
        echo -e "ECN: ${green_color}Enabled${color_end} | ECN: ${green_color}已啟用${color_end}"
    elif [[ "$environment_bbr2" = "true" ]]; then
        echo -e "ECN: ${red_color}Disabled${color_end} | ECN: ${red_color}已禁用${color_end}"
    fi
}

install_kernel() {
    if [[ "$environment_headers" != "true" ]]; then
        [ ! -f "linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb" ] && wget --no-check-certificate -O linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb "https://github.com/yeyingorg/bbr2.sh/raw/master/linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb"
        [ ! -f "linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb" ] && echo "Error! Download file failed! File \"linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb\" Not Found!" && echo "錯誤！下載文件失敗！找不到文件 \"linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb\"" && exit 1
    fi
    if [[ "$environment_image" != "true" ]]; then
        [ ! -f "linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb" ] && wget --no-check-certificate -O linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb "https://github.com/yeyingorg/bbr2.sh/raw/master/linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb"
        [ ! -f "linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb" ] && echo "Error! Download file failed! File \"linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb\" Not Found!" && echo "錯誤！下載文件失敗！找不到文件 \"linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb\"" && exit 1
    fi
    [[ "$environment_headers" != "true" ]] && dpkg -i linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb
    [[ "$environment_image" != "true" ]] && dpkg -i linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb
    rm -f linux-headers-5.4.0-rc6_5.4.0-rc6-2_amd64.deb linux-image-5.4.0-rc6_5.4.0-rc6-2_amd64.deb
    update-grub
}
enable_bbr2() {
    sed -i "/tcp_dctcp/d" /etc/modules-load.d/modules.conf
    sed -i "/tcp_bbr2/d" /etc/modules-load.d/modules.conf
    sed -i "/tcp_bbr/d" /etc/modules-load.d/modules.conf
    sed -i "/tcp_dctcp/d" /etc/modules
    sed -i "/tcp_bbr2/d" /etc/modules
    sed -i "/tcp_bbr/d" /etc/modules
    modprobe tcp_bbr2
    echo "tcp_bbr2" >> /etc/modules
    sed -i "/net.core.default_qdisc/d" /etc/sysctl.conf
    sed -i "/net.ipv4.tcp_congestion_control/d" /etc/sysctl.conf
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr2" >> /etc/sysctl.conf
    sysctl -p
}
disable_bbr2() {
    sed -i "/tcp_bbr2/d" /etc/modules
    sed -i "/net.core.default_qdisc/d" /etc/sysctl.conf
    sed -i "/net.ipv4.tcp_congestion_control/d" /etc/sysctl.conf
    sed -i "/net.ipv4.tcp_ecn/d" /etc/sysctl.conf
    echo 0 > /sys/module/tcp_bbr2/parameters/ecn_enable
    sysctl -p
    sed -i "/\/sys\/module\/tcp_bbr2\/parameters\/ecn_enable/d" /etc/rc.local
}
enable_ecn() {
    sed -i "/net.ipv4.tcp_ecn/d" /etc/sysctl.conf
    echo "net.ipv4.tcp_ecn=1" >> /etc/sysctl.conf
    echo 1 > /sys/module/tcp_bbr2/parameters/ecn_enable
    sysctl -p
    sed -i "/\/sys\/module\/tcp_bbr2\/parameters\/ecn_enable/d" /etc/rc.local
    add_to_rc.local "echo 1 > /sys/module/tcp_bbr2/parameters/ecn_enable"
}
disable_ecn() {
    sed -i "/net.ipv4.tcp_ecn/d" /etc/sysctl.conf
    echo 0 > /sys/module/tcp_bbr2/parameters/ecn_enable
    sysctl -p
    sed -i "/\/sys\/module\/tcp_bbr2\/parameters\/ecn_enable/d" /etc/rc.local
}
remove_other_kernels() {
    if [[ "$environment_kernel" != "true" ]]; then
        echo 'Abort kernel removal? Choose <No>'
        echo '當出現"Abort kernel removal?"選項時，請選擇 <No>'
        echo 'Abort kernel removal? Choose <No>'
        echo '當出現"Abort kernel removal?"選項時，請選擇 <No>'
        echo 'Abort kernel removal? Choose <No>'
        echo '當出現"Abort kernel removal?"選項時，請選擇 <No>'
        sleep 5s
    fi
    apt-get purge -y $other_linux_images $other_linux_headers
    update-grub
}


do_option() {
    case "$1" in
        0)
            exit 0
            ;;
        1)
            [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            install_kernel
            check_environment
            if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]]; then
                echo "Please reboot and then run this script again to enable BBR2."
                echo "請重新啟動然後再次執行此腳本以啟動BBR2。"
                read -p "Reboot now? | 現在立即重啟？ (y/n) " reboot
                [ -z "${reboot}" ] && reboot="y"
            	if [[ $reboot == [Yy] ]]; then
            		echo "Rebooting..."
                	echo "正在重新啟動..."
            		reboot
            	fi
            else
                echo "Error! Kernel install failed!"
                echo "錯誤！內核安裝失敗！"
                return 1
            fi
            ;;
        2)
            [[ "$environment_kernel" != "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            [[ "$environment_bbr2" = "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            enable_bbr2
            ;;
        3)
            [[ "$environment_bbr2" != "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            disable_bbr2
            ;;
        4)
            [[ "$environment_bbr2" != "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            [[ "$environment_ecn" = "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            enable_ecn
            ;;
        5)
            [[ "$environment_ecn" != "true" ]] && echo "Invalid option." && echo "無效的選項。" && return 1
            disable_ecn
            ;;
        6)
            if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_otherkernels" = "true" ]]; then
                remove_other_kernels
            else
                echo "Invalid option." && echo "無效的選項。" && return 1
            fi
            ;;
        7)
            if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_kernel" != "true" ]]; then
                reboot
            else
                echo "Invalid option." && echo "無效的選項。" && return 1
            fi
            ;;
            
    esac
}

auto_install() {
    check_environment
    if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_kernel" != "true" ]]; then
        this_file_path=${this_file_path//"/"/"\\/"} && sed -i "/bash $this_file_path auto/d" /etc/rc.local && this_file_path=${this_file_path//"\\/"/"/"}
        cat >> $this_file_dir/bbr2.sh.log << EOF
        Error! Install failed!
        Umm... It seems like you have installed the kernel for BBR2 but not using it...
        Maybe you have to manually remove other kernels and then reboot.
        錯誤！安裝失敗！
        呃...這看起來你已經安裝了BBR2的內核但是並沒有啟用。
        或許你需要手動卸載其餘的內核然後重啟。
EOF
        cat $this_file_dir/bbr2.sh.log
        exit 1
    elif [[ "$environment_kernel" != "true" ]]; then
        install_kernel
        check_environment
        if [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]]; then
            add_to_rc.local "bash $this_file_path auto"
            reboot
        else
            echo "Error! Kernel install failed!" >> $this_file_dir/bbr2.sh.log
            echo "錯誤！內核安裝失敗！" >> $this_file_dir/bbr2.sh.log
            cat $this_file_dir/bbr2.sh.log
            exit 1
        fi
    elif [[ "$environment_kernel" = "true" ]]; then
        enable_bbr2
        enable_ecn
        this_file_path=${this_file_path//"/"/"\\/"} && sed -i "/bash $this_file_path auto/d" /etc/rc.local && this_file_path=${this_file_path//"\\/"/"/"}
        check_environment
        if [[ "$environment_bbr2" = "true" ]] && [[ "$environment_ecn" = "true" ]]; then
            analyze_environment
            # If succeeded, no output to the log file. 這邊成功就不輸出到log文件了吧？故意的。
        else
            echo "Error! BBR2 install failed!" >> $this_file_dir/bbr2.sh.log
            echo $(analyze_environment) >> $this_file_dir/bbr2.sh.log
            cat $this_file_dir/bbr2.sh.log
            exit 1
        fi
    fi
}

[[ "$1" = "auto" ]] && auto_install && exit 0

while :
do
echo "+----------------------------------+" &&
echo "|               夜桜               |" &&
echo "|   BBR2 一鍵安裝 for Debian x64   |" &&
echo "|        2019-11-21 Alpha-2        |" &&
echo "+----------------------------------+"

check_environment
analyze_environment

echo "What do you want to do? | 請問您今天要來點兔子嗎？"

while :
do
    echo "0) Exit script. | 退出腳本。 (0"
    if [[ "$environment_headers" != "true" ]] || [[ "$environment_image" != "true" ]]; then echo "1) Install the kernel for BBR2. | 安裝適用於BBR2的內核。 (1"; fi
    [[ "$environment_kernel" = "true" ]] && [[ "$environment_bbr2" != "true" ]] && echo "2) Enable BBR2. | 啟用BBR2。 (2"
    [[ "$environment_bbr2" = "true" ]] && echo "3) Disable BBR2. | 禁用BBR2。 (3"
    [[ "$environment_bbr2" = "true" ]] && [[ "$environment_ecn" != "true" ]] && echo "4) Enable ECN. | 啟用ECN。 (4"
    [[ "$environment_ecn" = "true" ]] && echo "5) Disable ECN. | 禁用ECN。 (5"
    [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_otherkernels" = "true" ]] && echo "6) Remove other kernels. | 卸載其餘內核。 (6"
    [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_kernel" != "true" ]] && echo "7) reboot. | 重新啟動。 (7"
    unset choose_an_option
    read -p "Choose an option. | 選擇一個選項。 (Input a number | 輸入一個數字) " choose_an_option

    if [[ "$choose_an_option" = "0" ]] || [[ "$choose_an_option" = "1" ]] || [[ "$choose_an_option" = "2" ]] || [[ "$choose_an_option" = "3" ]] || [[ "$choose_an_option" = "4" ]] || [[ "$choose_an_option" = "5" ]] || [[ "$choose_an_option" = "6" ]] || [[ "$choose_an_option" = "7" ]]; then
        do_option $choose_an_option
        break
    else
        continue
    fi
done

done