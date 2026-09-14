#!/bin/bash
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;93m'
B='\033[1;94m'
C='\033[1;96m'
W='\033[1;97m'
RS='\033[0m'

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

# ══════════════════════════════════════════════════════════
#  1line — GIỐNG BẢN GỐC + 2 GIAI ĐOẠN
#  Lần 1: cài đầy đủ → tạo flag → quay lại menu chọn chức năng
#  Lần 2+: cài lại lệnh → reload settings → thoát app
# ══════════════════════════════════════════════════════════
1line() {
    local FLAG="$HOME/.termux-os-installed"

    # ══════════════════════════════════════════════════════════
    #  LẦN 2+ : đã có flag → cài lại đầy đủ → reload → EXIT
    # ══════════════════════════════════════════════════════════
    if [ -f "$FLAG" ]; then
        echo -e "\n${Y}[Lần 2+] Đang cài lại các lệnh và làm mới cấu hình...${RS}\n"

        # 1. Cập nhật apt
        apt update && apt upgrade -y

        # 2. Cài gói cơ bản (bỏ exa → dùng eza)
        pkg install zsh git figlet toilet ruby wget curl -y
        pkg install eza -y 2>/dev/null || true

        # 3. Cài lolcat đảm bảo
        gem install lolcat --no-document 2>/dev/null || gem install lolcat 2>/dev/null || true

        # 4. Clear + copy figlet font
        clear
        cd ~/Termux-os/.object/ && \
            cp -r 'ANSI Shadow.flf' "$PREFIX/share/figlet/ASCII-Shadow.flf" 2>/dev/null

        # 5. Cài lại toilet figlet (phòng khi thiếu)
        pkg install toilet figlet -y 2>/dev/null || true

        # 6. Vào thư mục .object + copy config Termux
        cd ~/Termux-os/.object 2>/dev/null
        rm -rf ~/.termux/colors.properties
        rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null
        mkdir -p ~/.termux
        cp -r .colors.properties ~/.termux/colors.properties
        cp -r .termux.properties ~/.termux.properties

        # 7. Tải font FiraCode Nerd Font
        curl -L --max-time 60 \
            https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf \
            > ~/.termux/font.ttf 2>/dev/null || true

        # 8. Clear + về thư mục gốc tool
        clear
        cd ~/Termux-os

        # 9. Reload settings (đã bỏ termux-open-url h4ck3r.me)
        termux-reload-settings 2>/dev/null || true

        # 10. Thông báo + thoát
        echo -e "\n${G}[✓] Đã cài lại xong.${RS}"
        echo -e "${Y}→ Đang đưa Termux về nền...${RS}"
        sleep 2
        # Đưa app về nền (giống ấn Home) — không kill app
        input keyevent KEYCODE_HOME 2>/dev/null || true
        sleep 1
        exit 0
    fi

    # ══════════════════════════════════════════════════════════
    #  LẦN 1 : cài đầy đủ (giống bản gốc) → tạo flag → menu
    # ══════════════════════════════════════════════════════════
    echo -e "\n${C}[Lần đầu] Đang cài đặt đầy đủ...${RS}\n"

    # 1. Cập nhật apt
    apt update && apt upgrade -y

    # 2. Cài gói cơ bản
    pkg install zsh git figlet toilet ruby wget curl -y

    # 3. Cài eza (thay exa)
    pkg install eza -y 2>/dev/null || true

    # 4. Cài lolcat đảm bảo
    gem install lolcat --no-document 2>/dev/null || gem install lolcat 2>/dev/null || true

    # 5. Clear + copy figlet font
    clear
    cd ~/Termux-os/.object/ && \
        cp -r 'ANSI Shadow.flf' "$PREFIX/share/figlet/ASCII-Shadow.flf" 2>/dev/null

    # 6. Clone Oh-My-Zsh (chỉ nếu chưa có)
    [ ! -d ~/.oh-my-zsh ] && \
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

    # 7. Cài lại toilet figlet cho chắc
    pkg install toilet figlet -y 2>/dev/null || true

    # 8. Copy config Termux
    cd ~/Termux-os/.object 2>/dev/null
    rm -rf ~/.termux/colors.properties
    rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null
    mkdir -p ~/.termux
    cp -r .colors.properties ~/.termux/colors.properties
    cp -r .termux.properties ~/.termux.properties

    # 9. Tải font FiraCode Nerd Font
    curl -L --max-time 60 \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf \
        > ~/.termux/font.ttf 2>/dev/null || true

    # 10. Clear + về thư mục gốc tool
    clear
    cd ~/Termux-os

    # 11. Reload settings (đã bỏ termux-open-url h4ck3r.me)
    termux-reload-settings 2>/dev/null || true

    # 12. Tạo flag + quay lại menu
    touch "$FLAG"
    echo -e "\n${G}[✓] Đã cài đặt xong!${RS}"
    echo -e "${W}→ Chọn các chức năng bạn muốn ở menu dưới.${RS}"
    echo -e "${W}→ Sau khi xong, ấn ${Y}1${W} lần nữa để cài lại và thoát Termux.${RS}"
    echo ""
    sleep 4
    menu
}

# ── Các hàm chức năng (giống bản gốc) ────────────────────────
2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh; }
10line() { rm -rf ~/Termux-os; cd; git clone https://github.com/lacongai/Termux-os; cd ~/Termux-os ; bash os.sh; }

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
            echo -e "\n\033[1;33m[!] Đang tiến hành cập nhật lại tool từ GitHub...\033[0m"
            rm -rf ~/Termux-os
            cd ~ && git clone https://github.com/lacongai/Termux-os
            sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
            [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
            echo -e "\n\033[1;32m[✓] Cập nhật và gỡ khóa thành công! Đang khởi động lại...\033[0m"
            sleep 2
            cd ~/Termux-os && bash os.sh
            return
        else
            if [ -f "/storage/emulated/0/Termux-os/key" ]; then
                echo -e "\n\033[1;32m[!] Mật khẩu của bạn là: \033[1;33m\$(cat /storage/emulated/0/Termux-os/key)\033[0m"
            else
                echo -e "\n\033[1;31m[!] Không tìm thấy file chứa key!\033[0m"
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
            echo -e "\n\033[1;31m[!] Hết lượt thử. Đang khởi động lại...\033[0m"
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
#  SMART MODE — tạm thời (11) + vĩnh viễn (12)
# ─────────────────────────────────────────────────────────
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

if [ -z "$TMPDIR" ]; then
    export TMPDIR="$PREFIX/tmp"
fi
mkdir -p "$TMPDIR" 2>/dev/null

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
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
                gem)   ( gem install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
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
            echo -e "${_AI_R}[Auto]${_AI_RST} ✗ Cài '${pkg_hint}' thất bại."
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto]${_AI_RST} Gói liên quan:"
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

smart_run_cmd() {
    local input="$*"

    if [[ "$input" == /* || "$input" == "~" || "$input" == "~/"* ]]; then
        local path="${input%/}"
        path="${path/#\~/$HOME}"
        if [ -d "$path" ]; then
            cd "$path" || true
        else
            echo -e "${_SR_ERR}[Lỗi] Không tìm thấy thư mục: ${path}${_SR_RST}"
        fi
        return
    fi

    local first_word="${input%% *}"
    if ! command -v "$first_word" &>/dev/null; then
        _auto_install $input
        return $?
    fi

    bash -c "$input"
}

11line() {
    clear
    echo -e "${C}+------------------------------------------+"
    echo -e "|       ${Y} SMART MODE ${C}                    |"
    echo -e "|  ${W}Dán đường dẫn  -> tự cd                 ${C}|"
    echo -e "|  ${W}Lệnh chưa cài  -> AI tìm gói để cài     ${C}|"
    echo -e "|  ${W}Lệnh thường    -> giữ nguyên             ${C}|"
    echo -e "|  ${R}Gõ 'exit' hoặc 'q' để quay lại menu   ${C}|"
    echo -e "+------------------------------------------+${RS}"
    echo ""

    while true; do
        local cwd; cwd=$(pwd)
        echo -ne "${C}[smart]${Y} $cwd ${G}> ${RS}"
        read -r user_input

        [[ -z "$user_input" ]] && continue
        [[ "$user_input" == "exit" || "$user_input" == "quit" || "$user_input" == "q" ]] && break

        smart_run_cmd "$user_input"
    done

    cd ~/Termux-os ; bash os.sh
}

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

unsetopt PROMPT_SP 2>/dev/null

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

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
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
                gem)   ( gem install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
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
            echo -e "${_AI_R}[Auto]${_AI_RST} ✗ Cài '${pkg_hint}' thất bại."
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto]${_AI_RST} Gói liên quan:"
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

# ZSH: chỉ gọi AI tìm gói — KHÔNG đoán file theo đuôi
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
    else
        echo -e "${Y}[!] Không tìm thấy ~/.zshrc${RS}"
    fi

    if [ -f ~/.bashrc ]; then
        if grep -q "$marker" ~/.bashrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.bashrc${RS}"
        else
            cat >> ~/.bashrc << 'BASH_SMART_EOF'

# ══════════════════════════════════════════════════════════
# SMART MODE (by Termux-OS)
# ══════════════════════════════════════════════════════════

_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
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
                gem)   ( gem install "$pkg_hint"    &>"$lf2"; echo $? > "$cf2" ) & ;;
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
            echo -e "${_AI_R}[Auto]${_AI_RST} ✗ Cài '${pkg_hint}' thất bại."
        fi
    fi

    echo -e "${_AI_Y}[Auto]${_AI_RST} Tìm trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto]${_AI_RST} Gói liên quan:"
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

# BASH: chỉ gọi AI tìm gói — KHÔNG đoán file theo đuôi
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
    printf "\n%s${C}[${W}11${C}]${C} ⚡ Smart Mode ${Y}(Chạy tạm thời)" "$left_pad"
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
        11)    11line ;;
        12)    12line ;;
        0|00)  clear; exit 0 ;;
        *)     menu   ;;
    esac
}
menu