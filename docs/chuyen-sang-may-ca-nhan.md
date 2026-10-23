# Chuyển dự án sang máy cá nhân

Mục tiêu: một thư mục lớn chứa 4 phần, trong đó **BE** và **Mobile** là 2 repo GitHub riêng (CI/CD
và deploy riêng), **Documents** và **Designs** không dùng git.

```
TalaTrieuKhuc/
  BE/          -> github.com/danda186/talatrieukhuc-be      (private)
  Mobile/      -> github.com/danda186/talatrieukhuc-mobile  (private)
  Documents/   (không git)
  Designs/     (không git)
```

## Bước 1 — Mở một phiên Claude trên máy của bạn

Chọn một trong hai cách:

- **Claude Desktop**: mở app, chọn thư mục làm việc (VD thư mục home), bắt đầu phiên Claude Code.
- **Terminal**: `cd` tới thư mục muốn đặt dự án rồi chạy `claude remote-control`; phiên đó hiện
  trong app Claude Code để bạn điều khiển.

## Bước 2 — Dán yêu cầu sau vào phiên mới

> Clone repo `danda186/TalaTrieuKhuc` (nhánh `claude/brave-johnson-213i0m`) vào một thư mục tạm, rồi
> chạy `bash tools/tach-du-an.sh ~/TalaTrieuKhuc` để dựng 4 thư mục BE, Mobile, Documents, Designs.
> Sau đó:
>
> 1. Trong `~/TalaTrieuKhuc/BE`: khởi tạo git, thêm README, `.gitignore` cho Dart, pub workspace
>    cho `packages/`, workflow GitHub Actions chạy `dart format --set-exit-if-changed`,
>    `dart analyze --fatal-infos`, `dart test` cho `packages/ta_la_engine`. Tạo repo **private**
>    `danda186/talatrieukhuc-be` và đẩy lên.
> 2. Trong `~/TalaTrieuKhuc/Mobile`: tạo app Flutter (Android + iOS, khổ ngang), dùng
>    `ta_la_engine` qua git dependency trỏ tới repo BE (`path: packages/ta_la_engine`, ghim theo
>    tag). Thêm workflow GitHub Actions: analyze + test + build APK. Hướng dẫn mình tạo token đọc
>    repo BE cho CI vì cả hai repo đều private. Tạo repo **private**
>    `danda186/talatrieukhuc-mobile` và đẩy lên.
> 3. Documents và Designs giữ nguyên, không khởi tạo git.
>
> Tài liệu cần đọc trước: `Documents/luat-choi-ta-la.md`, `Documents/kien-truc-online.md`,
> `Designs/README.md`.

## Ghi chú

- Máy cần có: **git**, **GitHub CLI (`gh`)** đã đăng nhập, **Dart SDK** (hoặc Flutter SDK, đã kèm
  Dart). Phiên Claude trên máy sẽ kiểm tra và hướng dẫn cài nếu thiếu.
- `ta_la_engine` là code dùng chung: nằm trong repo **BE**, app Mobile tải về qua git dependency.
  Khi sửa luật thì sửa ở BE, gắn tag mới, rồi nâng tag trong Mobile.
- Repo hiện tại `danda186/TalaTrieuKhuc` giữ nguyên làm lưu trữ lịch sử.
