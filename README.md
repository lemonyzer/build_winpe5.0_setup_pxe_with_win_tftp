# build_winpe5.0_setup_pxe_with_win_tftp
 Builds WinPE 5.0 and prepares TFTP-Folder (Windows tftp-Server)


# Requirements

Windows PC with installed:
* Windows Assessment and Deployment Kit (ADK) for Windows 8.1
  * source: (http://www.microsoft.com/de-de/download/details.aspx?id=39982)
* tftpd32 (http://tftpd32.jounin.net/tftpd32_download.html)
  * running @ C:\tftpboot
  * otherwise change %TFTPPath% in bat-File
* pxelinux.0 
  * from https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip @**(bios\core\pxelinux.0)**
  * or from http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/pxelinux.0 **(x86 and amd64 are identical)**
  

# Instructions

0. copy pxelinux.0 and folder pxelinux.cfg to C:\tftpboot

1. run the script **with admin priviliges**
    > .\full_Build_WinPE5.0_4_PXE.bat

2. with the script completed, all files should be at %TFTPPath% (C:\tftpboot & C:\tftpboot\Boot)
3. create syslink or copy C:\tftpboot\Boot\bootmgr.exe C:\tftpboot\bootmgr.exe
4. create syslink or copy C:\tftpboot\Boot\pxeboot.n12 C:\tftpboot\Boot\pxeboot.0

5. configure tftpd32

    TFTP-Settings
    ![tftpd32 - tftp setttings](./assets/tftpd32_-_tftp_settings.png?raw=true "tftpd32 - tftp setttings")
    Option negotiation is enabled

    DHCP-Settings
    ![tftpd32 - dhcp setttings](./assets/tftpd32_-_dhcp_settings.png?raw=true "tftpd32 - dhcp setttings")
    Boot File = ./pxelinux.0

6. make sure firewall allows traffic
7. boot the client machine with pxe (usally F12 PXE/Network Boot) - if option is not available enable it in bios/uefi (not all machines feature pxe boot!)