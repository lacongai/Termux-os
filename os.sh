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

# ══════════════════════════════════════════════════════════
#  BANNER — dùng echo -e để escape \033 được dịch đúng
# ══════════════════════════════════════════════════════════
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
#  AUTO UPDATE CHECK — chạy tự động mỗi khi mở tool
# ══════════════════════════════════════════════════════════
_auto_update_check() {
    [ "${1:-}" = "--no-update" ] && return 0

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
        echo -ne "${C}Cập nhật ngay bây giờ? (y/n, Enter=y): ${RS}"
        read -r _ans
        if [ -z "$_ans" ] || [[ "$_ans" =~ ^[Yy]$ ]]; then
            if git pull origin "$branch" &>/dev/null; then
                echo -e "${G}[✓] Đã cập nhật! Đang khởi động lại...${RS}"
                sleep 1
                exec bash ~/Termux-os/os.sh --no-update
            else
                echo -e "${R}[✗] Pull lỗi, đang ép đồng bộ...${RS}"
                git reset --hard "origin/$branch" &>/dev/null
                git pull origin "$branch" &>/dev/null
                echo -e "${G}[✓] Đã ép cập nhật thành công!${RS}"
                sleep 1
                exec bash ~/Termux-os/os.sh --no-update
            fi
        fi
    fi
}

_auto_update_check "${1:-}"

banner

# ══════════════════════════════════════════════════════════
#  1line — Cài đặt: lần 1 cài đầy đủ, lần 2+ chỉ cập nhật
# ══════════════════════════════════════════════════════════
1line() {
    local FLAG="$HOME/.termux-os-installed"
    local FIRST_TIME=1
    [ -f "$FLAG" ] && FIRST_TIME=0

    if [ "$FIRST_TIME" = "1" ]; then
        echo -e "\n${C}[Lần đầu] Đang cài đặt đầy đủ...${RS}\n"
    else
        echo -e "\n${Y}[Lần 2+] Chỉ cập nhật, không cài lại.${RS}\n"
    fi

    # ── Bước 1: cập nhật repo & gói cơ bản ───────────────────
    echo -e "${C}[1/5] Cập nhật apt...${RS}"
    apt update -y && apt upgrade -y

    echo -e "${C}[2/5] Cài gói cần thiết...${RS}"
    pkg install -y zsh git figlet toilet ruby wget curl exa

    if ! command -v lolcat &>/dev/null; then
        echo -e "${C}[*] Cài lolcat...${RS}"
        gem install lolcat 2>/dev/null || true
    fi

    # ── Bước 2: chỉ clone Oh-My-Zsh lần đầu ──────────────────
    if [ "$FIRST_TIME" = "1" ]; then
        echo -e "${C}[3/5] Cài Oh-My-Zsh...${RS}"
        [ ! -d "$HOME/.oh-my-zsh" ] && \
            git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    else
        echo -e "${C}[3/5] Bỏ qua Oh-My-Zsh (đã có).${RS}"
    fi

    # ── Bước 3+4: copy figlet font & config Termux ───────────
    if [ -d "$HOME/Termux-os/.object" ]; then
        cd "$HOME/Termux-os/.object" || true

        if [ -f 'ANSI Shadow.flf' ] && [ -d "$PREFIX/share/figlet" ]; then
            [ ! -f "$PREFIX/share/figlet/ASCII-Shadow.flf" ] && \
                cp -r 'ANSI Shadow.flf' "$PREFIX/share/figlet/ASCII-Shadow.flf"
        fi

        echo -e "${C}[4/5] Cập nhật giao diện Termux...${RS}"
        rm -rf ~/.termux/colors.properties
        rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null

        mkdir -p ~/.termux
        [ -f .colors.properties ] && cp -r .colors.properties ~/.termux/colors.properties
        [ -f .termux.properties ] && cp -r .termux.properties ~/.termux.properties

        if [ ! -f ~/.termux/font.ttf ] || [ "$(stat -c %s ~/.termux/font.ttf 2>/dev/null || echo 0)" -lt 102400 ]; then
            echo -e "${C}[*] Đang tải font FiraCode Nerd Font...${RS}"
            curl -L --max-time 60 \
                https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf \
                -o ~/.termux/font.ttf 2>/dev/null || true
        fi
    fi

    # ── Bước 5: chỉ mở browser + reload LẦN ĐẦU ──────────────
    if [ "$FIRST_TIME" = "1" ]; then
        echo -e "${C}[5/5] Hoàn tất! Mở liên kết và reload Termux...${RS}"
        termux-open-url "https://h4ck3r.me" 2>/dev/null || true
        termux-reload-settings 2>/dev/null || true
        touch "$FLAG"
        echo -e "${G}[✓] Cài đặt xong. Hãy mở lại Termux để áp dụng.${RS}"
        sleep 3
        exit 0
    else
        echo -e "${G}[✓] Đã cập nhật xong (không cần khởi động lại).${RS}"
        sleep 2
        cd ~/Termux-os
        bash os.sh --no-update
    fi
}

2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh --no-update; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh --no-update; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh --no-update; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }

# ─────────────────────────────────────────────────────────
#  [10] Tự động cập nhật Tool từ GitHub (thủ công từ menu)
# ─────────────────────────────────────────────────────────
10line() {
    echo -e "\n${C}Đang kiểm tra cập nhật từ GitHub...${RS}"

    if [ ! -d ~/Termux-os/.git ]; then
        echo -e "${Y}[!] Thư mục hiện tại không phải Git repository. Đang tiến hành cài đặt lại từ đầu...${RS}"
        rm -rf ~/Termux-os
        git clone https://github.com/lacongai/Termux-os ~/Termux-os
        cd ~/Termux-os && bash os.sh --no-update
        return
    fi

    cd ~/Termux-os || exit
    git fetch origin &>/dev/null

    local current_branch local_commit remote_commit
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch")

    if [ "$local_commit" = "$remote_commit" ]; then
        echo -e "${G}[✓] Tool của bạn đang là phiên bản mới nhất!${RS}"
        sleep 2
        menu
    else
        echo -e "${Y}[!] Phát hiện phiên bản mới trên GitHub! Đang cập nhật...${RS}"
        if git pull origin "$current_branch"; then
            echo -e "${G}[✓] Cập nhật thành công! Đang khởi động lại tool...${RS}"
            sleep 2
            bash os.sh --no-update
        else
            echo -e "${R}[✗] Cập nhật thất bại! Có xung đột dữ liệu local (conflict).${RS}"
            echo -e "${W}Đang thử ép buộc đồng bộ với GitHub...${RS}"
            git reset --hard "origin/$current_branch"
            git pull origin "$current_branch"
            echo -e "${G}[✓] Đã ép cập nhật thành công!${RS}"
            sleep 2
            bash os.sh --no-update
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
    printf '\n\033[1;96m╔══════════════════════════════════════╗\n'
    printf '║        \033[1;31mTRUY CẬP SHELL BẢO MẬT           \033[1;96m║\n'
    printf '╚══════════════════════════════════════╝\033[0m\n'
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
            echo -e "\n\033[1;32m[✓] Cập nhật và gỡ khóa thành công! Đang khởi động lại Termux...\033[0m"
            sleep 2
            cd ~/Termux-os && bash os.sh --no-update
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
            echo -e "\n\033[1;31m[!] Hết lượt thử. Đang khởi động lại Termux...\033[0m"
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

    echo -e "${G}Đã cấu hình Khóa kèm cơ chế hỏi (y/n) ở ĐẦU tệp tin.${RS}"
    sleep 2
    menu
}

9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    rm -f /storage/emulated/0/Termux-os/key
    echo -e "${R}Đã hủy kích hoạt Giao thức Bảo mật và xóa file Key.${RS}"
    sleep 2
    menu
}

# ─────────────────────────────────────────────────────────
#  SMART MODE — Auto install qua AI (chỉ tìm gói, KHÔNG tìm file)
# ─────────────────────────────────────────────────────────
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

if [ -z "$TMPDIR" ]; then
    export TMPDIR="$PREFIX/tmp"
fi
mkdir -p "$TMPDIR" 2>/dev/null

# ── Hàm auto install dùng chung ───────────────────────────
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

    # ── Bước 1: pkg install trực tiếp ────────────────────────
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

    # ── Bước 2: Gemini AI tìm gói ────────────────────────────
    echo -e "${_AI_R}[Auto]${_AI_RST} 'pkg install ${cmd}' thất bại → hỏi Gemini AI..."
    local pkg_hint="" manager_hint=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="${tmp_dir}/_ai_g_$$.json"
        local payload
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name (for pkg use the termux package name, may have python- prefix). Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

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
    else
        echo -e "${_AI_Y}[AI]${_AI_RST} ⚠ Chưa cấu hình GEMINI_API_KEY — bỏ qua AI."
    fi

    # ── Bước 3: cài theo gợi ý AI ─────────────────────────────
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
                echo -e "${_AI_G}[Auto]${_AI_RST} ✓ Cài xong '${pkg_hint}' (executable có thể khác tên gói)."
                "$cmd" "${args[@]}" 2>/dev/null || \
                  echo -e "${_AI_Y}[Auto]${_AI_RST} Kiểm tra lại tên lệnh sau khi cài."
                return $?
            fi
            echo -e "${_AI_R}[Auto]${_AI_RST} ✗ Cài '${pkg_hint}' thất bại."
        fi
    else
        echo -e "${_AI_R}[AI]${_AI_RST} AI không trả về tên gói hợp lệ."
    fi

    # ── Bước 4: fallback pkg search ───────────────────────────
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

# ── Smart Run dùng trong REPL — chỉ path + auto install ──
smart_run_cmd() {
    local input="$*"

    # Smart Path (chỉ xử lý khi bắt đầu bằng / hoặc ~)
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

    # Lấy từ đầu tiên, kiểm tra lệnh đã cài chưa
    local first_word="${input%% *}"
    if ! command -v "$first_word" &>/dev/null; then
        _auto_install $input
        return $?
    fi

    # Lệnh thông thường
    bash -c "$input"
}

# ─────────────────────────────────────────────────────────
#  [11] Smart Mode — REPL tạm thời
# ─────────────────────────────────────────────────────────
11line() {
    clear
    echo -e "${C}╔══════════════════════════════════════════╗"
    echo -e "║       ${Y}⚡  SMART MODE  ⚡${C}               ║"
    echo -e "║  ${W}Dán đường dẫn  → tự cd                 ${C}║"
    echo -e "║  ${W}Lệnh chưa cài  → AI tìm gói để cài     ${C}║"
    echo -e "║  ${W}Lệnh thường    → giữ nguyên             ${C}║"
    echo -e "║  ${R}Gõ 'exit' hoặc 'q' để quay lại menu   ${C}║"
    echo -e "╚══════════════════════════════════════════╝${RS}"
    echo ""

    while true; do
        local cwd; cwd=$(pwd)
        echo -ne "${C}[smart]${Y} $cwd ${G}❯ ${RS}"
        read -r user_input

        [[ -z "$user_input" ]] && continue
        [[ "$user_input" == "exit" || "$user_input" == "quit" || "$user_input" == "q" ]] && break

        smart_run_cmd "$user_input"
    done

    cd ~/Termux-os ; bash os.sh --no-update
}

# ─────────────────────────────────────────────────────────
#  [12] Cài Smart Mode vào shell (vĩnh viễn)
# ─────────────────────────────────────────────────────────
12line() {
    local marker="# SMART MODE (by Termux-OS)"

    # ── Cài vào ~/.zshrc ────────────────────────────────────
    if [ -f ~/.zshrc ]; then
        if grep -q "$marker" ~/.zshrc 2>/dev/null; then
            echo -e "${Y}[!] Smart Mode đã có trong ~/.zshrc${RS}"
        else
            cat >> ~/.zshrc << 'ZSH_SMART_EOF'

# ══════════════════════════════════════════════════════════
# SMART MODE (by Termux-OS)
# ══════════════════════════════════════════════════════════

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
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name (for pkg use the termux package name, may have python- prefix). Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

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

    # ── Cài vào ~/.bashrc ───────────────────────────────────
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
        payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name (for pkg use the termux package name, may have python- prefix). Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

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

    echo -e "${C}\nSmart Mode sẽ hoạt động tự động từ lần mở shell tiếp theo.${RS}"
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
        0|00)  exit   ;;
        *)     menu   ;;
    esac
}
menu