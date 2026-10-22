# Tá Lả Triều Khúc

Mobile app (Flutter) cho phép **4 người chơi kết nối cùng một phòng** để chơi Tá lả (Phỏm) và tự động tính điểm.

## Tài liệu

- [Luật chơi Tá lả — đặc tả cho app](docs/luat-choi-ta-la.md)
- [Package luật chơi `ta_la_engine`](packages/ta_la_engine/README.md)

## Lộ trình

1. ✅ Tìm hiểu & chốt luật chơi
2. ✅ Engine luật (Dart thuần, có unit test + mô phỏng 3000 ván): `packages/ta_la_engine`
3. ⬜ Chọn kiến trúc online (server trọng tài, phòng 4 người)
4. ⬜ UI Flutter: sảnh, phòng chờ, bàn chơi, hạ bài, tạm dừng, kết quả, bảng điểm
