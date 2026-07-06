# Termux Mods V2 - Hướng Dẫn Cài Đặt và Sử Dụng

> **Phiên bản:** V2 CN  
> **Cập nhật:** 05/07/2026 lúc 21:58  
> **Phát hành công khai:** 23:15 cùng ngày

---

## 📦 Cài Đặt Lần Đầu

Sao chép và dán các lệnh sau vào Termux:

# Cập nhật hệ thống
```bash
apt update && apt upgrade -y
```

# Cài đặt Git
```bash
pkg install git
```

# Clone repository
```bash
cd ~
git clone https://github.com/lacongai/Termux-os
```

# Di chuyển vào thư mục
```bash
cd Termux-os
```

# Chạy script cài đặt
```bash
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
# Tên Mô tả
01 Cài đặt Cần thiết Cài các gói công cụ cơ bản cho Termux
02 Thiết lập Zsh Cấu hình shell Zsh
03 Shell Zsh Chuyển sang sử dụng shell Zsh
04 Shell Bash Quay lại sử dụng shell Bash
05 Banner Zsh Tùy chỉnh banner hiển thị trên Zsh
06 Giao diện Zsh Cài đặt theme và giao diện cho Zsh
07 Tô sáng / Gợi ý Bật tính năng tô màu và gợi ý tự động
08 Thêm Khóa Cyber Tăng cường bảo mật (Chế độ an toàn cao)
09 Xóa Khóa Gỡ bỏ khóa bảo mật đã cài
10 Cập nhật Script Cập nhật phiên bản mới nhất
11 ⚡ Smart Mode Chạy chế độ thông minh tạm thời
12 ⚡ Cài Smart Mode Cài đặt Smart Mode vĩnh viễn
00 Thoát Đóng Terminal

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
