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

1line() { apt update && apt upgrade; pkg install zsh git figlet toilet ruby wget curl -y; gem install lolcat; clear; cd ~/Termux-os/.object/ && cp -r 'ANSI Shadow.flf' $PREFIX/share/figlet/ASCII-Shadow.flf; git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; pkg install toilet figlet exa -y; cd ~/Termux-os/.object; rm -rf ~/.termux/colors.properties; rm -rf /data/data/com.termux/files/usr/etc/motd; cp -r .colors.properties ~/.termux/colors.properties; cp -r .termux.properties ~/.termux.properties; curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf > ~/.termux/font.ttf; clear; cd ~/Termux-os ; bash os.sh; termux-open-url h4ck3r.me && termux-reload-settings; }
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

9line() {
    sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.bashrc
    [ -f ~/.zshrc ] && sed -i '/#LOCK_START/,/#LOCK_END/d' ~/.zshrc
    echo -e "${R}Đã hủy kích hoạt Giao thức Bảo mật.${RS}"
    sleep 2
    menu
}

# ─────────────────────────────────────────────────────────
#  SMART MODE — dùng trong REPL và cài vào shell
# ─────────────────────────────────────────────────────────
_SR_ERR='\033[1;31m'
_SR_RST='\033[0m'

# ── Auto Install (bash — dùng trong REPL) ─────────────────
_auto_install() {
    local cmd="$1"; shift; local args=("$@")
    local GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
    local _AI_C='\033[1;96m' _AI_Y='\033[1;93m' _AI_G='\033[1;32m'
    local _AI_R='\033[1;31m' _AI_W='\033[1;97m' _AIA='\033[1;95m' _AI_RST='\033[0m'
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    mkdir -p /tmp
    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    # ── Bước 1: pkg install trực tiếp ────────────────────────
    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử cài..."
    local log_file="/tmp/_ai_$$.log" code_file="/tmp/_ai_exit_$$.code"
    ( pkg install -y "$cmd" &>"$log_file"; echo $? > "$code_file" ) &
    local pkg_pid=$!; local spin_i=0
    while kill -0 "$pkg_pid" 2>/dev/null; do
        printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin_i]}${_AI_RST} Đang cài '${_AI_W}${cmd}${_AI_RST}'..."
        spin_i=$(( (spin_i + 1) % 10 )); sleep 0.1
    done
    wait "$pkg_pid" 2>/dev/null; printf "\r\033[2K"
    local install_status; install_status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file"
    if [[ "$install_status" == "0" ]] && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    # ── Bước 2: Gemini AI (ưu tiên trước pkg search) ─────────
    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được '${cmd}'. Đang hỏi Gemini AI..."
    local ai_pkg=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="/tmp/_ai_g_$$.json"
        (
            curl -sf --max-time 20 \
              -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
              -H "Content-Type: application/json" \
              -d "{\"contents\":[{\"parts\":[{\"text\":\"What is the exact Termux pkg package name for the command: ${cmd}? Reply with ONLY the package name, one word.\"}]}]}" \
              > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        local ai_pid=$!; local spin_ai=0
        while kill -0 "$ai_pid" 2>/dev/null; do
            printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai]}${_AI_RST} Đang hỏi Gemini..."
            spin_ai=$(( (spin_ai + 1) % 10 )); sleep 0.1
        done
        wait "$ai_pid" 2>/dev/null; printf "\r\033[2K"
        ai_pkg=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\n')
        rm -f "$ai_out"
        if [[ -n "$ai_pkg" && "$ai_pkg" =~ ^[a-zA-Z0-9][a-zA-Z0-9_+.-]*$ ]]; then
            echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${ai_pkg}${_AI_RST}"
            local log_ai="/tmp/_ai_gi_$$.log" code_ai="/tmp/_ai_gi_exit_$$.code"
            ( pkg install -y "$ai_pkg" &>"$log_ai"; echo $? > "$code_ai" ) &
            local ai_pkg_pid=$!; local spin_ai2=0
            while kill -0 "$ai_pkg_pid" 2>/dev/null; do
                printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai2]}${_AI_RST} Đang cài '${_AI_W}${ai_pkg}${_AI_RST}'..."
                spin_ai2=$(( (spin_ai2 + 1) % 10 )); sleep 0.1
            done
            wait "$ai_pkg_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log_ai" "$code_ai"
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${ai_pkg}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không thể cài '${ai_pkg}'. Chuyển sang tìm gói..."
        else
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI. Chuyển sang tìm gói..."
        fi
    else
        echo -e "${_AI_Y}[Auto Install AI]${_AI_RST} ⚠ Chưa cấu hình GEMINI_API_KEY — bỏ qua AI."
    fi

    # ── Bước 3: pkg search ────────────────────────────────────
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
                local log2="/tmp/_ai_s_$$.log" code2="/tmp/_ai_s_exit_$$.code"
                ( pkg install -y "$selected" &>"$log2"; echo $? > "$code2" ) &
                local pkg2_pid=$!; local spin2_i=0
                while kill -0 "$pkg2_pid" 2>/dev/null; do
                    printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin2_i]}${_AI_RST} Đang cài '${_AI_W}${selected}${_AI_RST}'..."
                    spin2_i=$(( (spin2_i + 1) % 10 )); sleep 0.1
                done
                wait "$pkg2_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log2" "$code2"
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không thể chạy '${cmd}' sau khi cài '${selected}'"
            fi
        fi
    else
        echo -e "${_AI_R}[Auto Install]${_AI_RST} Không tìm thấy gói nào phù hợp cho '${_AI_W}${cmd}${_AI_RST}'"
    fi
    return 127
}

# ── Smart Run + Auto Install dùng trong REPL ─────────────
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

    # Smart Run: file tồn tại với đuôi hỗ trợ
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

    # Lệnh thông thường — giữ nguyên
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
    echo -e "║  ${W}Nhập tên file  → tự chạy đúng lệnh     ${C}║"
    echo -e "║  ${W}Lệnh chưa cài  → tự hỏi cài pkg        ${C}║"
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

    cd ~/Termux-os ; bash os.sh
}

# ─────────────────────────────────────────────────────────
#  [12] Cài Smart Mode vào shell (vĩnh viễn) — dùng heredoc
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
    mkdir -p /tmp
    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    # ── Bước 1: pkg install trực tiếp ────────────────────────
    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử cài..."
    local log_file="/tmp/_ai_$$.log" code_file="/tmp/_ai_exit_$$.code"
    ( pkg install -y "$cmd" &>"$log_file"; echo $? > "$code_file" ) &
    local pkg_pid=$!; local spin_i=1
    while kill -0 "$pkg_pid" 2>/dev/null; do
        printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin_i]}${_AI_RST} Đang cài '${_AI_W}${cmd}${_AI_RST}'..."
        spin_i=$(( spin_i % 10 + 1 )); sleep 0.1
    done
    wait "$pkg_pid" 2>/dev/null; printf "\r\033[2K"
    local install_status; install_status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file"
    if [[ "$install_status" == "0" ]] && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    # ── Bước 2: Gemini AI (ưu tiên trước pkg search) ─────────
    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được '${cmd}'. Đang hỏi Gemini AI..."
    local ai_pkg=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="/tmp/_ai_g_$$.json"
        (
            curl -sf --max-time 20 \
              -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
              -H "Content-Type: application/json" \
              -d "{\"contents\":[{\"parts\":[{\"text\":\"What is the exact Termux pkg package name for the command: ${cmd}? Reply with ONLY the package name, one word.\"}]}]}" \
              > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        local ai_pid=$!; local spin_ai=1
        while kill -0 "$ai_pid" 2>/dev/null; do
            printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai]}${_AI_RST} Đang hỏi Gemini..."
            spin_ai=$(( spin_ai % 10 + 1 )); sleep 0.1
        done
        wait "$ai_pid" 2>/dev/null; printf "\r\033[2K"
        ai_pkg=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\n')
        rm -f "$ai_out"
        if [[ -n "$ai_pkg" && "$ai_pkg" =~ ^[a-zA-Z0-9][a-zA-Z0-9_+.-]*$ ]]; then
            echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${ai_pkg}${_AI_RST}"
            local log_ai="/tmp/_ai_gi_$$.log" code_ai="/tmp/_ai_gi_exit_$$.code"
            ( pkg install -y "$ai_pkg" &>"$log_ai"; echo $? > "$code_ai" ) &
            local ai_pkg_pid=$!; local spin_ai2=1
            while kill -0 "$ai_pkg_pid" 2>/dev/null; do
                printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai2]}${_AI_RST} Đang cài '${_AI_W}${ai_pkg}${_AI_RST}'..."
                spin_ai2=$(( spin_ai2 % 10 + 1 )); sleep 0.1
            done
            wait "$ai_pkg_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log_ai" "$code_ai"
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${ai_pkg}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không thể cài '${ai_pkg}'. Chuyển sang tìm gói..."
        else
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI. Chuyển sang tìm gói..."
        fi
    else
        echo -e "${_AI_Y}[Auto Install AI]${_AI_RST} ⚠ Chưa cấu hình GEMINI_API_KEY — bỏ qua AI."
    fi

    # ── Bước 3: pkg search ────────────────────────────────────
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
                local log2="/tmp/_ai_s_$$.log" code2="/tmp/_ai_s_exit_$$.code"
                ( pkg install -y "$selected" &>"$log2"; echo $? > "$code2" ) &
                local pkg2_pid=$!; local spin2_i=1
                while kill -0 "$pkg2_pid" 2>/dev/null; do
                    printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin2_i]}${_AI_RST} Đang cài '${_AI_W}${selected}${_AI_RST}'..."
                    spin2_i=$(( spin2_i % 10 + 1 )); sleep 0.1
                done
                wait "$pkg2_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log2" "$code2"
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không thể chạy '${cmd}' sau khi cài '${selected}'"
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
    mkdir -p /tmp
    if ! command -v pkg &>/dev/null; then echo "command not found: $cmd"; return 127; fi

    # ── Bước 1: pkg install trực tiếp ────────────────────────
    echo -e "${_AI_C}[Auto Install]${_AI_RST} '${cmd}' chưa được cài. Đang thử cài..."
    local log_file="/tmp/_ai_$$.log" code_file="/tmp/_ai_exit_$$.code"
    ( pkg install -y "$cmd" &>"$log_file"; echo $? > "$code_file" ) &
    local pkg_pid=$!; local spin_i=0
    while kill -0 "$pkg_pid" 2>/dev/null; do
        printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin_i]}${_AI_RST} Đang cài '${_AI_W}${cmd}${_AI_RST}'..."
        spin_i=$(( (spin_i + 1) % 10 )); sleep 0.1
    done
    wait "$pkg_pid" 2>/dev/null; printf "\r\033[2K"
    local install_status; install_status=$(cat "$code_file" 2>/dev/null)
    rm -f "$log_file" "$code_file"
    if [[ "$install_status" == "0" ]] && command -v "$cmd" &>/dev/null; then
        echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${cmd}${_AI_RST}'"
        "$cmd" "${args[@]}"; return $?
    fi

    # ── Bước 2: Gemini AI (ưu tiên trước pkg search) ─────────
    echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Không cài được '${cmd}'. Đang hỏi Gemini AI..."
    local ai_pkg=""
    if [[ -n "$GEMINI_API_KEY" && "$GEMINI_API_KEY" != "YOUR_GEMINI_API_KEY_HERE" ]]; then
        local ai_out="/tmp/_ai_g_$$.json"
        (
            curl -sf --max-time 20 \
              -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
              -H "Content-Type: application/json" \
              -d "{\"contents\":[{\"parts\":[{\"text\":\"What is the exact Termux pkg package name for the command: ${cmd}? Reply with ONLY the package name, one word.\"}]}]}" \
              > "$ai_out" 2>/dev/null || echo '{"error":"timeout"}' > "$ai_out"
        ) &
        local ai_pid=$!; local spin_ai=0
        while kill -0 "$ai_pid" 2>/dev/null; do
            printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai]}${_AI_RST} Đang hỏi Gemini..."
            spin_ai=$(( (spin_ai + 1) % 10 )); sleep 0.1
        done
        wait "$ai_pid" 2>/dev/null; printf "\r\033[2K"
        ai_pkg=$(grep -o '"text":"[^"]*"' "$ai_out" 2>/dev/null | head -1 \
            | sed 's/"text":"//;s/".*//' | tr -d '[:space:]`*#\n')
        rm -f "$ai_out"
        if [[ -n "$ai_pkg" && "$ai_pkg" =~ ^[a-zA-Z0-9][a-zA-Z0-9_+.-]*$ ]]; then
            echo -e "${_AIA}[Auto Install AI]${_AI_RST} Gemini gợi ý: ${_AI_C}${ai_pkg}${_AI_RST}"
            local log_ai="/tmp/_ai_gi_$$.log" code_ai="/tmp/_ai_gi_exit_$$.code"
            ( pkg install -y "$ai_pkg" &>"$log_ai"; echo $? > "$code_ai" ) &
            local ai_pkg_pid=$!; local spin_ai2=0
            while kill -0 "$ai_pkg_pid" 2>/dev/null; do
                printf "\r${_AIA}[Auto Install AI]${_AI_RST} ${_AI_Y}${frames[$spin_ai2]}${_AI_RST} Đang cài '${_AI_W}${ai_pkg}${_AI_RST}'..."
                spin_ai2=$(( spin_ai2 % 10 + 1 )); sleep 0.1
            done
            wait "$ai_pkg_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log_ai" "$code_ai"
            if command -v "$cmd" &>/dev/null; then
                echo -e "${_AI_G}[Auto Install AI]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${ai_pkg}${_AI_RST}'"
                "$cmd" "${args[@]}"; return $?
            fi
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không thể cài '${ai_pkg}'. Chuyển sang tìm gói..."
        else
            echo -e "${_AI_R}[Auto Install AI]${_AI_RST} ✗ Không lấy được gợi ý từ AI. Chuyển sang tìm gói..."
        fi
    else
        echo -e "${_AI_Y}[Auto Install AI]${_AI_RST} ⚠ Chưa cấu hình GEMINI_API_KEY — bỏ qua AI."
    fi

    # ── Bước 3: pkg search ────────────────────────────────────
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
                local log2="/tmp/_ai_s_$$.log" code2="/tmp/_ai_s_exit_$$.code"
                ( pkg install -y "$selected" &>"$log2"; echo $? > "$code2" ) &
                local pkg2_pid=$!; local spin2_i=0
                while kill -0 "$pkg2_pid" 2>/dev/null; do
                    printf "\r${_AI_C}[Auto Install]${_AI_RST} ${_AI_Y}${frames[$spin2_i]}${_AI_RST} Đang cài '${_AI_W}${selected}${_AI_RST}'..."
                    spin2_i=$(( (spin2_i + 1) % 10 )); sleep 0.1
                done
                wait "$pkg2_pid" 2>/dev/null; printf "\r\033[2K"; rm -f "$log2" "$code2"
                if command -v "$cmd" &>/dev/null; then
                    echo -e "${_AI_G}[Auto Install]${_AI_RST} ✓ Đã cài thành công '${_AI_Y}${selected}${_AI_RST}'"
                    "$cmd" "${args[@]}"; return $?
                fi
                echo -e "${_AI_R}[Auto Install]${_AI_RST} ✗ Vẫn không thể chạy '${cmd}' sau khi cài '${selected}'"
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
