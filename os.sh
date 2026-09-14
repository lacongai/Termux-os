#!/bin/bash
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;93m'
B='\033[1;94m'
C='\033[1;96m'
W='\033[1;97m'
RS='\033[0m'

cd $HOME 2>/dev/null || cd /data/data/com.termux/files/home

term_width=$(tput cols 2>/dev/null || echo 80)
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
    echo -e "\033[1;36m ______                              \033[1;31m  ___  ____"
    echo -e "\033[1;36m/_  __/__  _________ ___  __  ___  __\033[1;31m / _ \/ __/"
    echo -e "\033[1;36m / / / _ \/ ___/ __ '__ \/ / / / |/_/\033[1;31m/ // /\ \  "
    echo -e "\033[1;36m/_/  \___/_/  /_/ /_/ /_/\__,_/_/|_| \033[1;31m\___/___/  "
    echo -e ""
    echo -e "\033[1;97m      --[ \033[1;32mCông Cụ Tối Ưu Termux \033[1;97m]--       "
    echo -e ""
    echo -e "\033[1;31m [!]\033[1;97m Author  : \033[1;36mGấu Ngốc Nghếch (henntaiiz)"
    echo -e "\033[1;31m [!]\033[1;97m Version : \033[1;93mv2 (Stable)"
    echo -e "\033[1;31m [!]\033[1;97m Youtube : youtube.com/henntaiiz"
    echo -e "\033[1;31m [!]\033[1;97m GitHub  : github.com/lacongai"
    echo -e ""
    echo -e "\033[1;32m ==============================================\033[0m"
    echo -e ""
}

_banner_7mau() {
    local text="$1"
    local font="$2"
    local width="$3"

    if command -v toilet &>/dev/null; then
        toilet -f "$font" -w "$width" --gay "$text" 2>/dev/null && return $?
        toilet -w "$width" --gay "$text" 2>/dev/null && return $?
    fi

    if command -v lolcat &>/dev/null && echo "x" | lolcat &>/dev/null 2>&1; then
        figlet -c -f "$font" -w "$width" "$text" 2>/dev/null | lolcat -f
        return $?
    fi

    figlet -c -f "$font" -w "$width" "$text" 2>/dev/null || \
        figlet -c "$text" 2>/dev/null || \
        echo "  $text  "
}

# ══════════════════════════════════════════════════════════
#  AUTO UPDATE — chạy mỗi khi mở tool
# ══════════════════════════════════════════════════════════
_auto_update_check() {
    [ ! -d ~/Termux-os/.git ] && return 0
    command -v git &>/dev/null || return 0

    cd ~/Termux-os 2>/dev/null || return 0
    git fetch origin &>/dev/null || return 0

    local branch local_c remote_c
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -z "$branch" ] && return 0
    local_c=$(git rev-parse HEAD 2>/dev/null)
    remote_c=$(git rev-parse "origin/$branch" 2>/dev/null)

    if [ -n "$local_c" ] && [ -n "$remote_c" ] && [ "$local_c" != "$remote_c" ]; then
        echo -e "\n${Y}[!] Có bản cập nhật mới trên GitHub!${RS}"
        echo -ne "${C}Cập nhật ngay? (y/n, Enter=y): ${RS}"
        read -r _ans
        if [ -z "$_ans" ] || [[ "$_ans" =~ ^[Yy]$ ]]; then
            if git pull origin "$branch" &>/dev/null; then
                echo -e "${G}[✓] Đã cập nhật!${RS}"
                sleep 1
                cd $HOME
                bash ~/Termux-os/os.sh
                exit 0
            else
                git reset --hard "origin/$branch" &>/dev/null
                git pull origin "$branch" &>/dev/null
                echo -e "${G}[✓] Đã ép cập nhật!${RS}"
                sleep 1
                cd $HOME
                bash ~/Termux-os/os.sh
                exit 0
            fi
        fi
    fi
}

cd $HOME
_auto_update_check

# ══════════════════════════════════════════════════════════
#  1line — 2 GIAI ĐOẠN
# ══════════════════════════════════════════════════════════
1line() {
    local FLAG="$HOME/.termux-os-installed"

    _kill_all_tabs() {
        local my_pid=$$
        for shell in zsh bash sh; do
            for pid in $(pgrep -f "/$shell" 2>/dev/null); do
                [ "$pid" != "$my_pid" ] && kill -TERM "$pid" 2>/dev/null || true
            done
        done
        sleep 0.3
        for shell in zsh bash sh; do
            for pid in $(pgrep -f "/$shell" 2>/dev/null); do
                [ "$pid" != "$my_pid" ] && kill -9 "$pid" 2>/dev/null || true
            done
        done
        for pid in $(pgrep -f "com.termux/files/usr/bin" 2>/dev/null); do
            [ "$pid" != "$my_pid" ] && kill -9 "$pid" 2>/dev/null || true
        done
    }

    _install_banner_tool() {
        echo -e "${C}[*] Cài công cụ banner 7 màu...${RS}"
        pkg install toilet -y 2>/dev/null || true
        if command -v toilet &>/dev/null; then
            echo -e "${G}[✓] toilet hoạt động — dùng toilet --gay cho banner${RS}"
        fi
    }

    # ══════════════════════════════════════════════════════════
    #  LẦN 2+ : cài lại → kill tabs → EXIT
    # ══════════════════════════════════════════════════════════
    if [ -f "$FLAG" ]; then
        echo -e "\n${Y}[Lần 2+] Đang cài lại các lệnh và làm mới cấu hình...${RS}\n"

        apt update && apt upgrade -y
        pkg install zsh git figlet toilet ruby wget curl -y
        pkg install eza -y 2>/dev/null || true
        _install_banner_tool

        clear
        if [ -d "$HOME/Termux-os/.object" ]; then
            cd "$HOME/Termux-os/.object" || cd $HOME
            [ -f 'ANSI Shadow.flf' ] && \
                cp -r 'ANSI Shadow.flf' "$PREFIX/share/figlet/ASCII-Shadow.flf" 2>/dev/null

            rm -rf ~/.termux/colors.properties
            rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null
            mkdir -p ~/.termux
            [ -f .colors.properties ] && cp -r .colors.properties ~/.termux/colors.properties
            [ -f .termux.properties ] && cp -r .termux.properties ~/.termux.properties
        fi

        curl -L --max-time 60 \
            https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf \
            > ~/.termux/font.ttf 2>/dev/null || true

        clear
        cd $HOME

        termux-reload-settings 2>/dev/null || true

        echo -e "\n${C}[*] Đang đóng tất cả các tab Termux...${RS}"
        sleep 1
        _kill_all_tabs

        echo -e "\n${G}[✓] Đã cài lại xong. Đang đóng Termux...${RS}"
        sleep 1
        input keyevent KEYCODE_HOME 2>/dev/null || true
        sleep 1
        cd $HOME
        clear
        exit 0
    fi

    # ══════════════════════════════════════════════════════════
    #  LẦN 1 : cài đầy đủ → flag → menu
    # ══════════════════════════════════════════════════════════
    echo -e "\n${C}[Lần đầu] Đang cài đặt đầy đủ...${RS}\n"

    apt update && apt upgrade -y
    pkg install zsh git figlet toilet ruby wget curl -y
    pkg install eza -y 2>/dev/null || true
    _install_banner_tool

    clear
    if [ -d "$HOME/Termux-os/.object" ]; then
        cd "$HOME/Termux-os/.object" || cd $HOME
        [ -f 'ANSI Shadow.flf' ] && \
            cp -r 'ANSI Shadow.flf' "$PREFIX/share/figlet/ASCII-Shadow.flf" 2>/dev/null
    fi

    [ ! -d ~/.oh-my-zsh ] && \
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

    pkg install toilet figlet -y 2>/dev/null || true

    if [ -d "$HOME/Termux-os/.object" ]; then
        cd "$HOME/Termux-os/.object" || cd $HOME
        rm -rf ~/.termux/colors.properties
        rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null
        mkdir -p ~/.termux
        [ -f .colors.properties ] && cp -r .colors.properties ~/.termux/colors.properties
        [ -f .termux.properties ] && cp -r .termux.properties ~/.termux.properties
    fi

    curl -L --max-time 60 \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf \
        > ~/.termux/font.ttf 2>/dev/null || true

    clear
    cd $HOME

    termux-reload-settings 2>/dev/null || true

    touch "$FLAG"
    echo -e "\n${G}[✓] Đã cài đặt xong!${RS}"
    echo -e "${W}→ Chọn các chức năng bạn muốn ở menu dưới.${RS}"
    echo -e "${W}→ Sau khi xong, ấn ${Y}1${W} lần nữa để cài lại + kill tabs + thoát.${RS}"
    echo ""
    sleep 4
    cd $HOME
    menu
}

# ══════════════════════════════════════════════════════════
#  Các hàm chức năng — KHÔNG DÙNG exec
# ══════════════════════════════════════════════════════════
2line() {
    cd $HOME
    rm -rf ~/.oh-my-zsh
    rm -f ~/.zshrc
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    [ -f ~/.oh-my-zsh/templates/zshrc.zsh-template ] && \
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    cd $HOME
    echo ""
    echo -e "${G}[✓] Đã thiết lập Zsh xong. Nhấn Enter để tiếp tục...${RS}"
    read -r
    menu
}
3line() {
    cd $HOME
    pkg install zsh -y
    chsh -s zsh
    echo ""
    echo -e "${G}[✓] Đã chuyển sang Zsh.${RS}"
    sleep 2
    menu
}
4line() {
    cd $HOME
    chsh -s bash
    echo ""
    echo -e "${G}[✓] Đã chuyển sang Bash.${RS}"
    sleep 2
    menu
}
5line() {
    cd $HOME
    rm -f ~/.zshrc
    [ -d ~/Termux-os/.object ] && cd ~/Termux-os/.object && bash .2.sh
    cd $HOME
    echo ""
    echo -e "${G}[✓] Đã cài Banner Zsh. Nhấn Enter để tiếp tục...${RS}"
    read -r
    menu
}
6line() {
    cd $HOME
    [ -d ~/Termux-os/.object ] && cd ~/Termux-os/.object && bash .1.sh
    cd $HOME
    echo ""
    echo -e "${G}[✓] Đã cài Giao diện Zsh. Nhấn Enter để tiếp tục...${RS}"
    read -r
    menu
}
7line() {
    cd $HOME
    rm -f ~/.zshrc
    chsh -s zsh
    [ -f ~/Termux-os/.object/.3.sh ] && bash ~/Termux-os/.object/.3.sh
    cd $HOME
    echo ""
    echo -e "${G}[✓] Đã cài Tô sáng / Gợi ý. Nhấn Enter để tiếp tục...${RS}"
    read -r
    menu
}
10line() {
    cd $HOME
    if [ ! -d ~/Termux-os/.git ]; then
        echo -e "${Y}[!] Không phải Git repo. Cài lại từ đầu...${RS}"
        rm -rf ~/Termux-os
        git clone https://github.com/lacongai/Termux-os ~/Termux-os
        cd $HOME
        bash ~/Termux-os/os.sh
        exit 0
    fi

    cd ~/Termux-os
    git fetch origin &>/dev/null
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    local local_commit remote_commit
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch")

    if [ "$local_commit" = "$remote_commit" ]; then
        echo -e "${G}[✓] Tool đang là phiên bản mới nhất!${RS}"
        sleep 2
        menu
    else
        echo -e "${Y}[!] Phát hiện phiên bản mới! Đang cập nhật...${RS}"
        if git pull origin "$current_branch"; then
            echo -e "${G}[✓] Cập nhật thành công!${RS}"
            sleep 2
            cd $HOME
            bash ~/Termux-os/os.sh
            exit 0
        else
            git reset --hard "origin/$current_branch"
            git pull origin "$current_branch"
            echo -e "${G}[✓] Đã ép cập nhật!${RS}"
            sleep 2
            cd $HOME
            bash ~/Termux-os/os.sh
            exit 0
        fi
    fi
}

# ─────────────────────────────────────────────────────────
#  CYBER LOCK
# ─────────────────────────────────────────────────────────
8line() {
    echo -e "\n${C}Khởi tạo Giao thức Bảo mật...${RS}"
    echo -ne "${Y}Tạo Khóa Truy cập: ${RS}"
    read -s new_pass
    echo

    local key_dir="/storage/emulated/0/Termux-os"
    mkdir -p "$key_dir"
    printf '%s' "$new_pass" > "$key_dir/key"
    echo -e "${G}Đã lưu mật khẩu vào: ${key_dir}/key${RS}"

    local safe_pass
    safe_pass=$(printf '%s' "$new_pass" | sed "s/'/'\\\\''/g")

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
    printf '\n\033[1;96m+--------------------------------------+\n'
    printf '|        \033[1;31mTRUY CẬP SHELL BẢO MẬT           \033[1;96m|\n'
    printf '+--------------------------------------+\033[0m\n'
    printf '\033[1;93m [Attempt %s/3] Enter Key (Ấn Enter xem Key): \033[0m' "\$attempt"
    read -s pass_input
    echo

    if [ -z "\$pass_input" ]; then
        echo -e "\n\033[1;33m[!] Bạn đã để trống hoặc quên mật khẩu?\033[0m"
        echo -ne "\033[1;96mBạn có muốn tự động cập nhật lại tool và gỡ bỏ khóa không? (y/n): \033[0m"
        read -r choice_update
        if [[ "\$choice_update" =~ ^[Yy]$ ]]; then
            rm -rf ~/Termux-os
            cd ~ && git clone https://github.com/lacongai/Termux-os
            sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
            [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
            echo -e "\n\033[1;32m[✓] Cập nhật và gỡ khóa thành công!\033[0m"
            sleep 2
            cd ~/Termux-os && bash ~/Termux-os/os.sh
            return
        else
            if [ -f "/storage/emulated/0/Termux-os/key" ]; then
                echo -e "\n\033[1;32m[!] Mật khẩu của bạn là: \033[1;33m\$(cat /storage/emulated/0/Termux-os/key)\033[0m"
            fi
            echo -ne "\n\033[1;93mNhập lại Key: \033[0m"
            read -s pass_input
            echo
        fi
    fi

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

    echo -e "${G}Đã cấu hình Khóa ở ĐẦU tệp tin.${RS}"
    sleep 2
    menu
}

9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    rm -f /storage/emulated/0/Termux-os/key
    echo -e "${R}Đã hủy Giao thức Bảo mật và xóa file Key.${RS}"
    sleep 2
    menu
}

# ─────────────────────────────────────────────────────────
#  SMART MODE
# ─────────────────────────────────────────────────────────
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

if [ -z "$TMPDIR" ]; then
    export TMPDIR="$PREFIX/tmp"
fi
mkdir -p "$TMPDIR" 2>/dev/null

_is_whitelisted() {
    case "$1" in
        lolcat|figlet|toilet|ls|ll|la|cd|pwd|clear|echo|cat|source|exit|kill|sleep|man|help|history|which|whereis|type|alias|unalias|export|unset|set|read|printf|test|true|false)
            return 0 ;;
        *) return 1 ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift; local args=("$@")

    if _is_whitelisted "$cmd"; then
        echo "zsh: command not found: $cmd"
        return 127
    fi

    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    _spin() {
        local pid=$1 label=$2 text=$3 i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[%s]${_AI_RST} ${_AI_Y}%s${_AI_RST} %s" "$label" "${frames[$i]}" "$text"
            i=$(( (i + 1) % 10 )); sleep 0.1
        done
        printf "\r\033[2K"
    }

    echo -e "${_AI_C}[Auto]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    local lf="${tmp_dir}/_ai_$$.log" cf="${tmp_dir}/_ai_$$.code"
    ( pkg install -y "$cmd" &>"$lf"; echo $? > "$cf" ) &
    _spin $! "Auto" "Đang cài '${cmd}'..."
    wait $! 2>/dev/null
    if [[ "$(cat "$cf" 2>/dev/null)" == "0" ]] && command -v "$cmd" &>/dev/null; then
        rm -f "$lf" "$cf"
        echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${cmd}'"
        "$cmd" "${args[@]}"; return $?
    fi
    rm -f "$lf" "$cf"

    echo -e "${_AI_R}[Auto]${_AI_RST} 'pkg install ${cmd}' thất bại → hỏi Gemini AI..."
    local pkg_hint="" manager_hint=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="${tmp_dir}/_ai_g_$$.json"
        local payload
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

        (
          curl -sf --max-time 25 \
            -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        _spin $! "AI" "Đang hỏi Gemini tìm gói cho '${cmd}'..."
        wait $! 2>/dev/null

        local raw
        raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
              | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
        rm -f "$ai_out" 2>/dev/null

        if [[ "$raw" == *:* ]]; then
            manager_hint="${raw%%:*}"
            pkg_hint="${raw#*:}"
        else
            pkg_hint="$raw"
        fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        if [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]]; then
            pkg_hint=""
        fi
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[AI]${_AI_RST} Gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"
        echo -ne "${_AI_Y}Cài ngay? (y/n, Enter=y): ${_AI_RST}"
        read -r ans
        if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
            local lf2="${tmp_dir}/_ai2_$$.log" cf2="${tmp_dir}/_ai2_$$.code"
            case "$manager_hint" in
                pkg)   ( pkg install -y "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                pip)   ( pip install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
                npm)   ( npm install -g "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                gem)   ( timeout 20 gem install "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                cargo) ( cargo install "$pkg_hint"  &>"$lf2"; echo $? > "$cf2" ) & ;;
            esac
            _spin $! "Auto" "${manager_hint} install ${pkg_hint}..."
            wait $! 2>/dev/null
            local rc; rc=$(cat "$cf2" 2>/dev/null)
            rm -f "$lf2" "$cf2"
            if [[ "$rc" == "0" ]] && command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${pkg_hint}' — chạy '${cmd}'"
                "$cmd" "${args[@]}"; return $?
            fi
            if [[ "$rc" == "0" ]]; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Cài xong '${pkg_hint}'"
                "$cmd" "${args[@]}" 2>/dev/null || true
                return $?
            fi
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        local idx=1
        while IFS= read -r p; do echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${p}"; idx=$((idx+1)); done <<< "$alt_list"
        echo -ne "${_AI_Y}Chọn số (Enter=bỏ qua): ${_AI_RST}"
        read -r ch
        if [[ "$ch" =~ ^[0-9]+$ && "$ch" -ge 1 ]]; then
            local sel; sel=$(echo "$alt_list" | sed -n "${ch}p")
            if [[ -n "$sel" ]]; then
                ( pkg install -y "$sel" &>/dev/null; ) &
                _spin $! "Auto" "pkg install ${sel}..."
                wait $! 2>/dev/null
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${sel}'"
                    "$cmd" "${args[@]}"; return $?
                fi
            fi
        fi
    fi

    echo -e "${_AI_R}[Auto]${_AI_RST} Không cài được '${cmd}'."
    return 127
}

command_not_found_handler() {
    _auto_install "$@"
    return $?
}

# ─────────────────────────────────────────────────────────
#  [12] Cài Smart Mode vào shell (vĩnh viễn)
# ─────────────────────────────────────────────────────────
12line() {
    local marker="# SMART MODE (by Termux-OS)"

    if [ -f ~/.zshrc ]; then
        if grep -q "$marker" ~/.zshrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.zshrc${RS}"
        else
            cat >> ~/.zshrc << 'ZSH_SMART_EOF'

# ══════════════════════════════════════════════════════════
# SMART MODE (by Termux-OS)
# ══════════════════════════════════════════════════════════

unsetopt NOMATCH 2>/dev/null
unsetopt PROMPT_SP 2>/dev/null
cd $HOME 2>/dev/null

(( ${+ZSH_HIGHLIGHT_STYLES} )) && ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow,bold'

_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

_smart_accept_line() {
    local buf="$BUFFER"
    local trimmed="${buf#"${buf%%[! ]*}"}"
    trimmed="${trimmed%"${trimmed##*[! ]}"}"
    if [[ "$trimmed" == /* || "$trimmed" == '~' || "$trimmed" == '~/'* ]]; then
        local path="${trimmed%/}"
        path="${path/#\~/$HOME}"
        if [[ -d "$path" ]]; then
            BUFFER="${(q)path}"
            zle .accept-line
            return
        else
            print "\n${_SR_ERR}[Lỗi] Không tìm thấy thư mục: ${path}${_SR_RST}"
            zle reset-prompt
            return
        fi
    fi
    zle .accept-line
}
zle -N accept-line _smart_accept_line

_is_whitelisted() {
    case "$1" in
        lolcat|figlet|toilet|ls|ll|la|cd|pwd|clear|echo|cat|source|exit|kill|sleep|man|help|history|which|whereis|type|alias|unalias|export|unset|set|read|printf|test|true|false)
            return 0 ;;
        *) return 1 ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    if _is_whitelisted "$cmd"; then
        echo "zsh: command not found: $cmd"
        return 127
    fi
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    setopt LOCAL_OPTIONS; unsetopt NOTIFY

    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    _spin() {
        local pid=$1 label=$2 text=$3 i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[%s]${_AI_RST} ${_AI_Y}%s${_AI_RST} %s" "$label" "${frames[$i]}" "$text"
            i=$(( (i + 1) % 10 )); sleep 0.1
        done
        printf "\r\033[2K"
    }

    echo -e "${_AI_C}[Auto]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    local lf="${tmp_dir}/_ai_$$.log" cf="${tmp_dir}/_ai_$$.code"
    ( pkg install -y "$cmd" &>"$lf"; echo $? > "$cf" ) &
    _spin $! "Auto" "Đang cài '${cmd}'..."
    wait $! 2>/dev/null
    if [[ "$(cat "$cf" 2>/dev/null)" == "0" ]] && command -v "$cmd" &>/dev/null; then
        rm -f "$lf" "$cf"
        echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${cmd}'"
        "$cmd" "${args[@]}"; return $?
    fi
    rm -f "$lf" "$cf"

    echo -e "${_AI_R}[Auto]${_AI_RST} 'pkg install ${cmd}' thất bại → hỏi Gemini AI..."
    local pkg_hint="" manager_hint=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="${tmp_dir}/_ai_g_$$.json"
        local payload
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

        (
          curl -sf --max-time 25 \
            -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        _spin $! "AI" "Đang hỏi Gemini tìm gói cho '${cmd}'..."
        wait $! 2>/dev/null

        local raw
        raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
              | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
        rm -f "$ai_out" 2>/dev/null

        if [[ "$raw" == *:* ]]; then
            manager_hint="${raw%%:*}"
            pkg_hint="${raw#*:}"
        else
            pkg_hint="$raw"
        fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        if [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]]; then
            pkg_hint=""
        fi
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[AI]${_AI_RST} Gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"
        echo -ne "${_AI_Y}Cài ngay? (y/n, Enter=y): ${_AI_RST}"
        read -r ans
        if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
            local lf2="${tmp_dir}/_ai2_$$.log" cf2="${tmp_dir}/_ai2_$$.code"
            case "$manager_hint" in
                pkg)   ( pkg install -y "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                pip)   ( pip install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
                npm)   ( npm install -g "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                gem)   ( timeout 20 gem install "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                cargo) ( cargo install "$pkg_hint"  &>"$lf2"; echo $? > "$cf2" ) & ;;
            esac
            _spin $! "Auto" "${manager_hint} install ${pkg_hint}..."
            wait $! 2>/dev/null
            local rc; rc=$(cat "$cf2" 2>/dev/null)
            rm -f "$lf2" "$cf2"
            if [[ "$rc" == "0" ]] && command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${pkg_hint}' — chạy '${cmd}'"
                "$cmd" "${args[@]}"; return $?
            fi
            if [[ "$rc" == "0" ]]; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Cài xong '${pkg_hint}'"
                "$cmd" "${args[@]}" 2>/dev/null || true
                return $?
            fi
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        local idx=1
        while IFS= read -r p; do echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${p}"; idx=$((idx+1)); done <<< "$alt_list"
        echo -ne "${_AI_Y}Chọn số (Enter=bỏ qua): ${_AI_RST}"
        read -r ch
        if [[ "$ch" =~ ^[0-9]+$ && "$ch" -ge 1 ]]; then
            local sel; sel=$(echo "$alt_list" | sed -n "${ch}p")
            if [[ -n "$sel" ]]; then
                ( pkg install -y "$sel" &>/dev/null; ) &
                _spin $! "Auto" "pkg install ${sel}..."
                wait $! 2>/dev/null
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${sel}'"
                    "$cmd" "${args[@]}"; return $?
                fi
            fi
        fi
    fi
    return 127
}

command_not_found_handler() {
    _auto_install "$@"
    return $?
}
# ══════════════════════════════════════════════════════════
# END SMART MODE
# ══════════════════════════════════════════════════════════
ZSH_SMART_EOF
            echo -e "${G}[✓] Đã cài Smart Mode vào ~/.zshrc${RS}"
        fi
    fi

    if [ -f ~/.bashrc ]; then
        if grep -q "$marker" ~/.bashrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.bashrc${RS}"
        else
            cat >> ~/.bashrc << 'BASH_SMART_EOF'

# ══════════════════════════════════════════════════════════
# SMART MODE (by Termux-OS)
# ══════════════════════════════════════════════════════════

cd $HOME 2>/dev/null
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

_is_whitelisted() {
    case "$1" in
        lolcat|figlet|toilet|ls|ll|la|cd|pwd|clear|echo|cat|source|exit|kill|sleep|man|help|history|which|whereis|type|alias|unalias|export|unset|set|read|printf|test|true|false)
            return 0 ;;
        *) return 1 ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    if _is_whitelisted "$cmd"; then
        echo "bash: command not found: $cmd"
        return 127
    fi
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    _spin() {
        local pid=$1 label=$2 text=$3 i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[%s]${_AI_RST} ${_AI_Y}%s${_AI_RST} %s" "$label" "${frames[$i]}" "$text"
            i=$(( (i + 1) % 10 )); sleep 0.1
        done
        printf "\r\033[2K"
    }

    echo -e "${_AI_C}[Auto]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    local lf="${tmp_dir}/_ai_$$.log" cf="${tmp_dir}/_ai_$$.code"
    ( pkg install -y "$cmd" &>"$lf"; echo $? > "$cf" ) &
    _spin $! "Auto" "Đang cài '${cmd}'..."
    wait $! 2>/dev/null
    if [[ "$(cat "$cf" 2>/dev/null)" == "0" ]] && command -v "$cmd" &>/dev/null; then
        rm -f "$lf" "$cf"
        echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${cmd}'"
        "$cmd" "${args[@]}"; return $?
    fi
    rm -f "$lf" "$cf"

    echo -e "${_AI_R}[Auto]${_AI_RST} 'pkg install ${cmd}' thất bại → hỏi Gemini AI..."
    local pkg_hint="" manager_hint=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="${tmp_dir}/_ai_g_$$.json"
        local payload
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

        (
          curl -sf --max-time 25 \
            -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        _spin $! "AI" "Đang hỏi Gemini tìm gói cho '${cmd}'..."
        wait $! 2>/dev/null

        local raw
        raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
              | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
        rm -f "$ai_out" 2>/dev/null

        if [[ "$raw" == *:* ]]; then
            manager_hint="${raw%%:*}"
            pkg_hint="${raw#*:}"
        else
            pkg_hint="$raw"
        fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        if [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]]; then
            pkg_hint=""
        fi
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[AI]${_AI_RST} Gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"
        echo -ne "${_AI_Y}Cài ngay? (y/n, Enter=y): ${_AI_RST}"
        read -r ans
        if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
            local lf2="${tmp_dir}/_ai2_$$.log" cf2="${tmp_dir}/_ai2_$$.code"
            case "$manager_hint" in
                pkg)   ( pkg install -y "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                pip)   ( pip install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
                npm)   ( npm install -g "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                gem)   ( timeout 20 gem install "$pkg_hint" &>"$lf2"; echo $? > "$cf2" ) & ;;
                cargo) ( cargo install "$pkg_hint"  &>"$lf2"; echo $? > "$cf2" ) & ;;
            esac
            _spin $! "Auto" "${manager_hint} install ${pkg_hint}..."
            wait $! 2>/dev/null
            local rc; rc=$(cat "$cf2" 2>/dev/null)
            rm -f "$lf2" "$cf2"
            if [[ "$rc" == "0" ]] && command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${pkg_hint}' — chạy '${cmd}'"
                "$cmd" "${args[@]}"; return $?
            fi
            if [[ "$rc" == "0" ]]; then
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Cài xong '${pkg_hint}'"
                "$cmd" "${args[@]}" 2>/dev/null || true
                return $?
            fi
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        local idx=1
        while IFS= read -r p; do echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${p}"; idx=$((idx+1)); done <<< "$alt_list"
        echo -ne "${_AI_Y}Chọn số (Enter=bỏ qua): ${_AI_RST}"
        read -r ch
        if [[ "$ch" =~ ^[0-9]+$ && "$ch" -ge 1 ]]; then
            local sel; sel=$(echo "$alt_list" | sed -n "${ch}p")
            if [[ -n "$sel" ]]; then
                ( pkg install -y "$sel" &>/dev/null; ) &
                _spin $! "Auto" "pkg install ${sel}..."
                wait $! 2>/dev/null
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Đã cài '${sel}'"
                    "$cmd" "${args[@]}"; return $?
                fi
            fi
        fi
    fi
    return 127
}

command_not_found_handle() {
    _auto_install "$@"
    return $?
}
# ══════════════════════════════════════════════════════════
# END SMART MODE
# ══════════════════════════════════════════════════════════
BASH_SMART_EOF
            echo -e "${G}[✓] Đã cài Smart Mode vào ~/.bashrc${RS}"
        fi
    fi

    echo -e "${C}\nSmart Mode sẽ hoạt động từ lần mở shell tiếp theo.${RS}"
    echo -e "${W}Hoặc chạy ngay: ${Y}source ~/.zshrc${RS}"
    sleep 3
    menu
}

# ─────────────────────────────────────────────────────────
#  MENU CHÍNH
# ─────────────────────────────────────────────────────────
menu() {
    banner
    printf "\n%s${C}[${W}01${C}]${G} Cài đặt Cần thiết" "$left_pad"
    printf "\n%s${C}[${W}02${C}]${G} Thiết lập Zsh" "$left_pad"
    printf "\n%s${C}[${W}03${C}]${G} Shell Zsh" "$left_pad"
    printf "\n%s${C}[${W}04${C}]${G} Shell Bash" "$left_pad"
    printf "\n%s${C}[${W}05${C}]${Y} Banner Zsh" "$left_pad"
    printf "\n%s${C}[${W}06${C}]${Y} Giao diện Zsh" "$left_pad"
    printf "\n%s${C}[${W}07${C}]${Y} Tô sáng / Gợi ý tự động" "$left_pad"
    printf "\n%s${C}[${W}08${C}]${B} Thêm Khóa Cyber ${R}(Bảo mật Cao)" "$left_pad"
    printf "\n%s${C}[${W}09${C}]${R} Xóa Khóa" "$left_pad"
    printf "\n%s${C}[${W}10${C}]${W} Cập nhật Script" "$left_pad"
    printf "\n%s${C}[${W}12${C}]${G} ⚡ Cài Smart Mode vào Shell ${Y}(Vĩnh viễn)" "$left_pad"
    printf "\n%s${C}[${W}00${C}]${R} Thoát Terminal\n\n" "$left_pad"

    printf "%s${C}Lựa chọn: ${RS}" "$left_pad"
    read a
    case $a in
        1|01)  1line  ;;
        2|02)  2line  ;;
        3|03)  3line  ;;
        4|04)  4line  ;;
        5|05)  5line  ;;
        6|06)  6line  ;;
        7|07)  7line  ;;
        8|08)  8line  ;;
        9|09)  9line  ;;
        10)    10line ;;
        12)    12line ;;
        0|00)  cd $HOME; clear; exit 0 ;;
        *)     menu   ;;
    esac
}
menu