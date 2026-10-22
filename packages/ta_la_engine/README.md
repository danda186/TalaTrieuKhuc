# ta_la_engine

Luật chơi Tá lả (Phỏm) viết bằng Dart thuần, không phụ thuộc Flutter, để dùng
chung cho app và server trọng tài. Đặc tả luật:
[`docs/luat-choi-ta-la.md`](../../docs/luat-choi-ta-la.md).

## Có gì

| Phần | File | Nội dung |
|---|---|---|
| Lá bài | `lib/src/cards/` | `PlayingCard`, `Suit`, bộ 52 lá, xáo bài với `Random` truyền vào |
| Phỏm, cạ | `lib/src/melds/meld.dart` | `Meld.tryCreate` (bộ / sảnh, A nhỏ nhất), `isPair` (cạ), `hasNoPair` (khan) |
| Xếp phỏm | `lib/src/melds/arrangement.dart` | Tìm cách xếp giảm nhiều điểm nhất, ràng buộc lá ăn, `canEat` |
| Hạ bài | `lib/src/melds/lay_down_planner.dart` | Gợi ý hạ + gửi bài (cả gửi nối tiếp), chọn lá đánh, ưu tiên không Móm, ưu tiên Ù tròn |
| Nút Xếp bài | `lib/src/melds/hand_sorter.dart` | Rác → cạ → phỏm, tăng dần trái → phải, kèm vai trò từng lá |
| Ván | `lib/src/game/` | `TaLaEngine.deal` / `apply`: lượt, ăn/bốc, chuyển bài, hạ, gửi, Ù, Ù khan, đền |
| Hết giờ lượt | `lib/src/game/auto_play.dart` | `autoAction`: thao tác tự động khi người chơi hết giờ |
| Điểm | `lib/src/scoring/` | Mức base B, bảng điểm ván (`ScoreEntry`, tổng luôn 0), bảng điểm phòng |
| Tạm dừng | `lib/src/match/pause_clock.dart` | Quỹ 10 phút cả trận, người khác chờ 1 phút |

Mọi hàm đều thuần: không đọc đồng hồ, không tự sinh ngẫu nhiên. Server truyền
bộ bài đã xáo và giờ server vào, nên một ván luôn tái lập được từ bộ bài và
chuỗi thao tác.

## Dùng thử

```dart
import 'dart:math';

import 'package:ta_la_engine/ta_la_engine.dart';

void main() {
  final dealt = TaLaEngine.deal(
    settings: const RoomSettings(base: 5),
    deck: shuffledDeck(Random.secure()),
    firstSeat: 0,
  );
  if (dealt case Ok(value: final state)) {
    final action = autoAction(state)!; // người đi đầu đánh 1 lá
    print(TaLaEngine.apply(state, action));
  }
}
```

## Kiểm tra

```bash
dart pub get
dart format --set-exit-if-changed .
dart analyze --fatal-infos
dart test
```

`test/simulation_test.dart` chơi 3000 ván ngẫu nhiên và kiểm tra sau mỗi thao
tác: đủ 52 lá, hàng bài đánh chênh nhau tối đa 1 lá, lá ăn không bị mất,
mọi ván đều kết thúc và tổng điểm luôn bằng 0.
