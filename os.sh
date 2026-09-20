#!/bin/bash
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;93m'
B='\033[1;94m'
C='\033[1;96m'
W='\033[1;97m'
RS='\033[0m'

term_width=$(tput cols 2>/dev/null || echo 60)
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
    echo -e "${R} [!]${W} Version : ${Y}v3 (Stable)"
    echo -e "${R} [!]${W} Youtube : ${W}youtube.com/henntaiiz"
    echo -e "${R} [!]${W} GitHub  : ${W}github.com/lacongai"
    echo -e ""
    echo -e "${G} ==============================================${N}"
    echo -e ""
}

banner

# ─────────────────────────────────────────────────────────
#  HÀM MỞ URL / RELOAD AN TOÀN (fix Activity not started)
# ─────────────────────────────────────────────────────────
safe_open_url() {
    local url="$1"
    command -v termux-open-url &>/dev/null || pkg install termux-tools -y &>/dev/null
    if command -v termux-open-url &>/dev/null; then
        # Dùng nohup + setsid-like để tách hẳn khỏi tiến trình cha,
        # redirect cả stdin/stdout/stderr để không làm rối chain.
        nohup termux-open-url "$url" </dev/null >/dev/null 2>&1 &
        disown 2>/dev/null || true
    fi
    return 0
}

safe_reload_settings() {
    command -v termux-reload-settings &>/dev/null || pkg install termux-tools -y &>/dev/null
    if command -v termux-reload-settings &>/dev/null; then
        nohup termux-reload-settings </dev/null >/dev/null 2>&1 &
        disown 2>/dev/null || true
    fi
    return 0
}

# ─────────────────────────────────────────────────────────
#  AUTO UPDATE (khi khởi động + watcher nền)
# ─────────────────────────────────────────────────────────
REPO_DIR="$HOME/Termux-os"
REPO_URL="https://github.com/lacongai/Termux-os"
UPDATE_CACHE="$HOME/.Termux-os/.update_check"
UPDATE_LOG="$HOME/.Termux-os/.update.log"
SKIP_UPDATE=0
[[ "$1" == "--no-update" ]] && SKIP_UPDATE=1

mkdir -p "$(dirname "$UPDATE_CACHE")" 2>/dev/null

_do_self_update() {
    # $1: "force" nếu muốn ép cập nhật
    local force="${1:-}"
    [ -d "$REPO_DIR/.git" ] || return 1
    cd "$REPO_DIR" 2>/dev/null || return 1

    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -z "$branch" ] && return 1

    git fetch origin "$branch" &>/dev/null || return 1

    local local_c remote_c
    local_c=$(git rev-parse HEAD 2>/dev/null)
    remote_c=$(git rev-parse "origin/$branch" 2>/dev/null)

    if [ -n "$local_c" ] && [ -n "$remote_c" ] && [ "$local_c" != "$remote_c" ]; then
        echo -e "${Y}[!] Phát hiện bản cập nhật mới trên GitHub! Đang tự động cập nhật...${RS}"
        if git pull --rebase origin "$branch" &>/dev/null; then
            echo -e "${G}[✓] Cập nhật thành công! Khởi động lại tool...${RS}"
            sleep 2
            exec bash "$REPO_DIR/os.sh" --no-update
        else
            echo -e "${R}[✗] Cập nhật thất bại, ép đồng bộ...${RS}"
            git reset --hard "origin/$branch" &>/dev/null
            git pull origin "$branch" &>/dev/null
            sleep 2
            exec bash "$REPO_DIR/os.sh" --no-update
        fi
    fi
    return 0
}

auto_check_update() {
    [ "$SKIP_UPDATE" = "1" ] && return 0
    [ -d "$REPO_DIR/.git" ] || return 0

    # Cache 10 phút
    local now last
    now=$(date +%s)
    if [ -f "$UPDATE_CACHE" ]; then
        last=$(cat "$UPDATE_CACHE" 2>/dev/null || echo 0)
        if [ $(( now - last )) -lt 600 ]; then
            return 0
        fi
    fi
    echo "$now" > "$UPDATE_CACHE" 2>/dev/null

    _do_self_update
}

# Watcher nền: mỗi 5 phút check 1 lần, nếu có commit mới thì cập nhật
start_update_watcher() {
    [ "$SKIP_UPDATE" = "1" ] && return 0
    [ -d "$REPO_DIR/.git" ] || return 0

    # Tránh chạy nhiều watcher
    local pid_file="$HOME/.Termux-os/.watcher.pid"
    if [ -f "$pid_file" ]; then
        local old_pid
        old_pid=$(cat "$pid_file" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            return 0
        fi
    fi

    (
        while true; do
            sleep 300
            cd "$REPO_DIR" 2>/dev/null || exit 0
            local branch
            branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || continue
            git fetch origin "$branch" &>/dev/null || continue
            local lc rc
            lc=$(git rev-parse HEAD 2>/dev/null)
            rc=$(git rev-parse "origin/$branch" 2>/dev/null)
            if [ -n "$lc" ] && [ -n "$rc" ] && [ "$lc" != "$rc" ]; then
                echo "$(date) - new commit detected, pulling..." >> "$UPDATE_LOG"
                git pull --rebase origin "$branch" &>>"$UPDATE_LOG"
            fi
        done
    ) </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null || true
    echo $! > "$pid_file" 2>/dev/null
}

auto_check_update
start_update_watcher

# ─────────────────────────────────────────────────────────
1line() { apt update && apt upgrade; termux-setup-storage; pkg install zsh git figlet toilet ruby wget curl -y; pkg update && pkg upgrade -y; pkg install python -y; pkg install nodejs git -y; pkg install git -y; pip install python-telegram-bot requests; pip install telebot rich; pkg install boxes ruby -y; pip install pystyle; pkg install python git curl wget neofetch figlet toilet ruby boxes -y; pip install rich colorama; npm install discord.js; pip install yt_dlp; pkg install python-psutil; pip install flask; pip install telethon; python -m pip install pycryptodome; pip install blackboxprotobuf; pip install cachetools; pkg install curl wget -y; pkg install cloudflared; pkg install python git -y; pip install python-telegram-bot==20.3 aiohttp rich pytz; pip install requests beautifulsoup4; pip install pywebview; pip install pyTelegramBotAPI requests; pkg install clang; pip install protobuf-decoder; pip install google-play-scraper; pip install python-cfonts; pip install shortuuid; pip install aiofiles; python -m pip install flask-cors; pip install fastapi uvicorn python-multipart aiofiles; pkg update; pkg install rust clang python; pip install --upgrade pip setuptools wheel; pip install fastapi==0.95.2 pydantic==1.10.24 uvicorn; pip install qrcode; pkg install ffmpeg; pip install protobuf; python -m pip install PyJWT; cd ~/Termux-os; clear; pip install python-telegram-bot[job-queue]; pip install --upgrade "python-telegram-bot[job-queue]"; pip install --upgrade pip; pip install pillow; npm install express cors; termux-wake-lock; npm i express cors; npm uninstall express; command -v lolcat &>/dev/null || pip install lolcat 2>/dev/null || true; clear; cd ~/Termux-os/.object/ && cp -r 'ANSI Shadow.flf' $PREFIX/share/figlet/ASCII-Shadow.flf; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; pkg install toilet figlet exa -y; cd ~/Termux-os/.object; rm -rf ~/.termux/colors.properties; rm -rf /data/data/com.termux/files/usr/etc/motd; cp -r .colors.properties ~/.termux/colors.properties; cp -r .termux.properties ~/.termux/termux.properties; sed -i '/terminal-cursor-style/d' ~/.termux/termux.properties; echo "terminal-cursor-style = underline" >> ~/.termux/termux.properties; safe_reload_settings; curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf > ~/.termux/font.ttf; clear; cd ~/Termux-os ; bash os.sh --no-update; safe_reload_settings; }

2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh --no-update; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh --no-update; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh --no-update; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh --no-update; }

# ─────────────────────────────────────────────────────────
#  [10] Cập nhật Tool từ GitHub
# ─────────────────────────────────────────────────────────
10line() {
    echo -e "\n${C}Đang kiểm tra cập nhật từ GitHub...${RS}"
    if [ ! -d ~/Termux-os/.git ]; then
        echo -e "${Y}[!] Không phải Git repository. Cài lại từ đầu...${RS}"
        rm -rf ~/Termux-os
        git clone https://github.com/lacongai/Termux-os ~/Termux-os
        cd ~/Termux-os && bash os.sh --no-update
        return
    fi
    cd ~/Termux-os || exit
    git fetch origin &>/dev/null
    local current_branch; current_branch=$(git rev-parse --abbrev-ref HEAD)
    local local_commit remote_commit
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch")
    if [ "$local_commit" = "$remote_commit" ]; then
        echo -e "${G}[✓] Tool đang là phiên bản mới nhất!${RS}"
        sleep 2; menu
    else
        echo -e "${Y}[!] Phát hiện phiên bản mới! Đang cập nhật...${RS}"
        if git pull --rebase origin "$current_branch"; then
            echo -e "${G}[✓] Cập nhật thành công!${RS}"
            sleep 2; bash os.sh --no-update
        else
            echo -e "${R}[✗] Cập nhật thất bại! Ép đồng bộ...${RS}"
            git reset --hard "origin/$current_branch"
            git pull origin "$current_branch"
            sleep 2; bash os.sh --no-update
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
    mkdir -p "$key_dir" 2>/dev/null
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
        echo -e "\n\033[1;33m[!] Bạn quên mật khẩu?\033[0m"
        echo -ne "\033[1;96mCập nhật lại tool và gỡ khóa? (y/n): \033[0m"
        read -r choice_update
        if [[ "\$choice_update" =~ ^[Yy]$ ]]; then
            echo -e "\n\033[1;33m[!] Đang cập nhật lại tool từ GitHub...\033[0m"
            rm -rf ~/Termux-os
            cd ~ && git clone https://github.com/lacongai/Termux-os
            sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
            [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
            echo -e "\n\033[1;32m[✓] Đã gỡ khóa! Khởi động lại...\033[0m"
            sleep 2
            cd ~/Termux-os && bash os.sh --no-update
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
            echo -e "\n\033[1;31m[!] Hết lượt. Khởi động lại Termux...\033[0m"
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
    sleep 2; menu
}

9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    rm -f /storage/emulated/0/Termux-os/key
    echo -e "${R}Đã hủy Giao thức Bảo mật và xóa file Key.${RS}"
    sleep 2; menu
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

# ═══════════════════════════════════════════════════════════
#  AI AUTO INSTALL (FIXED)
#  - Bước 1: pkg install trực tiếp
#  - Bước 2: pip install (nếu là python package)
#  - Bước 3: npm install -g (nếu là node package)
#  - Bước 4: hỏi AI -> AI trả về LỆNH CÀI ĐẶT đầy đủ (không phải tên file)
#  - Bước 5: pkg search fallback
# ═══════════════════════════════════════════════════════════
_ai_call_gemini() {
    local prompt="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local out="${tmp_dir}/_gem_$$.json"
    curl -sf --max-time 25 \
        -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"${prompt}\"}]}]}" \
        > "$out" 2>/dev/null
    local result=""
    if [ -f "$out" ]; then
        result=$(grep -o '"text":"[^"]*"' "$out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' \
            | sed 's/\\n/ /g; s/\\"/"/g; s/\\\\/\\/g')
        rm -f "$out" 2>/dev/null
    fi
    printf '%s' "$result"
}

# Hỏi AI cách cài đặt lệnh (trả về chuỗi lệnh cài đặt, không phải tên file)
_ai_get_install_cmd() {
    local cmd="$1"
    local prompt="You are a Termux package installation expert. The user typed the command '${cmd}' but it is not installed. Determine the correct FULL installation command to install this tool on Termux (Android). Prefer Termux native 'pkg install' if the tool exists in the Termux repo. Otherwise use 'pip install' for Python tools or 'npm install -g' for Node.js tools. Reply with ONLY the raw installation command, one line, no explanation, no markdown, no quotes. Examples: 'pkg install neofetch', 'pip install requests', 'npm install -g typescript'. If you don't know, reply 'unknown'."
    local resp
    resp=$(_ai_call_gemini "$prompt" | tr -d '\r' | head -c 200)
    # Lọc sạch: chỉ giữ dòng đầu
    resp=$(printf '%s' "$resp" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Validate: chỉ cho phép các prefix cài đặt hợp lệ
    case "$resp" in
        "pkg install "*|"pip install "*|"pip3 install "*|"python -m pip install "*|"npm install -g "*|"apt install "*)
            printf '%s' "$resp"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift
    local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then
        echo "command not found: $cmd"
        return 127
    fi

    # ── Helper: chạy 1 lệnh cài có spinner ──────────────────
    _run_install_cmd() {
        local install_cmd="$1"
        local label="$2"
        local log_file="${tmp_dir}/_ai_$$.log"
        local code_file="${tmp_dir}/_ai_$$.code"
        ( eval "$install_cmd" &>"$log_file"; echo $? > "$code_file" ) &
        local pid=$!
        local i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$i]}${_AI_RST} %s" "$label"
            i=$(( (i + 1) % 10 ))
            sleep 0.1
        done
        wait "$pid" 2>/dev/null
        printf "\r\033[2K"
        local status
        status=$(cat "$code_file" 2>/dev/null)
        rm -f "$log_file" "$code_file" 2>/dev/null
        return "${status:-1}"
    }

    # ── Bước 1: pkg install trực tiếp ────────────────────────
    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Thử 'pkg install ${cmd}'..."
    if _run_install_cmd "pkg install -y ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pkg..." \
        && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    # ── Bước 2: pip install ──────────────────────────────────
    if command -v pip &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'pip install ${cmd}'..."
        if _run_install_cmd "pip install ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pip..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua pip"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    # ── Bước 3: npm install -g ───────────────────────────────
    if command -v npm &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'npm install -g ${cmd}'..."
        if _run_install_cmd "npm install -g ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua npm..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua npm"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    # ── Bước 4: Hỏi Gemini AI để lấy LỆNH CÀI ĐẶT ───────────
    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Các cách trên thất bại. Hỏi Gemini tra cứu lệnh cài..."
    local ai_cmd=""
    (
        printf ""
    ) &
    local ai_pid=$!
    local spin_ai=0
    while kill -0 "$ai_pid" 2>/dev/null; do
        printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai]}${_AI_RST} Đang hỏi Gemini..."
        spin_ai=$(( (spin_ai + 1) % 10 ))
        sleep 0.1
    done
    wait "$ai_pid" 2>/dev/null
    ai_cmd=$(_ai_get_install_cmd "$cmd")
    printf "\r\033[2K"

    if [ -n "$ai_cmd" ]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý lệnh: ${_AI_C}${ai_cmd}${_AI_RST}"
        if _run_install_cmd "$ai_cmd" "Đang chạy lệnh AI: ${_AI_W}${ai_cmd}${_AI_RST}..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' theo AI"
            "$cmd" "${args[@]}"; return $?
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Lệnh AI không chạy được '${cmd}'. Chuyển sang tìm gói..."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ AI không trả về lệnh hợp lệ. Chuyển sang tìm gói..."
    fi

    # ── Bước 5: pkg search fallback ──────────────────────────
    echo ""
    echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [ -n "$alt_list" ]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do
            echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"
            idx=$(( idx + 1 ))
        done <<< "$alt_list"
        echo ""
        echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected
            selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [ -n "$selected" ]; then
                if _run_install_cmd "pkg install -y ${selected}" "Đang cài '${_AI_W}${selected}${_AI_RST}'..." \
                    && command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

# ── Chạy file theo extension ─────────────────────────────
_run_file_by_ext() {
    local filename="$1"
    local ext="${filename##*.}"
    case "$ext" in
        py)   python "$filename";       return $? ;;
        sh)   bash "$filename";         return $? ;;
        js)   node "$filename";         return $? ;;
        ts)   npx ts-node "$filename";  return $? ;;
        php)  php "$filename";          return $? ;;
        rb)   ruby "$filename";         return $? ;;
        lua)  lua "$filename";          return $? ;;
        pl)   perl "$filename";         return $? ;;
        go)   go run "$filename";       return $? ;;
        r|R)  Rscript "$filename";      return $? ;;
        java) local cls="${filename%.java}"; javac "$filename" && java "$cls"; return $? ;;
        c)    local out="${filename%.c}"; gcc "$filename" -o "$out" && "./$out"; return $? ;;
        cpp)  local out="${filename%.cpp}"; g++ "$filename" -o "$out" && "./$out"; return $? ;;
        rs)   local out="${filename%.rs}"; rustc "$filename" && "./$out"; return $? ;;
        *)    return 1 ;;
    esac
}

smart_run_cmd() {
    local input="$*"

    # Smart Path
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

    # Smart Run: file có extension hỗ trợ
    local filename="${input%% *}"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
        _run_file_by_ext "$filename" && return
    fi

    # Lệnh chưa cài → auto install
    local first_word="${input%% *}"
    if ! command -v "$first_word" &>/dev/null; then
        _auto_install $input
        return $?
    fi

    bash -c "$input"
}

# ─────────────────────────────────────────────────────────
#  [11] Smart Mode tạm thời
# ─────────────────────────────────────────────────────────
11line() {
    clear
    echo -e "${C}╔══════════════════════════════════════════╗"
    echo -e "║       ${Y}⚡  SMART MODE  ⚡${C}               ║"
    echo -e "║  ${W}Dán đường dẫn  → tự cd                 ${C}║"
    echo -e "║  ${W}Nhập tên file  → tự chạy đúng lệnh     ${C}║"
    echo -e "║  ${W}Lệnh chưa cài  → tự hỏi AI & cài      ${C}║"
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
    cd ~/Termux-os
    bash os.sh --no-update
}

# ─────────────────────────────────────────────────────────
#  [12] Cài Smart Mode vĩnh viễn
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

if (( ${+ZSH_HIGHLIGHT_STYLES} )) && [[ "${(t)ZSH_HIGHLIGHT_STYLES}" == *association* ]]; then
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow,bold'
fi

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

_ai_call_gemini() {
    local prompt="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local out="${tmp_dir}/_gem_$$.json"
    curl -sf --max-time 25 \
        -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"${prompt}\"}]}]}" \
        > "$out" 2>/dev/null
    local result=""
    if [ -f "$out" ]; then
        result=$(grep -o '"text":"[^"]*"' "$out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' \
            | sed 's/\\n/ /g; s/\\"/"/g; s/\\\\/\\/g')
        rm -f "$out" 2>/dev/null
    fi
    printf '%s' "$result"
}

_ai_get_install_cmd() {
    local cmd="$1"
    local prompt="You are a Termux package installation expert. The user typed the command '${cmd}' but it is not installed. Determine the correct FULL installation command to install this tool on Termux (Android). Prefer Termux native 'pkg install' if the tool exists in the Termux repo. Otherwise use 'pip install' for Python tools or 'npm install -g' for Node.js tools. Reply with ONLY the raw installation command, one line, no explanation, no markdown, no quotes. Examples: 'pkg install neofetch', 'pip install requests', 'npm install -g typescript'. If you don't know, reply 'unknown'."
    local resp
    resp=$(_ai_call_gemini "$prompt" | tr -d '\r' | head -c 200)
    resp=$(printf '%s' "$resp" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    case "$resp" in
        "pkg install "*|"pip install "*|"pip3 install "*|"python -m pip install "*|"npm install -g "*|"apt install "*)
            printf '%s' "$resp"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift
    local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    setopt LOCAL_OPTIONS; unsetopt NOTIFY
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then
        echo "command not found: $cmd"
        return 127
    fi

    _run_install_cmd() {
        local install_cmd="$1"
        local label="$2"
        local log_file="${tmp_dir}/_ai_$$.log"
        local code_file="${tmp_dir}/_ai_$$.code"
        ( eval "$install_cmd" &>"$log_file"; echo $? > "$code_file" ) &
        local pid=$!
        local i=1
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$i]}${_AI_RST} %s" "$label"
            i=$(( i % 10 + 1 ))
            sleep 0.1
        done
        wait "$pid" 2>/dev/null
        printf "\r\033[2K"
        local status
        status=$(cat "$code_file" 2>/dev/null)
        rm -f "$log_file" "$code_file" 2>/dev/null
        return "${status:-1}"
    }

    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Thử 'pkg install ${cmd}'..."
    if _run_install_cmd "pkg install -y ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pkg..." \
        && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    if command -v pip &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'pip install ${cmd}'..."
        if _run_install_cmd "pip install ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pip..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua pip"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    if command -v npm &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'npm install -g ${cmd}'..."
        if _run_install_cmd "npm install -g ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua npm..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua npm"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Các cách trên thất bại. Hỏi Gemini tra cứu lệnh cài..."
    local ai_cmd=""
    ai_cmd=$(_ai_get_install_cmd "$cmd")

    if [[ -n "$ai_cmd" ]]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${ai_cmd}${_AI_RST}"
        if _run_install_cmd "$ai_cmd" "Đang chạy: ${_AI_W}${ai_cmd}${_AI_RST}..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' theo AI"
            "$cmd" "${args[@]}"; return $?
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Lệnh AI không chạy được '${cmd}'. Chuyển sang tìm gói..."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ AI không trả về lệnh hợp lệ. Chuyển sang tìm gói..."
    fi

    echo ""
    echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do
            echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"
            idx=$(( idx + 1 ))
        done <<< "$alt_list"
        echo ""
        echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected
            selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [[ -n "$selected" ]]; then
                if _run_install_cmd "pkg install -y ${selected}" "Đang cài '${_AI_W}${selected}${_AI_RST}'..." \
                    && command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

_run_file_by_ext_zsh() {
    local filename="$1"
    local ext="${filename##*.}"
    case "$ext" in
        py)   python "$filename";       return $? ;;
        sh)   bash "$filename";         return $? ;;
        js)   node "$filename";         return $? ;;
        ts)   npx ts-node "$filename";  return $? ;;
        php)  php "$filename";          return $? ;;
        rb)   ruby "$filename";         return $? ;;
        lua)  lua "$filename";          return $? ;;
        pl)   perl "$filename";         return $? ;;
        go)   go run "$filename";       return $? ;;
        r|R)  Rscript "$filename";      return $? ;;
        java) local cls="${filename%.java}"; javac "$filename" && java "$cls"; return $? ;;
        c)    local out="${filename%.c}"; gcc "$filename" -o "$out" && "./$out"; return $? ;;
        cpp)  local out="${filename%.cpp}"; g++ "$filename" -o "$out" && "./$out"; return $? ;;
        rs)   local out="${filename%.rs}"; rustc "$filename" && "./$out"; return $? ;;
        *)    return 1 ;;
    esac
}

command_not_found_handler() {
    local filename="$1"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
        _run_file_by_ext_zsh "$filename" && return $?
    fi
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

_ai_call_gemini() {
    local prompt="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local out="${tmp_dir}/_gem_$$.json"
    curl -sf --max-time 25 \
        -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"${prompt}\"}]}]}" \
        > "$out" 2>/dev/null
    local result=""
    if [ -f "$out" ]; then
        result=$(grep -o '"text":"[^"]*"' "$out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' \
            | sed 's/\\n/ /g; s/\\"/"/g; s/\\\\/\\/g')
        rm -f "$out" 2>/dev/null
    fi
    printf '%s' "$result"
}

_ai_get_install_cmd() {
    local cmd="$1"
    local prompt="You are a Termux package installation expert. The user typed the command '${cmd}' but it is not installed. Determine the correct FULL installation command to install this tool on Termux (Android). Prefer Termux native 'pkg install' if the tool exists in the Termux repo. Otherwise use 'pip install' for Python tools or 'npm install -g' for Node.js tools. Reply with ONLY the raw installation command, one line, no explanation, no markdown, no quotes. Examples: 'pkg install neofetch', 'pip install requests', 'npm install -g typescript'. If you don't know, reply 'unknown'."
    local resp
    resp=$(_ai_call_gemini "$prompt" | tr -d '\r' | head -c 200)
    resp=$(printf '%s' "$resp" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    case "$resp" in
        "pkg install "*|"pip install "*|"pip3 install "*|"python -m pip install "*|"npm install -g "*|"apt install "*)
            printf '%s' "$resp"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_auto_install() {
    local cmd="$1"; shift
    local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then
        echo "command not found: $cmd"
        return 127
    fi

    _run_install_cmd() {
        local install_cmd="$1"
        local label="$2"
        local log_file="${tmp_dir}/_ai_$$.log"
        local code_file="${tmp_dir}/_ai_$$.code"
        ( eval "$install_cmd" &>"$log_file"; echo $? > "$code_file" ) &
        local pid=$!
        local i=0
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$i]}${_AI_RST} %s" "$label"
            i=$(( (i + 1) % 10 ))
            sleep 0.1
        done
        wait "$pid" 2>/dev/null
        printf "\r\033[2K"
        local status
        status=$(cat "$code_file" 2>/dev/null)
        rm -f "$log_file" "$code_file" 2>/dev/null
        return "${status:-1}"
    }

    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Thử 'pkg install ${cmd}'..."
    if _run_install_cmd "pkg install -y ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pkg..." \
        && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    if command -v pip &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'pip install ${cmd}'..."
        if _run_install_cmd "pip install ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua pip..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua pip"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    if command -v npm &>/dev/null; then
        echo -e "${_AI_C}[Auto Install]${_AI_RST} Thử 'npm install -g ${cmd}'..."
        if _run_install_cmd "npm install -g ${cmd}" "Đang cài '${_AI_W}${cmd}${_AI_RST}' qua npm..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' qua npm"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Các cách trên thất bại. Hỏi Gemini tra cứu lệnh cài..."
    local ai_cmd=""
    ai_cmd=$(_ai_get_install_cmd "$cmd")

    if [[ -n "$ai_cmd" ]]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${ai_cmd}${_AI_RST}"
        if _run_install_cmd "$ai_cmd" "Đang chạy: ${_AI_W}${ai_cmd}${_AI_RST}..." \
            && command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}' theo AI"
            "$cmd" "${args[@]}"; return $?
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Lệnh AI không chạy được '${cmd}'. Chuyển sang tìm gói..."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ AI không trả về lệnh hợp lệ. Chuyển sang tìm gói..."
    fi

    echo ""
    echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do
            echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"
            idx=$(( idx + 1 ))
        done <<< "$alt_list"
        echo ""
        echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected
            selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [[ -n "$selected" ]]; then
                if _run_install_cmd "pkg install -y ${selected}" "Đang cài '${_AI_W}${selected}${_AI_RST}'..." \
                    && command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

_run_file_by_ext_bash() {
    local filename="$1"
    local ext="${filename##*.}"
    case "$ext" in
        py)   python "$filename";       return $? ;;
        sh)   bash "$filename";         return $? ;;
        js)   node "$filename";         return $? ;;
        ts)   npx ts-node "$filename";  return $? ;;
        php)  php "$filename";          return $? ;;
        rb)   ruby "$filename";         return $? ;;
        lua)  lua "$filename";          return $? ;;
        pl)   perl "$filename";         return $? ;;
        go)   go run "$filename";       return $? ;;
        r|R)  Rscript "$filename";      return $? ;;
        java) local cls="${filename%.java}"; javac "$filename" && java "$cls"; return $? ;;
        c)    local out="${filename%.c}"; gcc "$filename" -o "$out" && "./$out"; return $? ;;
        cpp)  local out="${filename%.cpp}"; g++ "$filename" -o "$out" && "./$out"; return $? ;;
        rs)   local out="${filename%.rs}"; rustc "$filename" && "./$out"; return $? ;;
        *)    return 1 ;;
    esac
}

command_not_found_handle() {
    local filename="$1"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
        _run_file_by_ext_bash "$filename" && return $?
    fi
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