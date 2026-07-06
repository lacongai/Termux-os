# Termux Mods V2 CN update, July 5th, 2026 at 21:58 PM, public update at 23:15 PM.
# Installation

```bash
apt update && apt upgrade -y
pkg install git
git clone https://github.com/lacongai/Termux-os
cd Termux-os
bash os.sh

```


# Reinstall the Tool

## 1. Xóa tool cũ
```bash
rm -rf ~/Termux-os
```

## 2. Clone lại mới
```bash
cd ~
git clone https://github.com/lacongai/Termux-os
```

## 3. Vào thư mục
```bash
cd ~/Termux-os
```

## 4. Chạy lại file
```bash
bash os.sh
```

### Note: Trong quá trình cài bị lỗi font chữ thì Lựa chọn: 1 để hết lỗi


# Các lệnh hiện có
                        [01] Cài đặt Cần thiết
                        [02] Thiết lập Zsh
                        [03] Shell Zsh
                        [04] Shell Bash
                        [05] Banner Zsh
                        [06] Giao diện Zsh
                        [07] Tô sáng / Gợi ý tự động
                        [08] Thêm Khóa Cyber (Bảo mật Cao)
                        [09] Xóa Khóa
                        [10] Cập nhật Script
                        [11] ⚡ Smart Mode (Chạy tạm thời)
                        [12] ⚡ Cài Smart Mode vào Shell (Vĩnh viễn)
                        [00] Thoát Terminal

# Lệnh [12]
          Tính năng
```bash
Smart Path — paste đường dẫn → tự cd	     
Smart Run — gõ app.py → tự chạy đúng 
interpreter	                               
Auto Install — lệnh chưa có → tự cài
hỗ trợ Ai để cài đặt chính xác hơn.        
```

           Có trong [12]
```bash
✅ (_smart_accept_line)
✅ (command_not_found_handler)
✅ (_auto_install)
```

## Api ai gemini
```bash
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}
```

## Chìa khóa ai mặc định
```bash
GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
```
