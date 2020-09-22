# bbr2.sh

Warning: Replacing the kernel is risky and will not be responsible for any loss caused by the use of this script.  
警告：更换内核有风险，若使用本脚本后无法开机造成损失，概不负责。

Recommended OS Debian 10 x86_64, theoretical support for Debian 8+, Ubuntu 16.04+  
建议系统 Debian 10 x86_64，理论支持Debian 8+, Ubuntu 16.04+  
Only for 64-bit (x86_64) systems, x86 is not supported, and CentOS and other OS are not supported.  
仅适用于64位(x86_64)系统，不支持x86，不支持CentOS及其他系统。  
BandwagonHOST passed the test in Debian 8 9 10, Ubuntu 16.04 18.04 (Ubuntu 14.04 failed)  
已在搬瓦工 Debian 8 9 10 , Ubuntu 16.04 18.04 中测试通过 (Ubuntu 14.04 失败)  
Tested in the Debian 10 of the following merchants: Oracle Public Cloud, DMIT, OLVPS, AlibabaCloud  
已在以下商家的Debian 10系统中测试通过：Oracle Public Cloud, DMIT, OLVPS, AlibabaCloud  
Installation success rate 100%  
安装成功率100%  

General usage:  
一般用法:  
```
wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh
```

Since it can be called a one-click installation script, of course, there must be...  
既然称得上是一键安装脚本，当然要有......  
True one-click installation:
真·一键安装:  
```
wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh auto
```

Automatically restart after installing the kernel, automatically install BBR2 and enable ECN after restart.  
安装内核后自动重启，重启后自动安装BBR2和开启ECN。  
