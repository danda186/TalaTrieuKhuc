import 'package:meta/meta.dart';
import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/melds/arrangement.dart';
import 'package:ta_la_engine/src/melds/meld.dart';

/// Một lần gửi: lá [card] được thêm vào phỏm thứ [targetIndex] trên bàn.
@immutable
final class SendMove {
  /// Gửi [card] vào phỏm [targetIndex].
  const SendMove(this.card, this.targetIndex);

  /// Lá được gửi.
  final PlayingCard card;

  /// Vị trí phỏm đích trong danh sách phỏm được phép gửi.
  final int targetIndex;

  @override
  bool operator ==(Object other) =>
      other is SendMove &&
      other.card == card &&
      other.targetIndex == targetIndex;

  @override
  int get hashCode => Object.hash(card, targetIndex);

  @override
  String toString() => '$card→#$targetIndex';
}

/// Áp các lần gửi [moves] lần lượt lên [targets]; `null` nếu có lần gửi
/// không hợp lệ.
List<Meld>? applySends(List<Meld> targets, List<SendMove> moves) {
  final melds = [...targets];
  for (final move in moves) {
    if (move.targetIndex < 0 || move.targetIndex >= melds.length) return null;
    final next = melds[move.targetIndex].tryAdd(move.card);
    if (next == null) return null;
    melds[move.targetIndex] = next;
  }
  return melds;
}

/// Chọn các lần gửi giảm được nhiều điểm nhất cho [cards] vào [targets].
///
/// Xét cả gửi nối tiếp (gửi `8♥` rồi `9♥` vào sảnh `5♥ 6♥ 7♥`).
List<SendMove> bestSends(List<PlayingCard> cards, List<Meld> targets) {
  if (cards.isEmpty || targets.isEmpty) return const [];
  return _SendSearch(targets).run(cards);
}

final class _SendSearch {
  _SendSearch(this.targets);

  final List<Meld> targets;
  final Map<String, ({int points, List<SendMove> moves})> _memo = {};

  List<SendMove> run(List<PlayingCard> cards) => _best(cards, targets).moves;

  ({int points, List<SendMove> moves}) _best(
    List<PlayingCard> remaining,
    List<Meld> melds,
  ) {
    final key = '${remaining.join(',')}|${melds.join('/')}';
    final cached = _memo[key];
    if (cached != null) return cached;
    var best = (points: 0, moves: const <SendMove>[]);
    for (final card in remaining) {
      for (var i = 0; i < melds.length; i++) {
        final grown = melds[i].tryAdd(card);
        if (grown == null) continue;
        final rest = _best(
          [...remaining]..remove(card),
          [...melds]..[i] = grown,
        );
        final points = card.points + rest.points;
        if (points > best.points) {
          best = (points: points, moves: [SendMove(card, i), ...rest.moves]);
        }
      }
    }
    return _memo[key] = best;
  }
}

/// Gợi ý hạ bài: phỏm hạ, lá gửi, lá đánh và phần còn lại trên tay.
final class LayDownPlan {
  /// Tạo một gợi ý hạ bài.
  const LayDownPlan({
    required this.melds,
    required this.sends,
    required this.discard,
    required this.remaining,
  });

  /// Các phỏm hạ ra.
  final List<Meld> melds;

  /// Các lá gửi vào phỏm của nhà đã hạ trước.
  final List<SendMove> sends;

  /// Lá đánh ra sau khi hạ; `null` khi không còn lá nào (Ù).
  final PlayingCard? discard;

  /// Các lá còn lại trên tay sau khi đánh (tính điểm rác).
  final List<PlayingCard> remaining;

  /// Điểm rác còn lại.
  int get remainingPoints => sumPoints(remaining);

  /// Hạ xong là hết bài trên tay (đủ điều kiện Ù).
  bool get emptiesHand => remaining.isEmpty;

  /// Toàn bộ bài thành phỏm, không gửi, không cần đánh lá nào (Ù tròn).
  bool get meldsWholeHand => discard == null && sends.isEmpty;
}

/// Gợi ý hạ bài giảm được nhiều điểm nhất.
///
/// Thứ tự ưu tiên: không bị Móm (khi [alreadyHasMelds] là `false`), ít điểm
/// rác nhất, ít lá còn lại nhất, rồi không cần đánh lá nào (để Ù tròn được
/// ưu tiên hơn Ù thường). Lá đánh ra là lá rác điểm cao nhất.
/// `null` khi không thể xếp các lá ăn [eaten] vào phỏm.
LayDownPlan? planLayDown(
  List<PlayingCard> hand, {
  Set<PlayingCard> eaten = const {},
  List<Meld> sendTargets = const [],
  bool alreadyHasMelds = false,
}) {
  LayDownPlan? best;
  int? bestKey;
  for (final arrangement in arrangements(hand, eaten: eaten)) {
    final plan = _planFor(arrangement, sendTargets);
    final isMom = !alreadyHasMelds && plan.melds.isEmpty;
    final key =
        (isMom ? 1 : 0) * 10000000 +
        plan.remainingPoints * 1000 +
        plan.remaining.length * 10 +
        (plan.discard == null ? 0 : 1);
    if (bestKey == null || key < bestKey) {
      best = plan;
      bestKey = key;
    }
  }
  return best;
}

LayDownPlan _planFor(Arrangement arrangement, List<Meld> sendTargets) {
  final sends = bestSends(arrangement.deadwood, sendTargets);
  final sent = {for (final move in sends) move.card};
  final residual = arrangement.deadwood.where((c) => !sent.contains(c)).toList()
    ..sort();
  final discard = residual.isEmpty ? null : residual.removeLast();
  return LayDownPlan(
    melds: arrangement.melds,
    sends: sends,
    discard: discard,
    remaining: List.unmodifiable(residual),
  );
}
