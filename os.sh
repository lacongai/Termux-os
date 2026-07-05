#!/bin/bash
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;93m'
B='\033[1;94m'
C='\033[1;96m'
W='\033[1;97m'
RS='\033[0m'

term_width=$(tput cols)
BOX_WIDTH=$(( term_width > 60 ? 58 : term_width - 2 ))
margin=$(( (term_width - BOX_WIDTH) / 2 ))
left_pad=$(printf '%*s' "$margin" "")

draw_line() {
    printf "${C}${left_pad}%s" "$1"
    for ((i=0; i<BOX_WIDTH-2; i++)); do printf "═"; done
    printf "%s${RS}\n" "$2"
}

print_center() {
    local text="$1"
    local color="$2"
    local len=${#text}
    local space_len=$(( (BOX_WIDTH - 2 - len) / 2 ))
    printf "${C}${left_pad}║%*s${color}%s${C}%*s║${RS}\n" $space_len "" "$text" $(( BOX_WIDTH - 2 - len - space_len )) ""
}

banner() {
    clear
    
    local R="\e[1;31m" 
    local G="\e[1;32m" 
    local C="\e[1;36m" 
    local W="\e[1;37m"
    local Y="\e[1;33m" 
    local N="\e[0m"    

    echo -e "${C} ______                              ${R}  ___  ____"
    echo -e "${C}/_  __/__  _________ ___  __  ___  __${R} / _ \/ __/"
    echo -e "${C} / / / _ \/ ___/ __ '__ \/ / / / |/_/${R}/ // /\ \  "
    echo -e "${C}/_/  \___/_/  /_/ /_/ /_/\__,_/_/|_| ${R}\___/___/  "
    echo -e "                                      "
    echo -e "${W}      --[ ${G}Công Cụ Tối Ưu Termux ${W}]--       "
    echo -e ""
    
    echo -e "${R} [!]${W} Author  : ${C}Gấu Ngốc Nghếch (henntaiiz)"
    echo -e "${R} [!]${W} Version : ${Y}v2 (Stable)"
    echo -e "${R} [!]${W} Youtube : ${W}youtube.com/henntaiiz"
    echo -e "${R} [!]${W} GitHub  : ${W}github.com/lacongai"
    echo -e ""
    
    echo -e "${G} ==============================================${N}"
    echo -e ""
}

banner

1line() { 
    apt update && apt upgrade
    pkg install zsh git figlet toilet ruby wget curl -y
    gem install lolcat
    clear
    cd ~/Termux-os/.object/ && cp -r 'ANSI Shadow.flf' $PREFIX/share/figlet/ASCII-Shadow.flf
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    pkg install toilet figlet exa -y
    cd ~/Termux-os/.object
    rm -rf ~/.termux/colors.properties
    rm -rf /data/data/com.termux/files/usr/etc/motd
    cp -r .colors.properties ~/.termux/colors.properties
    cp -r .termux.properties ~/.termux.properties
    curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf > ~/.termux/font.ttf
    rm -rf ~/.termux
    rm -f ~/.termux.properties
    clear
    cd ~/Termux-os
    bash os.sh
    termux-open-url h4ck3r.me && termux-reload-settings
}
2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh; }
10line() { rm -rf ~/Termux-os; cd; git clone https://github.com/lacongai/Termux-os; cd ~/Termux-os ; bash os.sh; }

# ===== KHÓA CYBER =====
8line() {
    echo -e "\n${C}Khởi tạo Giao thức Bảo mật...${RS}"
    echo -ne "${Y}Tạo Khóa Truy cập: ${RS}"
    read -s new_pass
    echo
    
    lock_code="#LOCK_START
clear
echo -e '\033[1;32m'
echo '  Kiểm tra hệ thống...'
sleep 0.2
echo '  Liên kết mã hóa đã thiết lập.'
sleep 0.2
clear
attempt=1
while [ \$attempt -le 3 ]; do
    echo -e \"\n${C}╔══════════════════════════════════════╗\"
    echo -e \"║        ${R}TRUY CẬP SHELL BẢO MẬT           ${C}║\"
    echo -e \"╚══════════════════════════════════════╝${RS}\"
    echo -ne \"${Y} [Attempt \$attempt/3] Enter Key: ${RS}\"
    read -s pass_input
    echo
    if [ \"\$pass_input\" = \"$new_pass\" ]; then
        echo -e \"${G} ĐÃ CẤP QUYỀN.${RS}\"
        sleep 1
        clear
        break
    else
        echo -e \"${R} TỪ CHỐI.${RS}\"
        if [ \$attempt -eq 3 ]; then
            exit
        fi
        attempt=\$((attempt + 1))
    fi
done
#LOCK_END"

    add_to_top() {
        local file=$1
        if [ -f "$file" ]; then
            echo "$lock_code" > "$file.tmp"
            cat "$file" >> "$file.tmp"
            mv "$file.tmp" "$file"
        else
            echo "$lock_code" > "$file"
        fi
    }

    add_to_top ~/.bashrc
    [ -f ~/.zshrc ] && add_to_top ~/.zshrc

    echo -e "${G}Đã cấu hình Khóa ở ĐẦU các tệp tin.${RS}"
    sleep 2
    menu
}

9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    echo -e "${R}Đã hủy kích hoạt Giao thức Bảo mật.${RS}"
    sleep 2
    menu
}

# ==============================================
# TÍNH NĂNG 1: CD TỰ ĐỘNG (HỖ TRỢ KHOẢNG CÁCH)
# ==============================================
auto_cd() {
    echo -e "\n${C}╔════════════════════════════════════════════╗${RS}"
    echo -e "${C}║${W}  📂 MỞ THƯ MỤC - CD TỰ ĐỘNG            ${C}║${RS}"
    echo -e "${C}╚════════════════════════════════════════════╝${RS}"
    echo -e "${Y}💡 Dán đường dẫn (hỗ trợ cả có và không có khoảng cách)${RS}"
    echo -e "${Y}   Ví dụ: /storage/emulated/0/Download/FreeFire/Bin Build Tools/${RS}"
    echo -ne "\n${C}📂 Đường dẫn: ${RS}"
    read -e dir_path
    
    dir_path=$(echo "$dir_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ -z "$dir_path" ]; then
        echo -e "${R}❌ Đường dẫn trống!${RS}"
        sleep 1
        menu
        return
    fi
    
    if [ -d "$dir_path" ]; then
        cd "$dir_path"
        echo -e "${G}✅ Đã vào: ${C}$(pwd)${RS}"
        echo -e "\n${G}📂 Nội dung thư mục:${RS}"
        ls -la --color=always | head -30
        echo -e "\n${Y}💡 Tổng: $(ls -1 | wc -l) file/thư mục${RS}"
    else
        echo -e "${R}❌ Thư mục không tồn tại: ${Y}$dir_path${RS}"
    fi
    echo -e "\n${C}Nhấn Enter để quay lại menu...${RS}"
    read -r
    menu
}

# ==============================================
# TÍNH NĂNG 2: CHẠY FILE TỰ ĐỘNG (THEO ĐUÔI)
# ==============================================
auto_run() {
    echo -e "\n${C}╔════════════════════════════════════════════╗${RS}"
    echo -e "${C}║${W}  🚀 CHẠY FILE - TỰ ĐỘNG THEO ĐUÔI      ${C}║${RS}"
    echo -e "${C}╚════════════════════════════════════════════╝${RS}"
    echo -e "${Y}💡 Chỉ cần nhập tên file, tool tự động nhận biết đuôi:${RS}"
    echo -e "${Y}   .py → python | .sh → bash | .js → node | .lua → lua${RS}"
    echo -ne "\n${C}📄 Tên file: ${RS}"
    read -e filename
    
    filename=$(echo "$filename" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ -z "$filename" ]; then
        echo -e "${R}❌ Tên file trống!${RS}"
        sleep 1
        menu
        return
    fi
    
    if [ ! -f "$filename" ]; then
        echo -e "${R}❌ File không tồn tại: ${Y}$filename${RS}"
        sleep 2
        menu
        return
    fi
    
    extension="${filename##*.}"
    
    echo -e "\n${C}▶️ Đang chạy: ${W}$filename${RS}"
    echo -e "${C}────────────────────────────────────────────${RS}"
    
    case "$extension" in
        py)
            echo -e "${G}🐍 Python:${RS}"
            python "$filename"
            ;;
        sh|bash)
            echo -e "${G}📜 Bash:${RS}"
            bash "$filename"
            ;;
        js)
            echo -e "${G}🟨 NodeJS:${RS}"
            if command -v node &>/dev/null; then
                node "$filename"
            else
                echo -e "${R}❌ Cần cài NodeJS: pkg install nodejs${RS}"
            fi
            ;;
        json)
            echo -e "${G}📋 JSON:${RS}"
            if command -v jq &>/dev/null; then
                cat "$filename" | jq '.' 2>/dev/null || cat "$filename"
            else
                cat "$filename"
            fi
            ;;
        txt|md|log)
            echo -e "${G}📄 Text:${RS}"
            cat "$filename"
            ;;
        lua)
            echo -e "${G}🔷 Lua:${RS}"
            if command -v lua &>/dev/null; then
                lua "$filename"
            else
                echo -e "${R}❌ Cần cài Lua: pkg install lua${RS}"
            fi
            ;;
        *)
            if head -n1 "$filename" | grep -q "#!/"; then
                echo -e "${G}⚡ File thực thi:${RS}"
                chmod +x "$filename"
                ./"$filename"
            else
                echo -e "${Y}⚠️ Không xác định đuôi: .$extension${RS}"
                bash "$filename" 2>/dev/null || echo -e "${R}❌ Không thể chạy${RS}"
            fi
            ;;
    esac
    
    echo -e "\n${C}────────────────────────────────────────────${RS}"
    echo -e "${C}Nhấn Enter để quay lại menu...${RS}"
    read -r
    menu
}

# ==============================================
# MENU CHÍNH (ĐÃ GỘP 13 VÀO 1)
# ==============================================
menu() {
    banner
    printf "\n${left_pad}${C}[${W}01${C}]${G} Cài đặt Cần thiết ${Y}(+ Reload tool)"
    printf "\n${left_pad}${C}[${W}02${C}]${G} Thiết lập Zsh"
    printf "\n${left_pad}${C}[${W}03${C}]${G} Shell Zsh"
    printf "\n${left_pad}${C}[${W}04${C}]${G} Shell Bash"
    printf "\n${left_pad}${C}[${W}05${C}]${Y} Banner Zsh"
    printf "\n${left_pad}${C}[${W}06${C}]${Y} Giao diện Zsh"
    printf "\n${left_pad}${C}[${W}07${C}]${Y} Tô sáng / Gợi ý tự động"
    printf "\n${left_pad}${C}[${W}08${C}]${B} Thêm Khóa Cyber ${R}(Bảo mật Cao)"
    printf "\n${left_pad}${C}[${W}09${C}]${R} Xóa Khóa"
    printf "\n${left_pad}${C}[${W}10${C}]${W} Cập nhật Script"
    printf "\n${left_pad}${C}[${W}11${C}]${C} 📂 Mở thư mục (CD tự động)"
    printf "\n${left_pad}${C}[${W}12${C}]${C} 🚀 Chạy file (Tự động theo đuôi)"
    printf "\n${left_pad}${C}[${W}00${C}]${R} Thoát Terminal\n\n"
    
    echo -ne "${left_pad}${C}Lựa chọn: ${RS}"
    read a
    case $a in
        1|01) 1line ;;
        2|02) 2line ;;
        3|03) 3line ;;
        4|04) 4line ;;
        5|05) 5line ;;
        6|06) 6line ;;
        7|07) 7line ;;
        8|08) 8line ;;
        9|09) 9line ;;
        10) 10line ;;
        11) auto_cd ;;
        12) auto_run ;;
        0|00) exit ;;
        *) menu ;;
    esac
}

# ==============================================
# TỰ ĐỘNG CHẠY TOOL KHI MỞ TERMUX
# ==============================================
if ! grep -q "bash ~/Termux-os/os.sh" ~/.bashrc 2>/dev/null; then
    echo -e "\n# TỰ ĐỘNG CHẠY TOOL TERMUX-OS" >> ~/.bashrc
    echo "bash ~/Termux-os/os.sh" >> ~/.bashrc
fi

menu