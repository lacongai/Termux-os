# Termux Mods V2 - Hướng Dẫn Cài Đặt và Sử Dụng

> **Phiên bản:** V2 CN  
> **Cập nhật:** 05/07/2026 lúc 21:58  
> **Phát hành công khai:** 23:15 cùng ngày

---

# 📦 Cài Đặt Lần Đầu

Sao chép và dán các lệnh sau vào Termux:

## Cập nhật hệ thống
```bash
apt update && apt upgrade -y
```

## Cài đặt Git
```bash
pkg install git
```

## Clone repository
```bash
cd ~
git clone https://github.com/lacongai/Termux-os
```

## Di chuyển vào thư mục
```bash
cd Termux-os
```

## Chạy script cài đặt
```bash
bash os.sh
```

---

# 🔄 Cài Đặt Lại Từ Đầu

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

⚠️ Lưu ý: Trong quá trình cài đặt, nếu gặp lỗi font chữ, hãy chọn tùy chọn 1 để khắc phục.


---

# 🧰 Các Tính Năng Có Sẵn
### Tên Mô tả

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


---

# Lệnh [12]
⚡ Chế Độ Smart Mode (Tính năng 12)

```bash
   🎯 Các Tính Năng Thông Minh

Smart Path — paste đường dẫn → tự cd	     
Smart Run — gõ app.py → tự chạy đúng 
interpreter	                               
Auto Install — lệnh chưa có → tự cài
hỗ trợ Ai để cài đặt chính xác hơn.        
```

```bash
 📌 Cơ Chế Hoạt Động

✅ (_smart_accept_line)
✅ (command_not_found_handler)
✅ (_auto_install)
```

---

## 🤖 Hỗ Trợ AI Gemini

## Smart Mode sử dụng AI Gemini để đưa ra gợi ý cài đặt chính xác hơn:
## Api Endpoint
```bash
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}
```

## Chìa khóa ai mặc định
```bash
GEMINI_API_KEY="AIzaSyBOaPceEXRzZNMeYF3uXt3yRriv-OiVS2U"
```
### ⚠️ Khuyến cáo bảo mật:
Nên thay đổi API Key mặc định thành key của riêng bạn để đảm bảo an toàn.

---

📝 Hướng Dẫn Sử Dụng

1. Lần đầu chạy: Chọn tùy chọn 01 để cài đặt các gói cần thiết
2. Tùy chỉnh giao diện: Sử dụng các tùy chọn 02 → 07 để setup shell theo sở thích
3. Bảo mật: Nên chọn tùy chọn 08 để thêm lớp bảo vệ
4. Tăng năng suất: Kích hoạt Smart Mode (tùy chọn 11 hoặc 12)

---

❓ Hỗ Trợ

Nếu gặp vấn đề trong quá trình cài đặt hoặc sử dụng, vui lòng tạo issue trên repository của dự án.

---

© 2026 Termux Mods V2 | Bảo lưu mọi quyền
```
https://t.me/@henntaiiz
```
https://img.shields.io/badge/Telegram-@henntaiiz-blue?style=for-the-badge&logo=telegram
