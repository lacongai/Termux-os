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
[ "$margin" -lt 0 ] && margin=0
left_pad=$(printf '%*s' "$margin" "")

banner() {
    clear

    local RC="\e[1;31m"
    local GC="\e[1;32m"
    local CC="\e[1;36m"
    local WC="\e[1;37m"
    local YC="\e[1;33m"
    local N="\e[0m"

    echo -e "${CC} ______                              ${RC}  ___  ____"
    echo -e "${CC}/_  __/__  _________ ___  __  ___  __${RC} / _ \/ __/"
    echo -e "${CC} / / / _ \/ ___/ __ '__ \/ / / / |/_/${RC}/ // /\ \  "
    echo -e "${CC}/_/  \___/_/  /_/ /_/ /_/\__,_/_/|_| ${RC}\___/___/  "
    echo -e "                                      "
    echo -e "${WC}      --[ ${GC}Công Cụ Tối Ưu Termux ${WC}]--       "
    echo -e ""

    echo -e "${RC} [!]${WC} Author  : ${CC}Gấu Ngốc Nghếch (henntaiiz)"
    echo -e "${RC} [!]${WC} Version : ${YC}v2 (Stable)"
    echo -e "${RC} [!]${WC} Youtube : ${WC}youtube.com/henntaiiz"
    echo -e "${RC} [!]${WC} GitHub  : ${WC}github.com/lacongai"
    echo -e ""

    echo -e "${GC} ==============================================${N}"
    echo -e ""
}

banner

# ══════════════════════════════════════════════════════════
#  SAFE HELPERS
# ══════════════════════════════════════════════════════════
_safe_open_url() {
    # termux-open-url hay lỗi "Activity not started" trên nhiều ROM → wrap an toàn
    if command -v termux-open-url &>/dev/null; then
        ( termux-open-url "$1" &>/dev/null & ) 2>/dev/null || true
    fi
}

_safe_reload_settings() {
    if command -v termux-reload-settings &>/dev/null; then
        ( termux-reload-settings &>/dev/null & ) 2>/dev/null || true
    fi
}

# ══════════════════════════════════════════════════════════
#  CÁC HÀM LINE
# ══════════════════════════════════════════════════════════
1line() { apt update && apt upgrade; pkg install zsh git figlet toilet ruby wget curl -y; gem install lolcat; clear; cd ~/Termux-os/.object/ && cp -r 'ANSI Shadow.flf' $PREFIX/share/figlet/ASCII-Shadow.flf; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; pkg install toilet figlet exa -y; cd ~/Termux-os/.object; rm -rf ~/.termux/colors.properties; rm -rf /data/data/com.termux/files/usr/etc/motd; cp -r .colors.properties ~/.termux/colors.properties; cp -r .termux.properties ~/.termux.properties; curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf > ~/.termux/font.ttf; clear; cd ~/Termux-os ; bash os.sh; termux-reload-settings 2>/dev/null || true; }
2line() { rm -rf ~/.zshrc; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; cd ~/Termux-os ; bash os.sh; }
3line() { pkg install zsh; chsh -s zsh; cd ~/Termux-os ; bash os.sh; }
4line() { chsh -s bash; cd ~/Termux-os ; bash os.sh; }
5line() { rm -rf ~/.zshrc; cd ~/Termux-os/.object; bash .2.sh; clear ; cd ~/Termux-os ; bash os.sh; }
6line() { cd ~/Termux-os/.object; bash .1.sh; clear ; cd ~/Termux-os ; bash os.sh; }
7line() { cd ~/Termux-os/.object; rm -rf ~/.zshrc; chsh -s zsh; bash .3.sh; clear ; cd ~/Termux-os ; bash os.sh; }

# ══════════════════════════════════════════════════════════
#  [10] AUTO UPDATE FROM GITHUB
# ══════════════════════════════════════════════════════════
10line() {
    echo -e "\n${C}Đang kiểm tra cập nhật từ GitHub...${RS}"

    if [ ! -d ~/Termux-os/.git ]; then
        echo -e "${Y}[!] Thư mục hiện tại không phải Git repository. Đang cài lại từ đầu...${RS}"
        rm -rf ~/Termux-os
        git clone https://github.com/lacongai/Termux-os ~/Termux-os
        cd ~/Termux-os && bash os.sh
        return
    fi

    cd ~/Termux-os || return

    git fetch origin &>/dev/null

    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -z "$current_branch" ] && current_branch="main"

    local local_commit remote_commit
    local_commit=$(git rev-parse HEAD 2>/dev/null)
    remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null)

    if [ -z "$remote_commit" ]; then
        echo -e "${Y}[!] Không tìm thấy branch 'origin/$current_branch'. Thử 'origin/main'...${RS}"
        remote_commit=$(git rev-parse "origin/main" 2>/dev/null)
        current_branch="main"
    fi

    if [ "$local_commit" = "$remote_commit" ]; then
        echo -e "${G}[✓] Tool của bạn đang là phiên bản mới nhất!${RS}"
        sleep 2
        menu
    else
        echo -e "${Y}[!] Phát hiện phiên bản mới trên GitHub! Đang cập nhật...${RS}"

        if git pull origin "$current_branch"; then
            echo -e "${G}[✓] Cập nhật thành công! Đang khởi động lại tool...${RS}"
            sleep 2
            bash os.sh
        else
            echo -e "${R}[✗] Cập nhật thất bại! Có xung đột dữ liệu local (conflict).${RS}"
            echo -e "${W}Đang thử ép buộc đồng bộ với GitHub...${RS}"
            git reset --hard "origin/$current_branch"
            git pull origin "$current_branch"
            echo -e "${G}[✓] Đã ép cập nhật thành công!${RS}"
            sleep 2
            bash os.sh
        fi
    fi
}

# ══════════════════════════════════════════════════════════
#  AUTO UPDATE ON START (background — không chặn UI)
# ══════════════════════════════════════════════════════════
auto_update_on_start() {
    [ -d ~/Termux-os/.git ] || return 0
    cd ~/Termux-os 2>/dev/null || return 0

    (
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        [ -z "$current_branch" ] && current_branch="main"

        git fetch origin &>/dev/null

        local local_commit remote_commit
        local_commit=$(git rev-parse HEAD 2>/dev/null)
        remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null)

        if [ -n "$remote_commit" ] && [ "$local_commit" != "$remote_commit" ]; then
            echo -e "\n${Y}[Auto-Update] Phát hiện bản mới trên GitHub! Đang cập nhật...${RS}"
            if git pull origin "$current_branch" &>/dev/null; then
                echo -e "${G}[Auto-Update] ✓ Đã cập nhật xong! Chạy lại tool để dùng bản mới.${RS}"
            else
                git reset --hard "origin/$current_branch" &>/dev/null
                git pull origin "$current_branch" &>/dev/null
                echo -e "${G}[Auto-Update] ✓ Đã ép cập nhật xong!${RS}"
            fi
            sleep 2
        fi
    ) &
}

if [ -z "$_TERMUX_OS_AUTO_UPDATE_DONE" ]; then
    export _TERMUX_OS_AUTO_UPDATE_DONE=1
    auto_update_on_start
fi

# ══════════════════════════════════════════════════════════
#  [8] CYBER LOCK
# ══════════════════════════════════════════════════════════
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
            cd ~/Termux-os && bash os.sh
            return
        else
            if [ -f "/storage/emulated/0/Termux-os/key" ]; then
                echo -e "\n\033[1;32m[!] Mật khẩu của bạn là : \033[1;33m\$(cat /storage/emulated/0/Termux-os/key)\033[0m"
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
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc 2>/dev/null
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc 2>/dev/null
    rm -f /storage/emulated/0/Termux-os/key
    echo -e "${R}Đã hủy kích hoạt Giao thức Bảo mật và xóa file Key.${RS}"
    sleep 2
    menu
}

# ══════════════════════════════════════════════════════════
#  SMART MODE — AI tìm GÓI qua pkg/pip/npm/gem/cargo
# ══════════════════════════════════════════════════════════
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

if [ -z "$TMPDIR" ]; then
    export TMPDIR="$PREFIX/tmp"
fi
mkdir -p "$TMPDIR" 2>/dev/null

# ── Gemini AI: hỏi TÊN GÓI + MANAGER ──
_gemini_suggest_pkg() {
    local cmd="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local ai_out="${tmp_dir}/_ai_g_$$.json"
    local raw=""

    if [[ -z "$GEMINI_API_KEY" || "$GEMINI_API_KEY" == "YOUR_GEMINI_API_KEY_HERE" ]]; then
        echo ""
        return
    fi

    local payload
    payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")

    curl -sf --max-time 25 \
      -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$payload" \
      > "$ai_out" 2>/dev/null || { rm -f "$ai_out"; echo ""; return; }

    raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
        | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
    rm -f "$ai_out" 2>/dev/null

    echo "$raw"
}

# ── Cài pkg với spinner ──
_try_install_pkg() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.code"

    ( pkg install -y "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r\033[1;96m[Auto Install]\033[0m \033[1;93m%s\033[0m Đang cài 'pkg: %s'..." "${frames[$i]}" "$pkg_name"
        i=$(( (i + 1) % 10 )); sleep 0.1
    done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file" 2>/dev/null
    return "${status:-1}"
}

_try_install_pip() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.code"

    ( pip install "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r\033[1;95m[Auto Install pip]\033[0m \033[1;93m%s\033[0m Đang cài 'pip: %s'..." "${frames[$i]}" "$pkg_name"
        i=$(( (i + 1) % 10 )); sleep 0.1
    done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file" 2>/dev/null
    return "${status:-1}"
}

_try_install_npm() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.code"

    ( npm install -g "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r\033[1;95m[Auto Install npm]\033[0m \033[1;93m%s\033[0m Đang cài 'npm: %s'..." "${frames[$i]}" "$pkg_name"
        i=$(( (i + 1) % 10 )); sleep 0.1
    done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file" 2>/dev/null
    return "${status:-1}"
}

# ── Auto Install: pkg → AI (pkg/pip/npm/gem/cargo) → pkg search ──
_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'

    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    mkdir -p "$tmp_dir" 2>/dev/null

    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    # Bước 1: thử pkg install trực tiếp với tên lệnh
    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    if _try_install_pkg "$cmd"; then
        if command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    # Bước 2: hỏi Gemini AI tên GÓI + MANAGER
    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được trực tiếp. Đang hỏi Gemini AI..."
    local raw manager_hint pkg_hint
    raw=$(_gemini_suggest_pkg "$cmd")

    if [[ -n "$raw" ]]; then
        if [[ "$raw" == *:* ]]; then
            manager_hint="${raw%%:*}"
            pkg_hint="${raw#*:}"
        else
            manager_hint="pkg"
            pkg_hint="$raw"
        fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        if [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]]; then
            pkg_hint=""
        fi
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"

        local ok=1
        case "$manager_hint" in
            pkg)
                _try_install_pkg "$pkg_hint" && ok=0
                ;;
            pip)
                _try_install_pip "$pkg_hint" && ok=0
                # pip install có thể không tạo binary, thử import
                if [[ "$ok" == "1" ]] && python -c "import ${pkg_hint}" 2>/dev/null; then
                    echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài 'pip: ${_AI_Y}${pkg_hint}${_AI_RST}' (import OK)"
                    return 0
                fi
                ;;
            npm)
                _try_install_npm "$pkg_hint" && ok=0
                ;;
            gem)
                ( timeout 25 gem install "$pkg_hint" &>/dev/null ) && ok=0
                ;;
            cargo)
                ( cargo install "$pkg_hint" &>/dev/null ) && ok=0
                ;;
        esac

        if [[ "$ok" == "0" ]]; then
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}' (binary khác tên lệnh)"
            return 0
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không cài được '${pkg_hint}' qua ${manager_hint}."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI."
    fi

    # Bước 3: pkg search fallback
    echo ""
    echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list
    alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do
            echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"; idx=$(( idx + 1 ))
        done <<< "$alt_list"
        echo ""
        echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected; selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [[ -n "$selected" ]]; then
                if _try_install_pkg "$selected"; then
                    if command -v "$cmd" &>/dev/null; then
                        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                        "$cmd" "${args[@]}"; return $?
                    fi
                    return 0
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}' sau khi cài '${selected}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào phù hợp cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

# ── Smart Run (dùng trong REPL 11line) ──
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

    # Smart Run: file tồn tại
    local filename="${input%% *}"
    local ext="${filename##*.}"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
        case "$ext" in
            py)   python "$filename";       return ;;
            sh)   bash "$filename";         return ;;
            js)   node "$filename";         return ;;
            ts)   npx ts-node "$filename";  return ;;
            php)  php "$filename";          return ;;
            rb)   ruby "$filename";         return ;;
            lua)  lua "$filename";          return ;;
            pl)   perl "$filename";         return ;;
            go)   go run "$filename";       return ;;
            r|R)  Rscript "$filename";      return ;;
            java) local cls="${filename%.java}"; javac "$filename" && java "$cls"; return ;;
            c)    local out="${filename%.c}"; gcc "$filename" -o "$out" && "./$out"; return ;;
            cpp)  local out="${filename%.cpp}"; g++ "$filename" -o "$out" && "./$out"; return ;;
            rs)   local out="${filename%.rs}"; rustc "$filename" && "./$out"; return ;;
        esac
    fi

    # Kiểm tra lệnh đã cài chưa
    local first_word="${input%% *}"
    if ! command -v "$first_word" &>/dev/null; then
        _auto_install $input
        return $?
    fi

    bash -c "$input"
}

# ══════════════════════════════════════════════════════════
#  [12] CÀI SMART MODE VÀO SHELL (vĩnh viễn)
# ══════════════════════════════════════════════════════════
11line() {
    local marker="# SMART MODE (by Termux-OS)"

    # ── Cài vào ~/.zshrc ──
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

# ── Gemini AI: hỏi TÊN GÓI + MANAGER ──
_gemini_suggest_pkg() {
    local cmd="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local ai_out="${tmp_dir}/_ai_g_$$.json"
    local raw=""
    [[ -z "$GEMINI_API_KEY" || "$GEMINI_API_KEY" == "YOUR_GEMINI_API_KEY_HERE" ]] && { echo ""; return; }
    local payload
    payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")
    curl -sf --max-time 25 -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" -H "Content-Type: application/json" -d "$payload" > "$ai_out" 2>/dev/null || { rm -f "$ai_out"; echo ""; return; }
    raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
    rm -f "$ai_out" 2>/dev/null
    echo "$raw"
}

_try_install_pkg() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.code"
    ( pkg install -y "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=1
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;96m[Auto Install]\033[0m \033[1;93m%s\033[0m Đang cài 'pkg: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( i % 10 + 1 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_try_install_pip() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.code"
    ( pip install "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=1
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;95m[Auto Install pip]\033[0m \033[1;93m%s\033[0m Đang cài 'pip: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( i % 10 + 1 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_try_install_npm() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.code"
    ( npm install -g "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local -a frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=1
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;95m[Auto Install npm]\033[0m \033[1;93m%s\033[0m Đang cài 'npm: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( i % 10 + 1 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    setopt LOCAL_OPTIONS; unsetopt NOTIFY
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"; mkdir -p "$tmp_dir" 2>/dev/null
    command -v pkg &>/dev/null || { echo "command not found: $cmd"; return 127; }

    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    if _try_install_pkg "$cmd"; then
        if command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được trực tiếp. Đang hỏi Gemini AI..."
    local raw manager_hint pkg_hint
    raw=$(_gemini_suggest_pkg "$cmd")
    if [[ -n "$raw" ]]; then
        if [[ "$raw" == *:* ]]; then manager_hint="${raw%%:*}"; pkg_hint="${raw#*:}"; else manager_hint="pkg"; pkg_hint="$raw"; fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]] && pkg_hint=""
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"
        local ok=1
        case "$manager_hint" in
            pkg) _try_install_pkg "$pkg_hint" && ok=0 ;;
            pip) _try_install_pip "$pkg_hint" && ok=0
                 if [[ "$ok" == "1" ]] && python -c "import ${pkg_hint}" 2>/dev/null; then
                     echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài 'pip: ${_AI_Y}${pkg_hint}${_AI_RST}' (import OK)"; return 0
                 fi ;;
            npm) _try_install_npm "$pkg_hint" && ok=0 ;;
            gem) ( timeout 25 gem install "$pkg_hint" &>/dev/null ) && ok=0 ;;
            cargo) ( cargo install "$pkg_hint" &>/dev/null ) && ok=0 ;;
        esac
        if [[ "$ok" == "0" ]]; then
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}'"; return 0
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không cài được '${pkg_hint}' qua ${manager_hint}."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI."
    fi

    echo ""; echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list; alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"; idx=$(( idx + 1 )); done <<< "$alt_list"
        echo ""; echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"; read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected; selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [[ -n "$selected" ]]; then
                if _try_install_pkg "$selected"; then
                    if command -v "$cmd" &>/dev/null; then
                        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                        "$cmd" "${args[@]}"; return $?
                    fi
                    return 0
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}' sau khi cài '${selected}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào phù hợp cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

command_not_found_handler() {
    local filename="$1"
    local ext="${filename##*.}"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
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
        esac
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

    # ── Cài vào ~/.bashrc ──
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

_gemini_suggest_pkg() {
    local cmd="$1"
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"
    local ai_out="${tmp_dir}/_ai_g_$$.json"
    local raw=""
    [[ -z "$GEMINI_API_KEY" || "$GEMINI_API_KEY" == "YOUR_GEMINI_API_KEY_HERE" ]] && { echo ""; return; }
    local payload
    payload=$(printf '{"contents":[{"parts":[{"text":"I am on Termux (Android). The shell command \\"%s\\" is not installed. Which package manager and package name should I use to install it? Answer STRICTLY in the format MANAGER:PACKAGE on one line. MANAGER must be one of: pkg, pip, npm, gem, cargo. PACKAGE must be the exact install name. Examples: pkg:python-numpy  pip:numpy  npm:typescript  gem:lolcat  cargo:ripgrep. No explanation, no quotes."}]}]}' "$cmd")
    curl -sf --max-time 25 -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" -H "Content-Type: application/json" -d "$payload" > "$ai_out" 2>/dev/null || { rm -f "$ai_out"; echo ""; return; }
    raw=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\\')
    rm -f "$ai_out" 2>/dev/null
    echo "$raw"
}

_try_install_pkg() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_ai_$$.code"
    ( pkg install -y "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=0
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;96m[Auto Install]\033[0m \033[1;93m%s\033[0m Đang cài 'pkg: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( (i + 1) % 10 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_try_install_pip() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_pip_$$.code"
    ( pip install "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=0
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;95m[Auto Install pip]\033[0m \033[1;93m%s\033[0m Đang cài 'pip: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( (i + 1) % 10 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_try_install_npm() {
    local pkg_name="$1"
    local log_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.log"
    local code_file="${TMPDIR:-$PREFIX/tmp}/_npm_$$.code"
    ( npm install -g "$pkg_name" &>"$log_file"; echo $? > "$code_file" ) &
    local pid=$!; local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"); local i=0
    while kill -0 "$pid" 2>/dev/null; do printf "\r\033[1;95m[Auto Install npm]\033[0m \033[1;93m%s\033[0m Đang cài 'npm: %s'..." "${frames[$i]}" "$pkg_name"; i=$(( (i + 1) % 10 )); sleep 0.1; done
    wait "$pid" 2>/dev/null; printf "\r\033[2K"
    local status; status=$(cat "$code_file" 2>/dev/null); rm -f "$log_file" "$code_file" 2>/dev/null; return "${status:-1}"
}

_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local tmp_dir="${TMPDIR:-$PREFIX/tmp}"; mkdir -p "$tmp_dir" 2>/dev/null
    command -v pkg &>/dev/null || { echo "command not found: $cmd"; return 127; }

    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử 'pkg install ${cmd}'..."
    if _try_install_pkg "$cmd"; then
        if command -v "$cmd" &>/dev/null; then
            echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${cmd}${_AI_RST}'"
            "$cmd" "${args[@]}"; return $?
        fi
    fi

    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được trực tiếp. Đang hỏi Gemini AI..."
    local raw manager_hint pkg_hint
    raw=$(_gemini_suggest_pkg "$cmd")
    if [[ -n "$raw" ]]; then
        if [[ "$raw" == *:* ]]; then manager_hint="${raw%%:*}"; pkg_hint="${raw#*:}"; else manager_hint="pkg"; pkg_hint="$raw"; fi
        [[ ! "$manager_hint" =~ ^(pkg|pip|npm|gem|cargo)$ ]] && manager_hint="pkg"
        [[ ! "$pkg_hint" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.+-]*$ ]] && pkg_hint=""
    fi

    if [[ -n "$pkg_hint" ]]; then
        echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${manager_hint} install ${pkg_hint}${_AI_RST}"
        local ok=1
        case "$manager_hint" in
            pkg) _try_install_pkg "$pkg_hint" && ok=0 ;;
            pip) _try_install_pip "$pkg_hint" && ok=0
                 if [[ "$ok" == "1" ]] && python -c "import ${pkg_hint}" 2>/dev/null; then
                     echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài 'pip: ${_AI_Y}${pkg_hint}${_AI_RST}' (import OK)"; return 0
                 fi ;;
            npm) _try_install_npm "$pkg_hint" && ok=0 ;;
            gem) ( timeout 25 gem install "$pkg_hint" &>/dev/null ) && ok=0 ;;
            cargo) ( cargo install "$pkg_hint" &>/dev/null ) && ok=0 ;;
        esac
        if [[ "$ok" == "0" ]]; then
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài '${manager_hint}: ${_AI_Y}${pkg_hint}${_AI_RST}'"; return 0
        fi
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không cài được '${pkg_hint}' qua ${manager_hint}."
    else
        echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI."
    fi

    echo ""; echo -e "${_AI_Y}[Auto Install]${_AI_RST} Đang tìm gói trong kho Termux..."
    local alt_list; alt_list=$(pkg search "$cmd" 2>/dev/null | grep -v "^Sorting\|^Full\|^N:\|^\s*$" | awk '{print $1}' | grep -i "$cmd" | head -5)
    if [[ -n "$alt_list" ]]; then
        echo -e "${_AI_Y}[Auto Install]${_AI_RST} Tìm thấy các gói liên quan:"
        local idx=1
        while IFS= read -r pkg_name; do echo -e "  ${_AI_C}[${idx}]${_AI_RST} ${pkg_name}"; idx=$(( idx + 1 )); done <<< "$alt_list"
        echo ""; echo -ne "${_AI_Y}Chọn số để cài (Enter = bỏ qua): ${_AI_RST}"; read -r choice
        if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 ]]; then
            local selected; selected=$(echo "$alt_list" | sed -n "${choice}p")
            if [[ -n "$selected" ]]; then
                if _try_install_pkg "$selected"; then
                    if command -v "$cmd" &>/dev/null; then
                        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài '${_AI_Y}${selected}${_AI_RST}'"
                        "$cmd" "${args[@]}"; return $?
                    fi
                    return 0
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không chạy được '${cmd}' sau khi cài '${selected}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào phù hợp cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

command_not_found_handle() {
    local filename="$1"
    local ext="${filename##*.}"
    if [[ "$filename" == *.* && "$filename" != *' '* && -f "$filename" ]]; then
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
        esac
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

# ══════════════════════════════════════════════════════════
#  MENU CHÍNH
# ══════════════════════════════════════════════════════════
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
    printf "\n${left_pad}${C}[${W}11${C}]${G} ⚡ Cài Smart Mode vào Shell ${Y}(Vĩnh viễn)"
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
        0|00)  exit   ;;
        *)     menu   ;;
    esac
}
menu