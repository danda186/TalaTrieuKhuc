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
- Khi hạ, người chơi được **gửi** lá rác của mình vào **phỏm đã hạ của người hạ trước**
  để giảm điểm (VD: người trước hạ `5♥ 6♥ 7♥`, mình gửi `8♥`; hoặc gửi `7♣` vào bộ `7♠ 7♥ 7♦`).
- Người hạ **đầu tiên** không có phỏm nào để gửi.
- Lá đã gửi coi như hết, không tính điểm.
- **[Biến thể]** có nơi chỉ cho gửi vào phỏm của người hạ **ngay trước**; có nơi cho gửi
  vào cả phỏm của chính mình đã hạ.

### 5.3 Móm (cháy)
Người hạ mà **không có phỏm nào** → **Móm**. Người móm luôn xếp **cuối** bất kể điểm.

---

## 6. Ù

**Ù** = toàn bộ bài trên tay xếp được thành phỏm, kết thúc ván ngay, người Ù thắng.
Có thể Ù **bất cứ lúc nào đến lượt** (sau khi bốc hoặc ăn), không cần chờ vòng 4.

| Loại | Điều kiện (luật chuẩn của app) |
|---|---|
| **Ù thường** | Sau khi bốc/ăn có 10 lá: 9 lá thành phỏm, đánh lá còn lại ra (0 điểm rác). |
| **Ù tròn** | Cả **10 lá** đều thành phỏm (không còn lá nào để đánh). |
| **Ù khan** | Ngay sau khi chia, trên tay **không có cạ nào và không có phỏm nào** (mọi cặp lá đều không thể ghép phỏm). Báo Ù khan trước lượt đầu. **[Biến thể]** nhiều nơi không chơi Ù khan. |
| **Ù đền** | Người Ù nhờ **ăn đủ 3 lá của cùng một người**, hoặc nhờ **ăn chốt** của một người → người bị ăn đó phải **đền làng** (trả thay phần của cả bàn). |

- **[Biến thể]** "Ù gửi": tính Ù nếu sau khi gửi bài không còn rác. Mặc định app **không** tính.
- Khi một người Ù, những người khác **không hạ**, không xếp hạng; chỉ trả điểm Ù.

---

## 7. Tính điểm và xếp hạng

### 7.1 Kết thúc ván bình thường (không ai Ù)
Sau khi người cuối cùng hạ và đánh lá chốt:

1. Mỗi người tính **tổng điểm rác** (theo bảng giá trị mục 1).
2. Xếp hạng **từ thấp đến cao**: **Nhất → Nhì → Ba → Bét**.
3. Người **Móm** xếp sau tất cả người có phỏm. Nhiều người móm → cùng bậc Móm.
4. **Bằng điểm:** người **hạ trước** xếp trên. **[Biến thể]**

### 7.2 Bảng điểm đề xuất (đơn vị = 1 "mức cược", app quy ra điểm)

| Tình huống | Ai trả | Trả cho ai | Mức |
|---|---|---|---|
| Về Nhì | Nhì | Nhất | 1 |
| Về Ba | Ba | Nhất | 2 |
| Về Bét | Bét | Nhất | 3 |
| Móm | Người móm | Nhất | 4 |
| Bị ăn lá thường (vòng 1–3) | Người bị ăn | Người ăn | 1 / lá |
| Bị ăn chốt (vòng 4) | Người bị ăn | Người ăn | 4 / lá |
| Ù (thường / tròn / khan) | Mỗi người còn lại | Người Ù | 5 |
| Ù đền | Người đền (trả thay cả làng) | Người Ù | 5 × 3 = 15 |

Ghi chú:
- Điểm ăn bài được tính **ngay khi ăn** và vẫn giữ nguyên dù ván kết thúc thế nào.
- Ù đền: hai người còn lại **không mất gì**.
- **[Biến thể]** Ù tròn / Ù khan nhiều nơi tính gấp đôi (10); ăn lá thứ 1/2/3 tăng dần
  (1/2/3); ăn chốt 2 hoặc 4. → Đưa các con số này vào **cấu hình phòng**.
- Tổng điểm mỗi ván luôn bằng 0 (zero-sum) → dễ kiểm tra lỗi.

---

## 8. Ví dụ một ván rút gọn

Ghế: **A** (đi đầu, 10 lá) → **B** → **C** → **D**.

1. Vòng 1: A đánh `8♣`. B có `8♠ 8♦` → **ăn** `8♣`, bày ra, rồi đánh `K♥`. **B thu 1 điểm từ A**.
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
- **Cấu hình phòng** nên chứa toàn bộ các mục [Biến thể] ở mục 10 để sau này linh hoạt.

---

## 10. Các điểm cần nhóm chốt (biến thể)

| # | Câu hỏi | Mặc định đề xuất |
|---|---|---|
| 1 | Chiều đánh | Ngược chiều kim đồng hồ |
| 2 | Có chơi **Ù khan** không? | Có |
| 3 | Ù tròn / Ù khan có tính gấp đôi? | Không (đều 5) |
| 4 | Mức tiền ăn lá thường / ăn chốt | 1 / 4 |
| 5 | Mức Nhì / Ba / Bét / Móm | 1 / 2 / 3 / 4 |
| 6 | Bằng điểm thì ai xếp trên | Người hạ trước |
| 7 | Gửi bài vào phỏm của ai | Mọi người đã hạ trước mình |
| 8 | Có tính "Ù gửi" | Không |
| 9 | Bị ăn 3 lá (không dẫn tới Ù) có phải đền không | Không |
| 10 | Phỏm có lá ăn có phải bày cả phỏm ngay khi ăn | Chỉ bày lá ăn |
| 11 | Thời gian mỗi lượt | 25 giây |

---

*Nguồn tham khảo (đối chiếu, các nguồn không hoàn toàn thống nhất):*
[thuthuatchoi.com](https://thuthuatchoi.com/huong-dan-cach-choi-ta-la-phom.html),
[gamebai.ad](https://gamebai.ad/luat-choi-phom/),
[chanthapthanh.com](https://m.chanthapthanh.com/ho-tro/12-ta-la-phom),
[52labai.com](https://m.52labai.com/game/huong_dan/1-ta-la-phom),
[uwaims.org – thuật ngữ Phỏm](https://www.uwaims.org/tong-hop-nhung-thuat-ngu-trong-phom/),
[hoatieu.vn](https://hoatieu.vn/phap-luat/phom-la-gi-ha-phom-la-gi-218777).
