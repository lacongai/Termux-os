#!/usr/bin/bash
DAT(){ echo -en "\033[${1};${2}H";}
clear;toilet -t -f mono12  "TERMUX" --gay -F border
echo ""
DAT 11 40
echo -e "\e[92mBởi\e[1;93m Gấu Ngốc Nghếch\e[1;95m /\e[1;96m @henntaiiz "
DAT 12 3
echo
echo -e "\e[1;31m  [\e[32m√\e[31m] \e[1;91m bởi \e[1;36mGấu Ngốc Nghếch \e[93m/ \e[100;92myoutube.com/henntaiiz\e[0m"    
echo
echo -e "  \e[101;1;39mLƯU Ý\e[0;1;33m Chỉ dùng tối đa 9 từ\e[0m"
echo ""
cd ~/Termux-os/.object
echo -e '\e[1;96m'
read -p '  Nhập Tên Banner ❯ ' ten
sed -e "s/\PROC/$ten/g" .1zshrc > $HOME/.zshrc
