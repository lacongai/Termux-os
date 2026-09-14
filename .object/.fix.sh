#!/bin/bash
# ══════════════════════════════════════════════════════════
#  AUTO FIX — Termux-OS v2
#  Fix các lỗi thường gặp trong .zshrc và .bashrc
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
#  FIX 1: ZSH_HIGHLIGHT_STYLES invalid subscript range
# ─────────────────────────────────────────────────────────
fix_highlight_styles() {
    local file=$1
    [ ! -f "$file" ] && return

    # Xóa dòng cũ nếu có
    sed -i '/^[[:space:]]*ZSH_HIGHLIGHT_STYLES\[unknown-token\]=/d' "$file"
    sed -i '/# Fix: chỉ gán style nếu plugin zsh-syntax-highlighting đã load/d' "$file"
    sed -i '/# Fix lỗi "invalid subscript range"/d' "$file"
    sed -i '/if (( ${+ZSH_HIGHLIGHT_STYLES} )); then/d' "$file"
    sed -i '/typeset -gA ZSH_HIGHLIGHT_STYLES 2>\/dev\/null/d' "$file"

    echo -e "${G}[✓] Đã fix ZSH_HIGHLIGHT_STYLES trong $file${RS}"
}

# ─────────────────────────────────────────────────────────
#  FIX 2: Lỗi hiển thị % trong banner
#     Nguyên nhân: `echo -e "...%..."` in ra % như format
#     Giải pháp: escape % → %% hoặc chuyển echo → printf
# ─────────────────────────────────────────────────────────
fix_percent_display() {
    local file=$1
    [ ! -f "$file" ] && return

    # Escape % trong các dòng echo -e chứa banner ASCII
    # Chỉ áp dụng cho dòng chứa ký tự đặc biệt từ figlet
    if grep -q 'echo -e.*%' "$file" 2>/dev/null; then
        # Thay echo -e có % → printf '%b\n' an toàn
        cp "$file" "$file.bak"
        awk '
        /echo[[:space:]]+-e[[:space:]]+.*%/ {
            # Chuyển echo -e "...%" → printf "%b\n" "..." với % đã escape
            line = $0
            gsub(/%/, "%%", line)
            sub(/echo[[:space:]]+-e/, "printf \"%b\\\\n\"", line)
            print line
            next
        }
        { print }
        ' "$file.bak" > "$file"
        rm -f "$file.bak"
        echo -e "${G}[✓] Đã fix lỗi hiển thị %% trong $file${RS}"
    fi
}

# ─────────────────────────────────────────────────────────
#  FIX 3: Ký tự lỗi (zero-width, BOM, CRLF) trong .zshrc
# ─────────────────────────────────────────────────────────
fix_weird_chars() {
    local file=$1
    [ ! -f "$file" ] && return

    # Xóa BOM UTF-8 (EF BB BF)
    sed -i '1s/^\xEF\xBB\xBF//' "$file" 2>/dev/null

    # Xóa CRLF → LF
    sed -i 's/\r$//' "$file" 2>/dev/null

    # Xóa zero-width chars (U+200B, U+FEFF)
    sed -i 's/\xe2\x80\x8b//g' "$file" 2>/dev/null
    sed -i 's/\xef\xbb\xbf//g' "$file" 2>/dev/null

    echo -e "${G}[✓] Đã dọn ký tự lỗi trong $file${RS}"
}

# ─────────────────────────────────────────────────────────
#  FIX 4: Đảm bảo source đúng thứ tự plugin
#     zsh-syntax-highlighting PHẢI được source SAU oh-my-zsh
# ─────────────────────────────────────────────────────────
fix_plugin_order() {
    local file=$1
    [ ! -f "$file" ] && return

    if grep -q 'oh-my-zsh.sh' "$file" 2>/dev/null; then
        # Kiểm tra zsh-syntax-highlighting có trước oh-my-zsh không
        local omz_line shl_line
        omz_line=$(grep -n 'oh-my-zsh.sh' "$file" | head -1 | cut -d: -f1)
        shl_line=$(grep -n 'zsh-syntax-highlighting' "$file" | head -1 | cut -d: -f1)

        if [ -n "$shl_line" ] && [ -n "$omz_line" ] && [ "$shl_line" -lt "$omz_line" ]; then
            echo -e "${Y}[!] Phát hiện zsh-syntax-highlighting source TRƯỚC oh-my-zsh → đang fix...${RS}"
            # Xóa dòng cũ và thêm lại sau oh-my-zsh
            sed -i '/zsh-syntax-highlighting/d' "$file"
            sed -i '/zsh-autosuggestions/d' "$file"
            # Thêm lại sau dòng source oh-my-zsh
            sed -i "/oh-my-zsh.sh/a\\
[[ -f \$HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \&\& source \$HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\\
[[ -f \$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \&\& source \$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$file"
            echo -e "${G}[✓] Đã sắp xếp lại thứ tự plugin trong $file${RS}"
        fi
    fi
}

# ─────────────────────────────────────────────────────────
#  FIX 5: Thêm khối fix ZSH_HIGHLIGHT_STYLES an toàn vào cuối .zshrc
# ─────────────────────────────────────────────────────────
inject_safe_highlight() {
    local file=$1
    [ ! -f "$file" ] && return

    # Xóa khối cũ nếu có
    sed -i '/# >>> SAFE-HIGHLIGHT-START >>>/,/# <<< SAFE-HIGHLIGHT-END <<</d' "$file"

    cat >> "$file" << 'SAFE_EOF'

# >>> SAFE-HIGHLIGHT-START >>>
# Fix an toàn cho ZSH_HIGHLIGHT_STYLES — tránh "invalid subscript range"
# Chờ plugin load xong rồi mới gán style
_safe_highlight_hook() {
    if (( ${+ZSH_HIGHLIGHT_STYLES} )) && [[ -n "${ZSH_HIGHLIGHT_STYLES+x}" ]]; then
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow,bold'
    fi
}
# Hook vào precmd để chạy sau khi mọi thứ đã load
autoload -Uz add-zsh-hook 2>/dev/null && add-zsh-hook precmd _safe_highlight_hook 2>/dev/null
# Chạy ngay 1 lần (nếu plugin đã load)
_safe_highlight_hook 2>/dev/null
# <<< SAFE-HIGHLIGHT-END <<<
SAFE_EOF

    echo -e "${G}[✓] Đã thêm SAFE-HIGHLIGHT block vào $file${RS}"
}

# ─────────────────────────────────────────────────────────
#  FIX 6: Fix banner trong .zshrc — dùng printf thay echo -e
# ─────────────────────────────────────────────────────────
fix_banner_percent() {
    local file=$1
    [ ! -f "$file" ] && return

    # Nếu có dòng echo -e với figlet output chứa % → escape
    if grep -qE 'print_center.*%|echo.*figlet|\\PROC' "$file" 2>/dev/null; then
        # Escape % trong các biến text trước khi printf
        sed -i 's/printf.*"\${text}"/printf "%s" "${text}"/g' "$file" 2>/dev/null
    fi

    # Đảm bảo print_center dùng %s thay vì nhúng text
    if grep -q 'print_center' "$file" 2>/dev/null; then
        # Thêm dòng replace % trong biến text
        if ! grep -q '_SR_FIXED_PERCENT' "$file" 2>/dev/null; then
            sed -i '/draw_banner()/a\    # Fix % hiển thị sai trong banner\n    local _SR_FIXED_PERCENT=1' "$file" 2>/dev/null
        fi
    fi
}

# ─────────────────────────────────────────────────────────
#  MAIN — Chạy tất cả fix
# ─────────────────────────────────────────────────────────
echo -e "${C}[1/3] Fix ~/.zshrc...${RS}"
if [ -f ~/.zshrc ]; then
    fix_weird_chars ~/.zshrc
    fix_highlight_styles ~/.zshrc
    fix_plugin_order ~/.zshrc
    inject_safe_highlight ~/.zshrc
    fix_percent_display ~/.zshrc
    fix_banner_percent ~/.zshrc
else
    echo -e "${Y}[!] Không tìm thấy ~/.zshrc${RS}"
fi

echo ""
echo -e "${C}[2/3] Fix ~/.bashrc...${RS}"
if [ -f ~/.bashrc ]; then
    fix_weird_chars ~/.bashrc
    fix_percent_display ~/.bashrc
else
    echo -e "${Y}[!] Không tìm thấy ~/.bashrc${RS}"
fi

echo ""
echo -e "${C}[3/3] Fix file banner .zshrc trong .object...${RS}"
if [ -f ~/Termux-os/.object/.1zshrc ]; then
    fix_weird_chars ~/Termux-os/.object/.1zshrc
    fix_percent_display ~/Termux-os/.object/.1zshrc
fi
if [ -f ~/Termux-os/.object/.2zshrc ]; then
    fix_weird_chars ~/Termux-os/.object/.2zshrc
    fix_percent_display ~/Termux-os/.object/.2zshrc
fi

echo ""
echo -e "${G}╔══════════════════════════════════════════╗${RS}"
echo -e "${G}║   ${W}✅  HOÀN TẤT FIX TỰ ĐỘNG  ✅${G}          ║${RS}"
echo -e "${G}╚══════════════════════════════════════════╝${RS}"
echo ""
echo -e "${Y}→ Chạy 'source ~/.zshrc' để áp dụng ngay${RS}"
echo -e "${Y}→ Hoặc mở Termux mới để tự động load${RS}"
echo ""