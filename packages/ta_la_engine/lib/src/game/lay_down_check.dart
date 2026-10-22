import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/game/game_action.dart';
import 'package:ta_la_engine/src/game/game_state.dart';
import 'package:ta_la_engine/src/game/rule_violation.dart';
import 'package:ta_la_engine/src/melds/lay_down_planner.dart';
import 'package:ta_la_engine/src/melds/meld.dart';
import 'package:ta_la_engine/src/result.dart';

/// Thao tác hạ bài đã được kiểm tra hợp lệ.
final class CheckedLayDown {
  /// Kết quả kiểm tra: phỏm, lần gửi, lá đánh và phần còn lại.
  const CheckedLayDown({
    required this.melds,
    required this.sends,
    required this.discard,
    required this.remaining,
  });

  /// Các phỏm hạ ra.
  final List<Meld> melds;

  /// Các lần gửi (vị trí trong `GameState.tableMelds`).
  final List<SendMove> sends;

  /// Lá đánh ra; `null` khi đã hạ hết bài.
  final PlayingCard? discard;

  /// Bài còn lại trên tay sau khi đánh; rỗng nghĩa là Ù.
  final List<PlayingCard> remaining;
}

/// Kiểm tra một thao tác [LayDown] theo luật hạ bài và gửi bài.
abstract final class LayDownCheck {
  /// Kiểm tra [action] trên [state]; trả về lý do khi không hợp lệ.
  static Result<CheckedLayDown, RuleViolation> validate(
    GameState state,
    LayDown action,
  ) {
    final seat = action.seat;
    final hand = state.hands[seat];
    final used = <PlayingCard>{};
    final melds = <Meld>[];
    for (final cards in action.melds) {
      final meld = Meld.tryCreate(cards);
      if (meld == null) return const Err(RuleViolation.invalidMeld);
      final problem = _claim(hand, used, meld.cards);
      if (problem != null) return Err(problem);
      melds.add(meld);
    }
    final eatenProblem = _checkEaten(state.unlaidEaten(seat), melds);
    if (eatenProblem != null) return Err(eatenProblem);
    final sendProblem = _checkSends(state, action, hand, used);
    if (sendProblem != null) return Err(sendProblem);
    return _settleDiscard(action, hand, used, melds);
  }

  static RuleViolation? _claim(
    List<PlayingCard> hand,
    Set<PlayingCard> used,
    List<PlayingCard> cards,
  ) {
    for (final card in cards) {
      if (!hand.contains(card)) return RuleViolation.cardNotInHand;
      if (!used.add(card)) return RuleViolation.duplicateCard;
    }
    return null;
  }

  static RuleViolation? _checkEaten(Set<PlayingCard> eaten, List<Meld> melds) {
    for (final meld in melds) {
      if (meld.cards.where(eaten.contains).length > 1) {
        return RuleViolation.twoEatenCardsInOneMeld;
      }
    }
    final melded = {for (final meld in melds) ...meld.cards};
    return eaten.every(melded.contains)
        ? null
        : RuleViolation.eatenCardNotMelded;
  }

  static RuleViolation? _checkSends(
    GameState state,
    LayDown action,
    List<PlayingCard> hand,
    Set<PlayingCard> used,
  ) {
    final targets = [for (final t in state.tableMelds) t.meld];
    for (final send in action.sends) {
      final index = send.targetIndex;
      if (index < 0 || index >= targets.length) {
        return RuleViolation.invalidSend;
      }
      if (state.tableMelds[index].owner == action.seat) {
        return RuleViolation.cannotSendToOwnMeld;
      }
      final problem = _claim(hand, used, [send.card]);
      if (problem != null) return problem;
      final grown = targets[index].tryAdd(send.card);
      if (grown == null) return RuleViolation.invalidSend;
      targets[index] = grown;
    }
    return null;
  }

  static Result<CheckedLayDown, RuleViolation> _settleDiscard(
    LayDown action,
    List<PlayingCard> hand,
    Set<PlayingCard> used,
    List<Meld> melds,
  ) {
    final rest = hand.where((c) => !used.contains(c)).toList();
    final discard = action.discard;
    if (rest.isEmpty && discard != null) {
      return const Err(RuleViolation.invalidDiscard);
    }
    if (rest.isNotEmpty && discard == null) {
      return const Err(RuleViolation.mustDiscard);
    }
    if (discard != null && !rest.remove(discard)) {
      return const Err(RuleViolation.invalidDiscard);
    }
    return Ok(
      CheckedLayDown(
        melds: List.unmodifiable(melds),
        sends: List.unmodifiable(action.sends),
        discard: discard,
        remaining: List.unmodifiable(rest),
      ),
    );
  }
}
