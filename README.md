# Tá Lả Triều Khúc

Mobile app (Flutter) cho phép **4 người chơi kết nối cùng một phòng** để chơi Tá lả (Phỏm) và tự động tính điểm.

## Tài liệu

- [Luật chơi Tá lả — đặc tả cho app](docs/luat-choi-ta-la.md)
- [Package luật chơi `ta_la_engine`](packages/ta_la_engine/README.md)
- [Kiến trúc chơi online (đề xuất)](docs/kien-truc-online.md)
- [Thiết kế giao diện](designs/README.md)
- [Chuyển dự án sang máy cá nhân (tách BE / Mobile)](docs/chuyen-sang-may-ca-nhan.md)

## Lộ trình

1. ✅ Tìm hiểu & chốt luật chơi
2. ✅ Engine luật (Dart thuần, có unit test + mô phỏng 3000 ván): `packages/ta_la_engine`
3. 🟡 Kiến trúc online: đã có đề xuất (server Dart trọng tài + WebSocket, lịch sử lưu local) — chờ chốt
4. ⬜ UI Flutter: sảnh, phòng chờ, bàn chơi (điểm cạnh tên người chơi), hạ bài, tạm dừng, bảng điểm
