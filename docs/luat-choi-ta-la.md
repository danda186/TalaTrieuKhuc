# Luật chơi Tá lả (Phỏm) — Đặc tả cho app

> Tài liệu này là **đặc tả luật** làm nền cho app Flutter 4 người chơi online.
> Tá lả có rất nhiều biến thể theo vùng/nhóm chơi. Phần **luật chuẩn** bên dưới là
> cách chơi phổ biến nhất; những chỗ hay khác nhau được đánh dấu **[Biến thể]** và
> gom lại ở mục 10 để nhóm chốt trước khi code.

---

## 1. Tổng quan

| Mục | Giá trị |
|---|---|
| Tên gọi | Tá lả (miền Nam), Phỏm (miền Bắc), còn gọi là bài Ù |
| Bộ bài | 52 lá tiêu chuẩn, **không** dùng Joker |
| Số người | 2–4 (app nhắm tới **4 người**) |
| Mục tiêu | Xếp bài thành các **phỏm**, sao cho tổng điểm bài lẻ (**rác**) còn lại trên tay là **thấp nhất**; hoặc **Ù** (toàn bộ bài thành phỏm) |

### Giá trị lá bài

| Lá | A | 2 … 10 | J | Q | K |
|---|---|---|---|---|---|
| Điểm | 1 | bằng số trên lá | 11 | 12 | 13 |

- A luôn là lá **nhỏ nhất**, không vòng: `A-2-3` hợp lệ, `Q-K-A` **không** hợp lệ.
- Chất (♠ ♣ ♦ ♥) không có thứ tự mạnh/yếu, chỉ dùng để xét sảnh.

---

## 2. Phỏm (bộ bài hợp lệ)

Một **phỏm** gồm **từ 3 lá trở lên** thuộc một trong hai dạng:

1. **Bộ cùng số (sám/tứ):** 3 hoặc 4 lá cùng giá trị, khác chất.
   Ví dụ: `7♠ 7♥ 7♦`, `K♠ K♣ K♦ K♥`.
2. **Sảnh (dây):** từ 3 lá trở lên **cùng chất**, giá trị **liên tiếp**.
   Ví dụ: `4♥ 5♥ 6♥`, `9♣ 10♣ J♣ Q♣`.

Thuật ngữ liên quan:

- **Cạ:** 2 lá có thể thành phỏm nếu thêm 1 lá (cùng số, hoặc cùng chất cách nhau ≤ 2 bậc như `5♥ 6♥`, `5♥ 7♥`).
- **Rác:** lá không thuộc phỏm nào.
- Mỗi lá chỉ thuộc **một** phỏm tại một thời điểm.

---

## 3. Chuẩn bị ván

1. **Chọn người đi đầu:**
   - Ván đầu tiên: ngẫu nhiên (hoặc chủ phòng).
   - Các ván sau: người **Nhất** (hoặc người **Ù**) ván trước đi đầu.
2. **Chia bài:** người đi đầu nhận **10 lá**, mỗi người còn lại **9 lá**.
3. Phần còn lại úp thành **nọc** (chồng bài để bốc).
   - 4 người: 52 − (10 + 9×3) = **15 lá** trong nọc.
4. **Chiều đánh:** ngược chiều kim đồng hồ (truyền thống). **[Biến thể]** nhiều app dùng chiều kim đồng hồ — app chỉ cần cố định thứ tự ghế.

---

## 4. Diễn biến một ván

Ván gồm **4 vòng**. Mỗi người chơi đánh ra đúng **4 lá** trong cả ván (mỗi vòng 1 lá),
đánh ra thành một hàng trước mặt mình (gọi là **bài đánh**/**chiếu**).

### 4.1 Lượt đầu tiên
Người đi đầu (đang có 10 lá) **đánh ngay 1 lá**, không bốc.

### 4.2 Một lượt thông thường
Đến lượt, người chơi làm **một trong hai**:

- **Ăn** lá vừa được người ngồi trước đánh ra (xem 4.3), **hoặc**
- **Bốc** 1 lá từ nọc.

Sau đó (nếu không Ù) **đánh ra 1 lá**. Số lá trên tay sau mỗi lượt luôn là 9.

### 4.3 Điều kiện ăn bài
Chỉ được ăn **lá vừa đánh ra bởi người ngồi ngay trước** mình, và:

1. Lá đó phải **tạo thành phỏm ngay** với ít nhất 2 lá trên tay.
2. Lá ăn được **bày ngửa** trước mặt người ăn cùng phỏm của nó (các lá trên tay tạo phỏm với lá ăn vẫn có thể giữ kín cho tới lúc hạ — **[Biến thể]** một số nơi bắt bày cả phỏm).
3. **Mỗi phỏm chỉ chứa tối đa 1 lá ăn** — không được ăn 2 lá vào cùng một phỏm.
4. Sau khi ăn, **tất cả lá đã ăn phải cùng lúc nằm trong các phỏm khác nhau** (không dùng chung lá trên tay). Nếu ăn lá mới làm phá phỏm của lá ăn cũ → **không được ăn**.
5. **Không được đánh ra** lá thuộc phỏm chứa lá đã ăn (phỏm ăn bị "khoá").
6. Ăn thay cho bốc: người ăn **không bốc** ở lượt đó.

### 4.4 Chuyển bài (khi có người bị ăn)
Khi lá của người **V** bị ăn, hàng bài đánh của V bị hụt 1 lá. Để mọi người vẫn đánh
đủ 4 lá và thứ tự hạ bài liền mạch, người ta **chuyển bài**:

- Nếu có người đã đánh **nhiều lá hơn** V trong vòng hiện tại (tức người đánh đầu vòng
  và những người đánh trước V), thì **lá đánh gần nhất của người đánh đầu vòng** (thực tế
  thường chuyển dồn từ người ngồi trước V) được chuyển sang hàng bài của V.
- Hệ quả: người đánh đầu vòng bị lùi 1 lá → **người kế tiếp trở thành người đánh đầu vòng**
  và cũng là người sẽ **hạ đầu tiên**. Người mất lá sẽ phải đánh thêm 1 lượt (dùng lá
  thừa trong nọc do người ăn không bốc).
- Nếu V chính là người đánh đầu vòng thì không cần chuyển.

> **Cách cài đặt đơn giản:** engine chỉ cần theo dõi `soLaDaDanh[player]`. Bất biến cần giữ:
> đi theo thứ tự lượt bắt đầu từ người đánh đầu vòng, số lá đã đánh **không tăng** và các
> người chênh nhau tối đa 1. Khi bị ăn làm vỡ bất biến → chuyển 1 lá từ người đánh đầu vòng
> sang V. Người **hạ** là người đến lượt khi đã đánh đủ 3 lá.

### 4.5 Ăn chốt
**Cây chốt** là lá đánh ra ở **vòng thứ 4** (lá cuối cùng của một người). Ăn được cây
chốt gọi là **ăn chốt** — có giá trị cao hơn ăn thường (xem mục 7).

---

## 5. Hạ phỏm và gửi bài

### 5.1 Hạ phỏm
Ở lượt cuối của mình (đã đánh đủ 3 lá, vừa bốc/ăn xong, đang có 10 lá):

1. **Hạ** (bày ngửa) tất cả phỏm của mình. Mọi phỏm có lá ăn **bắt buộc** phải hạ.
2. **Gửi bài** (nếu được — xem 5.2).
3. **Đánh lá cuối cùng** (lá thứ 4) ra.
4. Các lá còn lại trên tay là **rác**, cộng điểm.

- Người hạ đầu tiên là người đánh đầu vòng 4; thứ tự hạ theo thứ tự lượt.
- Người chơi được **tự chọn cách xếp phỏm** khi hạ. App nên **gợi ý cách xếp tối ưu**
  (ít điểm rác nhất), nhưng vẫn cho người chơi chọn (có chiến thuật giữ lá để gửi).

### 5.2 Gửi bài
- Khi hạ, người chơi được **gửi** lá rác của mình vào phỏm của **tất cả các nhà đã hạ trước mình**
  để giảm điểm (VD: người trước hạ `5♥ 6♥ 7♥`, mình gửi `8♥`; hoặc gửi `7♣` vào bộ `7♠ 7♥ 7♦`).
- Người hạ **đầu tiên** không có phỏm nào để gửi.
- Lá đã gửi coi như hết, không tính điểm.
- Được gửi nhiều lá, vào nhiều phỏm của nhiều nhà khác nhau.

### 5.3 Móm (cháy)
Người hạ mà **không có phỏm nào** → **Móm**. Người móm luôn xếp **cuối** bất kể điểm.

---

## 6. Ù

**Ù** = toàn bộ bài trên tay xếp được thành phỏm, kết thúc ván ngay, người Ù thắng.
Có thể Ù **bất cứ lúc nào đến lượt** (sau khi bốc hoặc ăn), không cần chờ vòng 4.

| Loại | Điều kiện |
|---|---|
| **Ù thường** | Sau khi bốc/ăn có 10 lá: 9 lá thành phỏm, đánh lá còn lại ra (0 điểm rác). |
| **Ù tròn** | Cả **10 lá** đều thành phỏm (không còn lá nào để đánh). |
| **Ù khan** | Ngay sau khi chia, **9 lá** trên tay **không có cạ nào** (không có 2 lá nào có cơ hội ghép thành phỏm). Báo ngay, trước lượt đầu. |
| **Ù khan tròn** | Ngay sau khi chia, **10 lá** trên tay **không có cạ nào** (người đi đầu). |
| **Ù đền** | Ù do **ăn cây thứ 3** → người đánh ra cây thứ 3 đó phải **đền làng** (trả thay phần của cả 3 nhà). Ù do **ăn cây chốt** → người mất chốt đền. |

- **Kiểm tra "không có cạ":** với mọi cặp lá `x, y` trên tay: không cùng số, và nếu cùng chất
  thì chênh lệch giá trị > 2. Chỉ cần 1 cặp vi phạm là không khan.
- **Ăn cây thứ 3 luôn dẫn tới Ù:** mỗi phỏm chỉ chứa 1 lá ăn, nên 3 lá ăn = 3 phỏm ≥ 9 lá
  trên tay 10 lá → còn tối đa 1 lá để đánh.
- **[Biến thể]** "Ù gửi": tính Ù nếu sau khi gửi bài không còn rác. Mặc định app **không** tính.
- Khi một người Ù, những người khác **không hạ**, không xếp hạng; chỉ trả điểm Ù.
  Các khoản ăn cây đã phát sinh trước đó **vẫn giữ nguyên**.

---

## 7. Tính điểm

### 7.1 Mức base (B)
Khi tạo phòng, chủ phòng chọn:

- **Mức base `B`** (VD: 5, 10, 20…). Mọi khoản điểm là **bội số của B**.
- **Tính điểm ăn cây thường**: Bật / Tắt.

### 7.2 Xếp hạng trong ván (khi không ai Ù)
Sau khi người cuối cùng hạ và đánh lá chốt:

1. Mỗi người tính **tổng điểm rác** (theo bảng giá trị mục 1).
2. Xếp hạng **từ thấp đến cao**: **Nhất → Nhì → Ba → Bét**.
3. Người **Móm** xếp sau tất cả người có phỏm. Nhiều người móm → cùng bậc Móm.
4. **Bằng điểm rác:** người **hạ trước** xếp trên.

### 7.3 Bảng điểm theo base

| Khoản | Ai trừ | Ai cộng | Hệ số | B = 5 | B = 10 |
|---|---|---|---|---|---|
| Về Nhì | Nhì | Nhất | −1B | −5 | −10 |
| Về Ba | Ba | Nhất | −2B | −10 | −20 |
| Về Bét | Bét | Nhất | −3B | −15 | −30 |
| Móm *(cần chốt)* | Người móm | Nhất | −4B | −20 | −40 |
| **Nhất** | | | **+ tổng các nhà trả** (bình thường 1B+2B+3B = **+6B**) | +30 | +60 |
| Ăn cây chốt (luôn tính) | Người mất chốt | Người ăn | ±4B | ±20 | ±40 |
| Ăn cây thường thứ 1 *(nếu bật)* | Người bị ăn | Người ăn | ±1B | ±5 | ±10 |
| Ăn cây thường thứ 2 *(nếu bật)* | Người bị ăn | Người ăn | ±2B | ±10 | ±20 |
| Ăn cây thường thứ 3 *(nếu bật)* | Người bị ăn | Người ăn | ±3B | ±15 | ±30 |
| Ù thường | Mỗi nhà | Người Ù | −5B / nhà (Ù +15B) | −25 / +75 | −50 / +150 |
| Ù tròn | Mỗi nhà | Người Ù | −10B / nhà (Ù +30B) | −50 / +150 | −100 / +300 |
| Ù khan *(cần chốt, tạm = Ù thường)* | Mỗi nhà | Người Ù | −5B / nhà | −25 | −50 |
| Ù khan tròn *(cần chốt, tạm = Ù tròn)* | Mỗi nhà | Người Ù | −10B / nhà | −50 | −100 |
| Ù đền | Người đền (trả cả 3 phần) | Người Ù | 3 × mức Ù tương ứng | −75 (Ù thường) | −150 |

Ghi chú:
- "Cây thứ k" là thứ tự lá ăn **của người ăn** trong ván (lá ăn đầu tiên, thứ hai, thứ ba).
- Điểm ăn cây được ghi **ngay khi ăn** và không bị huỷ dù ván kết thúc thế nào.
- Ù đền: hai nhà còn lại **không bị trừ** phần Ù.
- Tổng điểm mọi khoản trong một ván **luôn bằng 0**.

### 7.4 Ví dụ (B = 5, bật tính điểm ăn cây)

**Ván thường:** B ăn 1 cây thường của A; D ăn cây chốt của C. Kết quả: B Nhất, D Nhì, A Ba, C Bét.

| | A | B | C | D |
|---|---|---|---|---|
| Ăn cây | −5 | +5 | | |
| Ăn chốt | | | −20 | +20 |
| Xếp hạng | −10 | +30 | −15 | −5 |
| **Cộng ván** | **−15** | **+35** | **−35** | **+15** |

**Ván Ù đền:** D ăn cây thứ 1 của C, cây thứ 2 của A, cây thứ 3 của B → Ù. B đền.

| | A | B | C | D |
|---|---|---|---|---|
| Ăn cây | −10 | −15 | −5 | +30 |
| Ù đền | | −75 | | +75 |
| **Cộng ván** | **−10** | **−90** | **−5** | **+105** |

### 7.5 Bảng điểm phòng (cộng dồn nhiều ván)
- Khi vào phòng, mọi người bắt đầu từ **0 điểm**.
- Sau mỗi ván, cộng điểm ván vào tổng. **Tổng điểm của tất cả người chơi luôn = 0**
  (engine phải assert điều này sau mỗi ván).
- Bảng xếp hạng phòng sắp theo tổng điểm **giảm dần**: dương nhiều nhất đứng đầu.

---

## 8. Ví dụ một ván rút gọn

Ghế: **A** (đi đầu, 10 lá) → **B** → **C** → **D**.

1. Vòng 1: A đánh `8♣`. B có `8♠ 8♦` → **ăn** `8♣`, bày ra, rồi đánh `K♥`. Nếu bật tính điểm ăn cây: **B +1B, A −1B**.
   Hàng bài của A bị hụt, nhưng A là người đánh đầu vòng → không chuyển bài; **B thành người đánh đầu vòng**.
2. C bốc, đánh `2♠`. D bốc, đánh `Q♦`. A bốc, đánh `J♣` (lá đầu tiên còn nằm trên hàng của A).
   Mỗi người đều có 1 lá trên hàng → vòng 2 bắt đầu từ B.
3. … Đến vòng 4: B (đã đánh 3 lá) bốc → **hạ** `8♠ 8♦ 8♣` + `3♥ 4♥ 5♥`, rác `9♠ 6♣ 2♦` = 17 điểm, đánh lá chốt.
4. C hạ, gửi `6♥` vào sảnh của B, … D, rồi A hạ cuối (A đánh thêm 1 lượt vì đã bị ăn).
5. So điểm rác → xếp Nhất/Nhì/Ba/Bét, thanh toán theo bảng 7.2.

---

## 9. Ghi chú cho việc cài đặt (Flutter + online 4 người)

- **Server là trọng tài (authoritative):** xáo bài, giữ nọc, kiểm tra hợp lệ ăn/đánh/hạ/Ù
  phải chạy ở server (Cloud Functions / server Dart / Node…). Client chỉ gửi *ý định*
  (`AN`, `BOC`, `DANH(card)`, `HA(phỏm[], gửi[])`, `U`), không bao giờ nhận bài của người khác.
- **Các thuật toán cần có trong engine:**
  - `laPhomHopLe(cards)` — kiểm tra bộ/sảnh.
  - `xepPhomToiUu(hand, lockedEatenCards)` — backtracking tìm cách xếp **ít điểm rác nhất**,
    ràng buộc mỗi lá ăn nằm ở phỏm khác nhau (tay ≤ 10 lá nên vét cạn là đủ nhanh).
  - `coTheAn(hand, eatenCards, card)` — gọi lại hàm trên với ràng buộc thêm lá mới.
  - `kiemTraU(hand, eaten)`, `kiemTraUKhan(hand)` (không tồn tại cặp nào là cạ).
  - `coTheGui(card, phomDaHa)`.
  - Theo dõi `soLaDaDanh[]`, người đánh đầu vòng, logic chuyển bài (mục 4.4).
  - Ghi nhận **ai ăn của ai, vòng mấy** để tính tiền ăn, ăn chốt và Ù đền.
- **State machine ván:** `CHIA_BAI → (KIEM_TRA_U_KHAN) → LUOT[người]: CHON(ăn|bốc) → (U?) → (HA nếu vòng cuối) → DANH → … → KET_THUC → TINH_DIEM`.
- **Xử lý mất kết nối / hết giờ lượt:** cần luật timeout (VD 20–30 giây), tự động bốc +
  đánh lá rác điểm cao nhất; khi hạ tự xếp phỏm tối ưu.
- **Cấu hình phòng:** `base`, `tinhDiemAnCayThuong`, thời gian lượt, cùng các mục còn mở ở mục 10.
- **Bảng điểm:** lưu từng khoản (ăn cây, chốt, xếp hạng, Ù) theo ván để hiển thị lịch sử và kiểm tra tổng = 0.

---

## 10. Quyết định luật

### Đã chốt

| # | Nội dung | Quyết định |
|---|---|---|
| 1 | Ù khan | **Có**, gồm Ù khan (9 lá) và **Ù khan tròn** (10 lá) ngay sau chia, không có cạ nào |
| 2 | Mức điểm | Theo **base B** do phòng cài đặt (mục 7.3) |
| 3 | Điểm ăn cây thường | **Tuỳ chọn** bật/tắt; bật thì cây 1/2/3 = 1B/2B/3B |
| 4 | Gửi bài | Được gửi vào phỏm của **tất cả nhà đã hạ trước mình** |
| 5 | Tính điểm phòng | Điểm âm/dương, bắt đầu 0, **tổng luôn = 0**, xếp hạng theo tổng giảm dần |

### Còn cần xác nhận

| # | Câu hỏi | Tạm dùng |
|---|---|---|
| 1 | Ví dụ B=5 ghi "Nhất được 60", nhưng Nhì+Ba+Bét chỉ trả 5+10+15 = 30. Nhất = tổng các nhà trả (6B) đúng không? | Nhất = tổng các nhà trả |
| 2 | Móm bị trừ bao nhiêu? | −4B |
| 3 | Ù khan / Ù khan tròn tính bao nhiêu? | Như Ù thường (5B) / Ù tròn (10B) |
| 4 | Ù khan tròn chỉ áp dụng cho người đi đầu (người duy nhất có 10 lá khi chia)? | Đúng |
| 5 | Khi **tắt** điểm ăn cây thường, Ù do ăn cây thứ 3 có còn đền làng không? | Vẫn đền |
| 6 | Ù do ăn cây chốt có bị tính đền làng không? | Có |
| 7 | Cây chốt cũng là lá ăn thứ k của người ăn: chỉ tính 4B hay cộng thêm kB? | Chỉ 4B |
| 8 | Chiều đánh | Ngược chiều kim đồng hồ |
| 9 | Có tính "Ù gửi" không? | Không |
| 10 | Thời gian mỗi lượt | 25 giây |

---

*Nguồn tham khảo (đối chiếu, các nguồn không hoàn toàn thống nhất):*
[thuthuatchoi.com](https://thuthuatchoi.com/huong-dan-cach-choi-ta-la-phom.html),
[gamebai.ad](https://gamebai.ad/luat-choi-phom/),
[chanthapthanh.com](https://m.chanthapthanh.com/ho-tro/12-ta-la-phom),
[52labai.com](https://m.52labai.com/game/huong_dan/1-ta-la-phom),
[uwaims.org – thuật ngữ Phỏm](https://www.uwaims.org/tong-hop-nhung-thuat-ngu-trong-phom/),
[hoatieu.vn](https://hoatieu.vn/phap-luat/phom-la-gi-ha-phom-la-gi-218777).
