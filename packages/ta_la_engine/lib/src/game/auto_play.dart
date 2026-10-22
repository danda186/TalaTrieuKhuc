import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/game/game_action.dart';
import 'package:ta_la_engine/src/game/game_engine.dart';
import 'package:ta_la_engine/src/game/game_state.dart';
import 'package:ta_la_engine/src/melds/arrangement.dart';

/// Thao tác tự động khi người chơi hết giờ lượt.
///
/// Ưu tiên báo Ù nếu đủ điều kiện; đầu lượt thì bốc (hết nọc thì ăn); lượt
/// thường đánh lá rác điểm cao nhất; lượt hạ thì hạ theo gợi ý tối ưu.
/// `null` khi ván đã kết thúc.
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
      if (TaLaEngine.canDeclareU(state, seat)) return DeclareU(seat);
      final mustLayEaten =
          state.hasLaidDown(seat) && state.unlaidEaten(seat).isNotEmpty;
      if (mustLayEaten) return _suggestedLayDown(state, seat);
      return DiscardCard(seat, autoDiscard(state, seat));
    case TurnPhase.layDown:
      if (TaLaEngine.canDeclareU(state, seat)) return DeclareU(seat);
      return _suggestedLayDown(state, seat);
  }
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

/// Lá nên đánh khi tự động: lá rác điểm cao nhất mà vẫn giữ được phỏm của
/// các lá đã ăn.
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
