import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/game/game_action.dart';
import 'package:ta_la_engine/src/game/game_engine.dart';
import 'package:ta_la_engine/src/game/game_state.dart';
import 'package:ta_la_engine/src/melds/arrangement.dart';
import 'package:ta_la_engine/src/result.dart';

/// Thao tác tự động tiếp theo khi người chơi hết giờ lượt.
///
/// Luật hết giờ: **tự bốc** (không tự ăn; chỉ ăn khi nọc đã hết), rồi **đánh
/// 1 lá không thuộc phỏm** trên tay. Không tự báo Ù. Ở lượt hạ bài thì tự hạ
/// theo gợi ý tối ưu rồi đánh lá rác điểm cao nhất. `null` khi ván đã kết
/// thúc.
GameAction? autoAction(GameState state) {
  final seat = state.currentSeat;
  switch (state.phase) {
    case TurnPhase.ended:
      return null;
    case TurnPhase.drawOrEat:
      final canDraw = state.deck.isNotEmpty;
      if (!canDraw && TaLaEngine.canEatNow(state, seat)) return EatCard(seat);
      return DrawCard(seat);
    case TurnPhase.discard:
      final mustLayEaten =
          state.hasLaidDown(seat) && state.unlaidEaten(seat).isNotEmpty;
      if (mustLayEaten) return _suggestedLayDown(state, seat);
      return DiscardCard(seat, autoDiscard(state, seat));
    case TurnPhase.layDown:
      return _suggestedLayDown(state, seat);
  }
}

/// Xử lý hết giờ lượt của người đang đánh: áp [autoAction] liên tiếp (bốc
/// rồi đánh, hoặc hạ rồi đánh) cho tới khi lượt chuyển sang người khác hoặc
/// ván kết thúc.
GameResult playTimeout(GameState state) {
  final seat = state.currentSeat;
  var current = state;
  while (!current.isOver && current.currentSeat == seat) {
    final action = autoAction(current);
    if (action == null) break;
    switch (TaLaEngine.apply(current, action)) {
      case Ok(:final value):
        current = value;
      case Err(:final failure):
        return Err(failure);
    }
  }
  return Ok(current);
}

LayDown _suggestedLayDown(GameState state, int seat) {
  final plan = TaLaEngine.suggestLayDown(state, seat);
  return LayDown(
    seat,
    melds: [
      for (final meld in [...?plan?.melds]) meld.cards,
    ],
    sends: plan?.sends ?? const [],
    discard: plan?.discard,
  );
}

/// Lá đánh tự động: lá **không thuộc phỏm** (theo cách xếp giảm nhiều điểm
/// nhất) có điểm cao nhất, và vẫn giữ được phỏm của các lá đã ăn. Chỉ khi mọi
/// lá đều thuộc phỏm mới phải tách phỏm.
PlayingCard autoDiscard(GameState state, int seat) {
  final hand = state.hands[seat];
  final locked = state.unlaidEaten(seat);
  bool legal(PlayingCard card) =>
      !locked.contains(card) &&
      keepsEatenMelds([...hand]..remove(card), locked);
  final deadwood = [
    ...?bestArrangement(hand, eaten: locked)?.deadwood,
  ]..sort((a, b) => b.compareTo(a));
  final byPoints = [...hand]..sort((a, b) => b.compareTo(a));
  return deadwood.where(legal).firstOrNull ??
      byPoints.where(legal).firstOrNull ??
      byPoints.first;
}
