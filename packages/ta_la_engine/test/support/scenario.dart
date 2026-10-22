import 'package:ta_la_engine/ta_la_engine.dart';
import 'package:test/test.dart';

/// Mức base dùng trong các ví dụ của tài liệu luật.
const settingsB5 = RoomSettings(base: 5);

/// Dựng bộ bài sao cho khi chia, ghế `i` nhận đúng [hands] `[i]` và nọc bắt
/// đầu bằng [draws]; các lá còn lại xếp sau theo thứ tự chuẩn.
List<PlayingCard> stackDeck({
  required List<String> hands,
  String draws = '',
  int firstSeat = 0,
  TurnDirection direction = TurnDirection.counterClockwise,
}) {
  final seatCount = hands.length;
  final parsed = [for (final h in hands) parseCards(h)];
  final step = direction == TurnDirection.counterClockwise ? 1 : -1;
  final deck = <PlayingCard>[];
  for (var round = 0; round < TaLaEngine.handSize; round++) {
    for (var k = 0; k < seatCount; k++) {
      deck.add(parsed[(firstSeat + step * k) % seatCount][round]);
    }
  }
  deck
    ..add(parsed[firstSeat][TaLaEngine.handSize])
    ..addAll(parseCards(draws));
  final rest = standardDeck().where((c) => !deck.contains(c));
  deck.addAll(rest);
  expect(deck.toSet(), hasLength(52), reason: 'bộ bài dựng bị trùng lá');
  return deck;
}

/// Chia bài từ [deck], báo lỗi test nếu chia thất bại.
GameState dealFrom(
  List<PlayingCard> deck, {
  RoomSettings settings = settingsB5,
  int firstSeat = 0,
  TurnDirection direction = TurnDirection.counterClockwise,
  int seatCount = 4,
}) => unwrap(
  TaLaEngine.deal(
    settings: settings,
    deck: deck,
    firstSeat: firstSeat,
    direction: direction,
    seatCount: seatCount,
  ),
);

/// Lấy giá trị từ [result], báo lỗi test nếu là [Err].
GameState unwrap(GameResult result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Thao tác bị từ chối: $failure'),
};

/// Lý do từ chối của [result], báo lỗi test nếu thao tác thành công.
RuleViolation violation(GameResult result) => switch (result) {
  Ok() => fail('Mong đợi bị từ chối nhưng thao tác thành công'),
  Err(:final failure) => failure,
};

/// Áp lần lượt [actions] lên [state].
GameState play(GameState state, List<GameAction> actions) =>
    actions.fold(state, (s, a) => unwrap(TaLaEngine.apply(s, a)));

/// Một lá bài từ mã.
PlayingCard card(String code) => PlayingCard.parse(code);

/// Ghế [seat] bốc rồi đánh ngay lá vừa bốc.
GameState drawToss(GameState state, int seat) {
  final drawn = state.deck.first;
  return play(state, [DrawCard(seat), DiscardCard(seat, drawn)]);
}

/// Tổng số lá ở mọi nơi (tay, hàng đánh, phỏm trên bàn, nọc).
int cardsInPlay(GameState state) =>
    state.deck.length +
    state.hands.fold<int>(0, (n, h) => n + h.length) +
    state.discards.fold<int>(0, (n, d) => n + d.length) +
    state.tableMelds.fold<int>(0, (n, m) => n + m.meld.cards.length);
