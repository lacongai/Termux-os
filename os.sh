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
    echo -e "${R} [!]${W} Version : ${Y}v1 (Stable)"
    echo -e "${R} [!]${W} Youtube : ${W}youtube.com/henntaiiz"
    echo -e "${R} [!]${W} GitHub  : ${W}github.com/lacongai"
    echo -e ""

    echo -e "${G} ==============================================${N}"
    echo -e ""
}

banner

1line() { apt update && apt upgrade; pkg install zsh git figlet toilet ruby wget curl -y; gem install lolcat; clear; cd ~/Termux-os/.object/ && cp -r 'ANSI Shadow.flf' $PREFIX/share/figlet/ASCII-Shadow.flf; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; pkg install toilet figlet exa -y; cd ~/Termux-os/.object; rm -rf ~/.termux/colors.properties; rm -rf /data/data/com.termux/files/usr/etc/motd; cp -r .colors.properties ~/.termux/colors.properties; cp -r .termux.properties ~/.termux.properties; curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf > ~/.termux/font.ttf; clear; cd ~/Termux-os ; bash os.sh; termux-open-url h4ck3r.me && termux-reload-settings; }
2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh; }
10line() { rm -rf ~/Termux-os; cd; git clone https://github.com/lacongai/Termux-os; cd ~/Termux-os ; bash os.sh; }

# ─────────────────────────────────────────────────────────
#  CYBER LOCK — Thêm mật khẩu bảo vệ shell
# ─────────────────────────────────────────────────────────
8line() {
    echo -e "\n${C}Khởi tạo Giao thức Bảo mật...${RS}"
    echo -ne "${Y}Tạo Khóa Truy cập: ${RS}"
    read -s new_pass
    echo

    # Escape password so it is safe to embed inside single-quoted shell strings
    # Any single-quote in the password is replaced with '\''
    local safe_pass
    safe_pass=$(printf '%s' "$new_pass" | sed "s/'/'\\\\''/g")

    # The lock block uses single-quoted here-doc to avoid variable expansion at
    # generation time; only $safe_pass (already sanitised) is inserted.
    local lock_code
    lock_code=$(cat <<LOCKEOF
#LOCK_START
clear
echo -e '\033[1;32m'
echo '  Kiểm tra hệ thống...'
sleep 0.2
echo '  Liên kết mã hóa đã thiết lập.'
sleep 0.2
clear
attempt=1
while [ \$attempt -le 3 ]; do
    printf '\n\033[1;96m╔══════════════════════════════════════╗\n'
    printf '║        \033[1;31mTRUY CẬP SHELL BẢO MẬT           \033[1;96m║\n'
    printf '╚══════════════════════════════════════╝\033[0m\n'
    printf '\033[1;93m [Attempt %s/3] Enter Key: \033[0m' "\$attempt"
    read -s pass_input
    echo
    if [ "\$pass_input" = '${safe_pass}' ]; then
        printf '\033[1;32m ĐÃ CẤP QUYỀN.\033[0m\n'
        sleep 1
        clear
        break
    else
        printf '\033[1;31m TỪ CHỐI.\033[0m\n'
        if [ \$attempt -eq 3 ]; then
            exit
        fi
        attempt=\$((attempt + 1))
    fi
done
#LOCK_END
LOCKEOF
)

    add_to_top() {
        local file=$1
        if [ -f "$file" ]; then
            printf '%s\n' "$lock_code" > "$file.tmp"
            cat "$file" >> "$file.tmp"
            mv "$file.tmp" "$file"
        else
            printf '%s\n' "$lock_code" > "$file"
        fi
    }

    add_to_top ~/.bashrc
    [ -f ~/.zshrc ] && add_to_top ~/.zshrc

    echo -e "${G}Đã cấu hình Khóa ở ĐẦU các tệp tin.${RS}"
    sleep 2
    menu
}

# ─────────────────────────────────────────────────────────
#  XÓA KHÓA
# ─────────────────────────────────────────────────────────
9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    echo -e "${R}Đã hủy kích hoạt Giao thức Bảo mật.${RS}"
    sleep 2
    menu
}

# ─────────────────────────────────────────────────────────
#  SMART MODE — hàm xử lý lệnh thông minh
# ─────────────────────────────────────────────────────────

# Resolve a path that may start with ~ or /
_smart_resolve_path() {
    local raw="$1"
    # Expand leading ~ manually (POSIX-safe)
    if [[ "$raw" == "~/"* ]]; then
        raw="$HOME/${raw:2}"
    elif [[ "$raw" == "~" ]]; then
        raw="$HOME"
    fi
    printf '%s' "$raw"
}

smart_run_cmd() {
    local input="$*"

    # ── Smart Path ─────────────────────────────────────────
    # Triggered when input starts with / or ~/
    if [[ "$input" == /* || "$input" == "~" || "$input" == "~/"* ]]; then
        local path
        path=$(_smart_resolve_path "${input%/}")   # strip trailing slash after expand
        if [ -d "$path" ]; then
            echo -e "${C}[Smart Path]${RS} cd \"$path\""
            cd "$path" || true
        else
            echo -e "${R}[Lỗi] Không tìm thấy thư mục: $path${RS}"
        fi
        return
    fi

    # ── Smart Run ──────────────────────────────────────────
    # Triggered when input is a bare filename (no spaces) with a known extension
    # and the file actually exists in the current directory.
    local filename="$input"
    local ext="${filename##*.}"

    if [[ "$filename" == *.* && "$filename" != *" "* && -f "$filename" ]]; then
        case "$ext" in
            py)
                echo -e "${C}[Smart Run]${RS} python $filename"
                python "$filename" ;;
            sh)
                echo -e "${C}[Smart Run]${RS} bash $filename"
                bash "$filename" ;;
            js)
                echo -e "${C}[Smart Run]${RS} node $filename"
                node "$filename" ;;
            ts)
                echo -e "${C}[Smart Run]${RS} npx ts-node $filename"
                npx ts-node "$filename" ;;
            php)
                echo -e "${C}[Smart Run]${RS} php $filename"
                php "$filename" ;;
            rb)
                echo -e "${C}[Smart Run]${RS} ruby $filename"
                ruby "$filename" ;;
            lua)
                echo -e "${C}[Smart Run]${RS} lua $filename"
                lua "$filename" ;;
            pl)
                echo -e "${C}[Smart Run]${RS} perl $filename"
                perl "$filename" ;;
            go)
                echo -e "${C}[Smart Run]${RS} go run $filename"
                go run "$filename" ;;
            java)
                local cls="${filename%.java}"
                echo -e "${C}[Smart Run]${RS} javac $filename && java $cls"
                javac "$filename" && java "$cls" ;;
            c)
                local out="${filename%.c}"
                echo -e "${C}[Smart Run]${RS} gcc $filename -o $out && ./$out"
                gcc "$filename" -o "$out" && "./$out" ;;
            cpp)
                local out="${filename%.cpp}"
                echo -e "${C}[Smart Run]${RS} g++ $filename -o $out && ./$out"
                g++ "$filename" -o "$out" && "./$out" ;;
            rs)
                local out="${filename%.rs}"
                echo -e "${C}[Smart Run]${RS} rustc $filename && ./$out"
                rustc "$filename" && "./$out" ;;
            r|R)
                echo -e "${C}[Smart Run]${RS} Rscript $filename"
                Rscript "$filename" ;;
            *)
                # Unknown extension — treat as a regular shell command
                bash -c "$input" ;;
        esac
        return
    fi

    # ── Lệnh thông thường — giữ nguyên ─────────────────────
    bash -c "$input"
}

# ─────────────────────────────────────────────────────────
#  [11] Smart Mode — vòng lặp tương tác tạm thời
# ─────────────────────────────────────────────────────────
11line() {
    clear
    echo -e "${C}╔══════════════════════════════════════════╗"
    echo -e "║       ${Y}⚡  SMART MODE  ⚡${C}               ║"
    echo -e "║  ${W}Dán đường dẫn  → tự cd                 ${C}║"
    echo -e "║  ${W}Nhập tên file  → tự chạy đúng lệnh     ${C}║"
    echo -e "║  ${W}Lệnh thường    → giữ nguyên             ${C}║"
    echo -e "║  ${R}Gõ 'exit' hoặc 'q' để quay lại menu   ${C}║"
    echo -e "╚══════════════════════════════════════════╝${RS}"
    echo ""

    while true; do
        local cwd
        cwd=$(pwd)
        echo -ne "${C}[smart]${Y} $cwd ${G}❯ ${RS}"
        read -r user_input

        [[ -z "$user_input" ]] && continue
        [[ "$user_input" == "exit" || "$user_input" == "quit" || "$user_input" == "q" ]] && break

        smart_run_cmd "$user_input"
    done

    cd ~/Termux-os ; bash os.sh
}

# ─────────────────────────────────────────────────────────
#  [12] Cài Smart Mode vào shell (vĩnh viễn)
# ─────────────────────────────────────────────────────────
12line() {
    # The zsh hook is command_not_found_handler (with trailing 'r').
    # The bash hook is command_not_found_handle (no trailing 'r').
    # We write the correct hook for each shell separately.

    local zsh_smart_block='
# ── SMART MODE (by Termux-OS) ───────────────────────────
# Smart Path: chỉ cần dán đường dẫn → tự cd
# Smart Run:  chỉ cần nhập tên file → tự chạy đúng lệnh
_smart_resolve_path() {
    local raw="$1"
    if [[ "$raw" == "~/"* ]]; then raw="$HOME/${raw:2}"; elif [[ "$raw" == "~" ]]; then raw="$HOME"; fi
    printf '"'"'%s'"'"' "$raw"
}
command_not_found_handler() {
    local input="$*"
    if [[ "$input" == /* || "$input" == "~" || "$input" == "~/"* ]]; then
        local path; path=$(_smart_resolve_path "${input%/}")
        if [ -d "$path" ]; then echo -e "\033[1;96m[Smart Path]\033[0m cd \"$path\""; cd "$path" || return 1; return 0
        else echo -e "\033[1;31m[Lỗi] Không tìm thấy thư mục: $path\033[0m"; return 1; fi
    fi
    local filename="$input" ext="${input##*.}"
    if [[ "$filename" == *.* && "$filename" != *" "* && -f "$filename" ]]; then
        case "$ext" in
            py)   echo -e "\033[1;96m[Smart Run]\033[0m python $filename";      python "$filename";        return $? ;;
            sh)   echo -e "\033[1;96m[Smart Run]\033[0m bash $filename";        bash "$filename";          return $? ;;
            js)   echo -e "\033[1;96m[Smart Run]\033[0m node $filename";        node "$filename";          return $? ;;
            ts)   echo -e "\033[1;96m[Smart Run]\033[0m npx ts-node $filename"; npx ts-node "$filename";   return $? ;;
            php)  echo -e "\033[1;96m[Smart Run]\033[0m php $filename";         php "$filename";           return $? ;;
            rb)   echo -e "\033[1;96m[Smart Run]\033[0m ruby $filename";        ruby "$filename";          return $? ;;
            lua)  echo -e "\033[1;96m[Smart Run]\033[0m lua $filename";         lua "$filename";           return $? ;;
            pl)   echo -e "\033[1;96m[Smart Run]\033[0m perl $filename";        perl "$filename";          return $? ;;
            go)   echo -e "\033[1;96m[Smart Run]\033[0m go run $filename";      go run "$filename";        return $? ;;
            java) local cls="${filename%.java}"; echo -e "\033[1;96m[Smart Run]\033[0m javac $filename && java $cls"; javac "$filename" && java "$cls"; return $? ;;
            c)    local out="${filename%.c}";   echo -e "\033[1;96m[Smart Run]\033[0m gcc $filename -o $out && ./$out"; gcc "$filename" -o "$out" && "./$out"; return $? ;;
            cpp)  local out="${filename%.cpp}"; echo -e "\033[1;96m[Smart Run]\033[0m g++ $filename -o $out && ./$out"; g++ "$filename" -o "$out" && "./$out"; return $? ;;
            rs)   local out="${filename%.rs}";  echo -e "\033[1;96m[Smart Run]\033[0m rustc $filename && ./$out"; rustc "$filename" && "./$out"; return $? ;;
            r|R)  echo -e "\033[1;96m[Smart Run]\033[0m Rscript $filename"; Rscript "$filename"; return $? ;;
        esac
    fi
    echo "command not found: $input"; return 127
}
# ── END SMART MODE ───────────────────────────────────────
'

    # bash uses "command_not_found_handle" (no trailing r)
    local bash_smart_block
    bash_smart_block=$(printf '%s' "$zsh_smart_block" | sed 's/command_not_found_handler/command_not_found_handle/g')

    local marker="# ── SMART MODE (by Termux-OS)"

    # Install into .zshrc (zsh hook)
    if [ -f ~/.zshrc ]; then
        if grep -q "$marker" ~/.zshrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.zshrc, bỏ qua.${RS}"
        else
            printf '\n%s\n' "$zsh_smart_block" >> ~/.zshrc
            echo -e "${G}[✓] Đã cài Smart Mode vào ~/.zshrc${RS}"
        fi
    else
        echo -e "${Y}[!] Không tìm thấy ~/.zshrc${RS}"
    fi

    # Install into .bashrc (bash hook — different function name)
    if [ -f ~/.bashrc ]; then
        if grep -q "$marker" ~/.bashrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.bashrc, bỏ qua.${RS}"
        else
            printf '\n%s\n' "$bash_smart_block" >> ~/.bashrc
            echo -e "${G}[✓] Đã cài Smart Mode vào ~/.bashrc${RS}"
        fi
    fi

    echo -e "${C}\nSmart Mode sẽ hoạt động tự động từ lần mở shell tiếp theo.${RS}"
    echo -e "${W}Hoặc chạy: ${Y}source ~/.zshrc${RS}"
    sleep 3
    menu
}

# ─────────────────────────────────────────────────────────
#  MENU CHÍNH
# ─────────────────────────────────────────────────────────
menu() {
    banner
    printf "\n${left_pad}${C}[${W}01${C}]${G} Cài đặt Cần thiết"
    printf "\n${left_pad}${C}[${W}02${C}]${G} Thiết lập Zsh"
    printf "\n${left_pad}${C}[${W}03${C}]${G} Shell Zsh"
    printf "\n${left_pad}${C}[${W}04${C}]${G} Shell Bash"
    printf "\n${left_pad}${C}[${W}05${C}]${Y} Banner Zsh"
    printf "\n${left_pad}${C}[${W}06${C}]${Y} Giao diện Zsh"
    printf "\n${left_pad}${C}[${W}07${C}]${Y} Tô sáng / Gợi ý tự động"
    printf "\n${left_pad}${C}[${W}08${C}]${B} Thêm Khóa Cyber ${R}(Bảo mật Cao)"
    printf "\n${left_pad}${C}[${W}09${C}]${R} Xóa Khóa"
    printf "\n${left_pad}${C}[${W}10${C}]${W} Cập nhật Script"
    printf "\n${left_pad}${C}[${W}11${C}]${C} ⚡ Smart Mode ${Y}(Chạy tạm thời)"
    printf "\n${left_pad}${C}[${W}12${C}]${G} ⚡ Cài Smart Mode vào Shell ${Y}(Vĩnh viễn)"
    printf "\n${left_pad}${C}[${W}00${C}]${R} Thoát Terminal\n\n"

    echo -ne "${left_pad}${C}Lựa chọn: ${RS}"
    read a
    case $a in
        1|01)  1line  ;;  # Cài đặt Cần thiết
        2|02)  2line  ;;  # Thiết lập Zsh
        3|03)  3line  ;;  # Shell Zsh
        4|04)  4line  ;;  # Shell Bash
        5|05)  5line  ;;  # Banner Zsh
        6|06)  6line  ;;  # Giao diện Zsh
        7|07)  7line  ;;  # Tô sáng / Gợi ý tự động
        8|08)  8line  ;;  # Thêm Khóa Cyber
        9|09)  9line  ;;  # Xóa Khóa
        10)    10line ;;  # Cập nhật Script
        11)    11line ;;  # Smart Mode tạm thời
        12)    12line ;;  # Cài Smart Mode vĩnh viễn
        0|00)  exit   ;;
        *)     menu   ;;
    esac
}
menu
