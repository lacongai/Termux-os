#!/bin/bash
# ══════════════════════════════════════════════════════════
#  AUTO FIX — Termux-OS v2 (Safe version)
# ══════════════════════════════════════════════════════════

R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;93m'
C='\033[1;96m'
W='\033[1;97m'
RS='\033[0m'

echo -e "${C}╔══════════════════════════════════════════╗${RS}"
echo -e "${C}║   ${Y}🔧  AUTO FIX — Termux-OS v2  🔧${C}      ║${RS}"
echo -e "${C}╚══════════════════════════════════════════╝${RS}"
echo ""

# ─────────────────────────────────────────────────────────
#  FIX 0: Cài lolcat nếu thiếu
# ─────────────────────────────────────────────────────────
fix_lolcat() {
    if ! command -v lolcat &>/dev/null; then
        echo -e "${Y}[!] lolcat chưa có — đang cài...${RS}"
        if command -v gem &>/dev/null; then
            gem install lolcat 2>/dev/null
        fi
        if ! command -v lolcat &>/dev/null && command -v pkg &>/dev/null; then
            pkg install -y ruby 2>/dev/null
            gem install lolcat 2>/dev/null
        fi
        if command -v lolcat &>/dev/null; then
            echo -e "${G}[✓] Đã cài lolcat${RS}"
        else
            echo -e "${Y}[!] Không cài được lolcat — sẽ dùng fallback cat${RS}"
        fi
    else
        echo -e "${G}[✓] lolcat đã có sẵn${RS}"
    fi
}

# ─────────────────────────────────────────────────────────
#  FIX 1: Xóa block SAFE-HIGHLIGHT cũ (nếu có) — tránh parse error
# ─────────────────────────────────────────────────────────
remove_old_fix_blocks() {
    local file=$1
    [ ! -f "$file" ] && return

    # Xóa block cũ
    sed -i '/# >>> SAFE-HIGHLIGHT-START >>>/,/# <<< SAFE-HIGHLIGHT-END <<</d' "$file" 2>/dev/null
    sed -i '/# >>> SAFE-HIGHLIGHT-START >>>/d' "$file" 2>/dev/null
    sed -i '/# <<< SAFE-HIGHLIGHT-END <<</d' "$file" 2>/dev/null

    # Xóa dòng lỗi cũ
    sed -i '/^[[:space:]]*ZSH_HIGHLIGHT_STYLES\[unknown-token\]=/d' "$file" 2>/dev/null
    sed -i '/# Fix: chỉ gán style nếu plugin zsh-syntax-highlighting đã load/d' "$file" 2>/dev/null
    sed -i '/# Fix lỗi "invalid subscript range"/d' "$file" 2>/dev/null
    sed -i '/if (( ${+ZSH_HIGHLIGHT_STYLES} )); then/d' "$file" 2>/dev/null
    sed -i '/typeset -gA ZSH_HIGHLIGHT_STYLES/d' "$file" 2>/dev/null
}

# ─────────────────────────────────────────────────────────
#  FIX 2: Xóa BOM, CRLF, zero-width chars
# ─────────────────────────────────────────────────────────
fix_weird_chars() {
    local file=$1
    [ ! -f "$file" ] && return

    sed -i '1s/^\xEF\xBB\xBF//' "$file" 2>/dev/null
    sed -i 's/\r$//' "$file" 2>/dev/null
    sed -i 's/\xe2\x80\x8b//g' "$file" 2>/dev/null
    sed -i 's/\xef\xbb\xbf//g' "$file" 2>/dev/null
}

# ─────────────────────────────────────────────────────────
#  FIX 3: Đảm bảo cấu trúc if/fi cân bằng (phát hiện parse error)
# ─────────────────────────────────────────────────────────
check_balance() {
    local file=$1
    [ ! -f "$file" ] && return 1

    local if_count else_count fi_count
    if_count=$(grep -cE '^[[:space:]]*(if[[:space:]]|if$)' "$file" 2>/dev/null || echo 0)
    fi_count=$(grep -cE '^[[:space:]]*fi[[:space:]]*$' "$file" 2>/dev/null || echo 0)
    else_count=$(grep -cE '^[[:space:]]*else[[:space:]]*$' "$file" 2>/dev/null || echo 0)

    if [ "$if_count" -ne "$fi_count" ]; then
        echo -e "${R}[!] Phát hiện if/fi KHÔNG cân bằng trong $file (if=$if_count, fi=$fi_count)${RS}"
        return 1
    fi
    return 0
}

# ─────────────────────────────────────────────────────────
#  FIX 4: Inject block SAFE-HIGHLIGHT — CHỈ 1 dòng gán có điều kiện
# ─────────────────────────────────────────────────────────
inject_safe_highlight() {
    local file=$1
    [ ! -f "$file" ] && return

    # Xóa block cũ
    sed -i '/# >>> SAFE-HIGHLIGHT-START >>>/,/# <<< SAFE-HIGHLIGHT-END <<</d' "$file" 2>/dev/null

    # Thêm block mới AN TOÀN — dùng [[ ]] thay vì (())
    cat >> "$file" << 'SAFE_EOF'

# >>> SAFE-HIGHLIGHT-START >>>
# Fix ZSH_HIGHLIGHT_STYLES — tránh "invalid subscript range"
# Chỉ chạy khi biến đã tồn tại (plugin đã load)
if [[ -n "${ZSH_HIGHLIGHT_STYLES+x}" ]]; then
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow,bold' 2>/dev/null || true
fi
# <<< SAFE-HIGHLIGHT-END <<<
SAFE_EOF
}

# ─────────────────────────────────────────────────────────
#  FIX 5: Fix cấu trúc plugin order — chỉ dùng sed đơn giản
# ─────────────────────────────────────────────────────────
fix_plugin_order() {
    local file=$1
    [ ! -f "$file" ] && return

    # Nếu source plugin TRƯỚC oh-my-zsh → di chuyển xuống sau
    local omz_line shl_line
    omz_line=$(grep -n 'oh-my-zsh.sh' "$file" | head -1 | cut -d: -f1)
    shl_line=$(grep -n 'zsh-syntax-highlighting.zsh' "$file" | head -1 | cut -d: -f1)

    if [ -n "$shl_line" ] && [ -n "$omz_line" ] && [ "$shl_line" -lt "$omz_line" ]; then
        echo -e "${Y}[!] Fix thứ tự plugin trong $file...${RS}"
        # Xóa 2 dòng source cũ
        sed -i '/zsh-autosuggestions\.zsh/d' "$file"
        sed -i '/zsh-syntax-highlighting\.zsh/d' "$file"
        # Thêm lại SAU oh-my-zsh.sh — dùng dòng cụ thể
        sed -i "/source.*oh-my-zsh\.sh/a\\
[[ -f \$HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \&\& source \$HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\\
[[ -f \$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \&\& source \$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$file"
    fi
}

# ─────────────────────────────────────────────────────────
#  FIX 6: Fix lỗi hiển thị % — escape % trong banner
# ─────────────────────────────────────────────────────────
fix_percent_display() {
    local file=$1
    [ ! -f "$file" ] && return

    # Escape % trong các dòng printf/echo có chứa ký tự % đơn lẻ
    # Chỉ trong block draw_banner (từ draw_banner() đến })
    # Đơn giản: replace printf "...${text}..." thành printf "%s" "${text}"
    # Không tự động sửa vì có thể hỏng code — chỉ cảnh báo
    if grep -qE 'print_center.*[^%]%[^%]' "$file" 2>/dev/null; then
        echo -e "${Y}[!] Có thể có lỗi %% trong $file — kiểm tra hàm print_center${RS}"
    fi
}

# ─────────────────────────────────────────────────────────
#  FIX 7: Fix banner zshrc — đảm bảo lolcat có fallback
# ─────────────────────────────────────────────────────────
fix_banner_fallback() {
    local file=$1
    [ ! -f "$file" ] && return

    # Thay `| lolcat` bằng fallback an toàn
    if grep -q 'figlet.*| lolcat' "$file" 2>/dev/null; then
        # Không sửa file gốc — chỉ cảnh báo
        echo -e "${Y}[!] $file dùng lolcat — đảm bảo gem đã cài${RS}"
    fi
}

# ─────────────────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────────────────
echo -e "${C}[1/4] Fix lolcat...${RS}"
fix_lolcat
echo ""

echo -e "${C}[2/4] Fix ~/.zshrc...${RS}"
if [ -f ~/.zshrc ]; then
    # Backup trước khi sửa
    cp ~/.zshrc ~/.zshrc.bak.$(date +%s)

    remove_old_fix_blocks ~/.zshrc
    fix_weird_chars ~/.zshrc

    if check_balance ~/.zshrc; then
        echo -e "${G}[✓] Cấu trúc if/fi cân bằng${RS}"
    else
        echo -e "${R}[!] File .zshrc có lỗi cú pháp — khôi phục từ backup nếu cần${RS}"
        echo -e "${Y}→ Backup: ~/.zshrc.bak.*${RS}"
    fi

    fix_plugin_order ~/.zshrc
    inject_safe_highlight ~/.zshrc
    fix_percent_display ~/.zshrc
    fix_banner_fallback ~/.zshrc
    echo -e "${G}[✓] Đã fix ~/.zshrc${RS}"
else
    echo -e "${Y}[!] Không tìm thấy ~/.zshrc${RS}"
fi
echo ""

echo -e "${C}[3/4] Fix ~/.bashrc...${RS}"
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.bak.$(date +%s)
    fix_weird_chars ~/.bashrc
    echo -e "${G}[✓] Đã fix ~/.bashrc${RS}"
else
    echo -e "${Y}[!] Không tìm thấy ~/.bashrc${RS}"
fi
echo ""

echo -e "${C}[4/4] Kiểm tra file banner trong .object...${RS}"
for f in ~/Termux-os/.object/.1zshrc ~/Termux-os/.object/.2zshrc; do
    if [ -f "$f" ]; then
        fix_weird_chars "$f"
        fix_banner_fallback "$f"
        echo -e "${G}[✓] Đã kiểm tra $f${RS}"
    fi
done

echo ""
echo -e "${G}╔══════════════════════════════════════════╗${RS}"
echo -e "${G}║   ${W}✅  HOÀN TẤT FIX TỰ ĐỘNG  ✅${G}          ║${RS}"
echo -e "${G}╚══════════════════════════════════════════╝${RS}"
echo ""
echo -e "${Y}→ Chạy 'source ~/.zshrc' để áp dụng${RS}"
echo ""