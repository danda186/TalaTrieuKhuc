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
4. **Chiều chia và đánh:** người đi đầu ván (người **Nhất**/**Ù** ván trước) được **chọn chiều**
   cho ván đó: **thuận** hoặc **ngược** chiều kim đồng hồ. Chiều đã chọn áp dụng cho cả chia bài
   và thứ tự lượt trong suốt ván.
   - Ván đầu tiên: chủ phòng chọn (mặc định ngược chiều kim đồng hồ).
   - "Người ngồi trước" (người mình được ăn bài) và thứ tự hạ bài đều tính theo chiều đã chọn.

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
- **Ăn chốt ở vòng 4:** người đánh đầu vòng 4 có thể **đã hạ bài**. Khi bị chuyển mất 1 lá,
  nhà đó **được quay lại đánh tiếp** thêm 1 lượt: bốc (hoặc ăn nếu hợp lệ), được hạ thêm
  phỏm / gửi bài, rồi đánh 1 lá. Nếu nhà đó **Ù** ở lượt này → **người ăn chốt đền làng** (mục 6).

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
- Nếu sau khi hạ + gửi + đánh lá cuối mà **không còn lá rác** → **Ù gửi** (mục 6).
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
| **Ù gửi** | Khi hạ bài: hạ phỏm của mình, **gửi** các lá còn lại vào phỏm nhà đã hạ trước, đánh lá cuối mà **không còn lá rác**. Áp dụng cả với lượt quay lại của nhà đã hạ (mục 4.4). |
| **Ù khan** | Ngay sau khi chia, **9 lá** trên tay **không có cạ nào** (không có 2 lá nào có cơ hội ghép thành phỏm). Báo ngay, trước lượt đầu. |
| **Ù khan tròn** | Ngay sau khi chia, **10 lá** trên tay **không có cạ nào** (người đi đầu). |
| **Ù đền** | (a) Ù do **ăn cây thứ 3** → người **đánh ra** cây thứ 3 đó phải **đền làng** (trả thay phần của cả 3 nhà). Áp dụng cả khi tắt điểm ăn cây thường. <br>(b) Một người **ăn chốt** khiến nhà đã hạ bài được quay lại đánh tiếp (mục 4.4), và nhà đó **Ù** → **người ăn chốt** đền làng (không phải người mất chốt). |

- **Kiểm tra "không có cạ":** với mọi cặp lá `x, y` trên tay: không cùng số, và nếu cùng chất
  thì chênh lệch giá trị > 2. Chỉ cần 1 cặp vi phạm là không khan.
- **Ăn cây thứ 3 luôn dẫn tới Ù:** mỗi phỏm chỉ chứa 1 lá ăn, nên 3 lá ăn = 3 phỏm ≥ 9 lá
  trên tay 10 lá → còn tối đa 1 lá để đánh.
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
| Móm | Người móm | Nhất | −4B | −20 | −40 |
| **Nhất** | | | **+ tổng các nhà trả** (bình thường 1B+2B+3B = **+6B**) | +30 | +60 |
| Ăn cây chốt (luôn tính, kể cả là cây thứ 2/3) | Người mất chốt | Người ăn | ±4B | ±20 | ±40 |
| Ăn cây thường thứ 1 *(nếu bật)* | Người bị ăn | Người ăn | ±1B | ±5 | ±10 |
| Ăn cây thường thứ 2 *(nếu bật)* | Người bị ăn | Người ăn | ±2B | ±10 | ±20 |
| Ăn cây thường thứ 3 *(nếu bật)* | Người bị ăn | Người ăn | ±3B | ±15 | ±30 |
| Ù thường | Mỗi nhà | Người Ù | −5B / nhà (Ù +15B) | −25 / +75 | −50 / +150 |
| Ù tròn | Mỗi nhà | Người Ù | −10B / nhà (Ù +30B) | −50 / +150 | −100 / +300 |
| Ù gửi | Mỗi nhà | Người Ù | −5B / nhà | −25 | −50 |
| Ù khan | Mỗi nhà | Người Ù | −5B / nhà | −25 | −50 |
| Ù khan tròn (chỉ người đi đầu) | Mỗi nhà | Người Ù | −10B / nhà | −50 | −100 |
| Ù đền | Người đền (trả cả 3 phần) | Người Ù | 3 × mức Ù tương ứng | −75 (Ù thường) | −150 |

Ghi chú:
- "Cây thứ k" là thứ tự lá ăn **của người ăn** trong ván (lá ăn đầu tiên, thứ hai, thứ ba),
  tính cả cây chốt khi đếm thứ tự.
- Cây chốt **luôn là 4B**, không tính theo kB, kể cả khi nó là cây thứ 3.
- Tắt điểm ăn cây thường: không cộng/trừ 1B/2B/3B, nhưng **Ù đền vẫn áp dụng**.
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

**Ván Ù đền:** D ăn 3 cây thường của C (vòng 1, 2, 3 — D chỉ ăn được của nhà ngồi trước là C)
→ Ù ở cây thứ 3. C đền.

| | A | B | C | D |
|---|---|---|---|---|
| Ăn cây (5 + 10 + 15) | | | −30 | +30 |
| Ù đền (3 × 25) | | | −75 | +75 |
| **Cộng ván** | **0** | **0** | **−105** | **+105** |

Nếu **tắt** điểm ăn cây thường: C −75, D +75.

**Ván Ù đền do ăn chốt:** A đánh đầu vòng 4, đã hạ. C đánh cây chốt, D ăn chốt
→ chuyển bài, A được quay lại đánh tiếp và Ù thường. D đền.

| | A | B | C | D |
|---|---|---|---|---|
| Ăn chốt | | | −20 | +20 |
| Ù đền (3 × 25) | +75 | | | −75 |
| **Cộng ván** | **+75** | **0** | **−20** | **−55** |

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
- **Hết giờ lượt:** tự động bốc + đánh lá rác điểm cao nhất; khi hạ tự xếp phỏm tối ưu.
- **Tạm dừng (pause):** đồng hồ do **server** giữ (thời điểm pause, người pause, quỹ pause còn lại)
  để mọi client hiển thị giống nhau, không phụ thuộc giờ máy. Xem mục 11.
- **Cấu hình phòng:** `base`, `tinhDiemAnCayThuong`, thời gian lượt, cùng các mục còn mở ở mục 10.
- **Bảng điểm:** lưu từng khoản (ăn cây, chốt, xếp hạng, Ù) theo ván để hiển thị lịch sử và kiểm tra tổng = 0.
- **Lịch sử trận:** khi phòng đóng (chủ động hoặc hết quỹ pause), lưu bảng điểm cuối cùng,
  danh sách ván và lý do kết thúc vào lịch sử để người chơi xem lại.

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
| 6 | Nhất | Nhận **tổng các nhà trả** (bình thường +6B: 30 khi B=5, 60 khi B=10) |
| 7 | Móm | −4B |
| 8 | Ù khan / Ù khan tròn | 5B / 10B mỗi nhà; Ù khan tròn **chỉ người đi đầu** |
| 9 | Ù đền khi tắt điểm ăn cây | **Vẫn đền**, chỉ không có điểm ăn cây |
| 10 | Ù đền do ăn chốt | Ăn chốt khiến nhà đã hạ quay lại đánh và Ù → **người ăn chốt đền** |
| 11 | Cây chốt là cây thứ k | **Luôn 4B** |
| 12 | Chiều chia/đánh | Người đi đầu ván (Nhất/Ù ván trước) **chọn** thuận hoặc ngược chiều kim đồng hồ |
| 13 | Ù gửi | **Có tính** |
| 14 | Tạm dừng ván | Có, theo mục 11 |
| 15 | Lượt quay lại của nhà đã hạ | Bốc/ăn, hạ thêm phỏm + gửi bài, đánh 1 lá; **không còn lá rác** → Ù |
| 16 | Ù gửi | Như Ù thường: **5B mỗi nhà** |
| 17 | Thời gian mỗi lượt | 25 giây (cấu hình được) |
| 18 | Quỹ pause 10 phút | Tính cho **cả trận**; hết quỹ → **đóng phòng**, lưu bảng điểm vào **lịch sử** |
| 19 | Hết quỹ pause giữa ván | Giữ các khoản ăn cây/chốt đã phát sinh, không xếp hạng ván dở |
| 20 | Ai được pause | Bất kỳ người chơi nào, lúc nào cũng được, không giới hạn số lần (chỉ giới hạn tổng thời gian) |

Tất cả các điểm luật đã được chốt.

---

## 11. Tạm dừng ván (pause)

1. **Ai được pause:** bất kỳ người chơi nào trong phòng, vào bất cứ lúc nào trong ván
   (kể cả không phải lượt của mình). Khi ván đang pause thì không pause chồng được.
2. **Khi pause:**
   - Đồng hồ lượt **dừng lại**, giữ nguyên số giây còn lại; không ai thao tác được bài.
   - **Thông báo** cho tất cả người chơi: ván đang tạm dừng, ai pause, thời gian pause đã trôi
     và **quỹ pause còn lại**.
3. **Bỏ pause (unpause):**
   - **Người pause** được unpause **ngay lập tức**, bất cứ lúc nào.
   - **Người khác** chỉ được unpause sau khi đã pause **≥ 1 phút**.
   - Unpause → đồng hồ lượt chạy tiếp từ số giây còn lại, thông báo cho mọi người.
4. **Quỹ pause: tổng 10 phút cho cả trận** (cộng dồn mọi lần pause qua tất cả các ván
   trong phòng, không reset sau mỗi ván).
   - Khi tổng thời gian pause **vượt 10 phút** → **kết thúc ngay lập tức**:
     ván đang chơi dừng lại, **bảng xếp hạng phòng tại thời điểm đó là kết quả cuối cùng**,
     **phòng bị đóng** và bảng điểm được **lưu vào lịch sử**.
   - Ván dở: không tính xếp hạng Nhất/Nhì/Ba/Bét; các khoản ăn cây/chốt đã ghi **giữ nguyên**
     (mỗi khoản đều cân bằng nên tổng điểm vẫn = 0).

| Trạng thái | Người pause | Người khác |
|---|---|---|
| Pause < 1 phút | Unpause được | Chờ |
| Pause ≥ 1 phút | Unpause được | Unpause được |
| Tổng pause cả trận > 10 phút | — | — → **kết thúc trận**, đóng phòng, lưu bảng điểm vào lịch sử |

---

## 12. Yêu cầu giao diện bàn chơi

1. **Nút "Xếp bài":** tự sắp bài trên tay theo thứ tự **tăng dần từ trái qua phải**, gom nhóm
   theo thứ tự **rác → cạ → phỏm** (phỏm nằm bên phải). Cách xếp phỏm dùng cách giảm được
   **nhiều điểm nhất** (mục 5.1).
   - Người chơi **kéo thả** đổi vị trí lá bài tuỳ ý; thứ tự lá trên tay chỉ là hiển thị phía
     client, không ảnh hưởng luật.
2. **Gợi ý hạ bài:** khi hạ, app đề xuất cách xếp phỏm + gửi bài giảm được nhiều điểm nhất
   (ưu tiên không bị Móm), người chơi vẫn có thể chỉnh lại.
3. **Đầu lượt:** hiển thị 2 nút **Ăn** (chỉ bật khi lá vừa đánh ăn được) và **Bốc**.
4. **Ù:**
   - Khi đủ điều kiện Ù (kể cả Ù khan / Ù khan tròn ngay sau chia), hiện nút
     **"Hạ bài báo Ù"**; người chơi bấm thì app tự hạ theo cách tối ưu và kết thúc ván.
   - Trường hợp **đền** (ăn cây thứ 3; ăn chốt khiến nhà đã hạ quay lại và Ù) thì
     **tự động kết thúc ván và tính điểm ngay**, không cần bấm.

---

*Nguồn tham khảo (đối chiếu, các nguồn không hoàn toàn thống nhất):*
[thuthuatchoi.com](https://thuthuatchoi.com/huong-dan-cach-choi-ta-la-phom.html),
[gamebai.ad](https://gamebai.ad/luat-choi-phom/),
[chanthapthanh.com](https://m.chanthapthanh.com/ho-tro/12-ta-la-phom),
[52labai.com](https://m.52labai.com/game/huong_dan/1-ta-la-phom),
[uwaims.org – thuật ngữ Phỏm](https://www.uwaims.org/tong-hop-nhung-thuat-ngu-trong-phom/),
[hoatieu.vn](https://hoatieu.vn/phap-luat/phom-la-gi-ha-phom-la-gi-218777).
