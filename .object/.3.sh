#!/usr/bin/bash
git clone https://github.com/zsh-users/zsh-autosuggestions /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting

clear
DAT(){ echo -en "\033[${1};${2}H";}
clear;toilet -t -f mono12  "Gấu Ngốc Nghếch" --gay -F border
echo ""
DAT 11 40
echo -e "\e[92mBởi\e[1;93m Gấu Ngốc Nghếch\e[1;95m /\e[1;96m @henntaiiz "
DAT 12 3
echo ""
echo -e "\e[1;31m  [\e[32m√\e[31m] \e[1;91m bởi \e[1;36mGấu Ngốc Nghếch \e[93m/ \e[100;92myoutube.com/henntaiiz\e[0m"
echo
echo -e "  \e[101;1;39mLƯU Ý\e[0;1;33m Chỉ dùng tối đa 9 từ\e[0m"
echo ""
cd ~/Termux-os/.object
echo -e '\e[1;96m'
read -p '  Nhập Tên Banner ❯ ' ten
sed -e "s/\PROC/$ten/g" .2zshrc > $HOME/.zshrc
echo  ""
echo -e '\e[1;96m'
read -p '  Nhập Tên Shell ❯ ' ten
sed -e "s/\H4ck3r/$ten/g" .henntaiiz.zsh-theme > $HOME/.oh-my-zsh/themes/henntaiiz.zsh-theme