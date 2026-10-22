import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/melds/arrangement.dart';
import 'package:ta_la_engine/src/melds/meld.dart';

/// Vai trò của một lá trên tay sau khi xếp bài, để giao diện tô màu.
enum CardRole {
  /// Lá lẻ, không thuộc phỏm hay cạ.
  deadwood,

  /// Thuộc một cặp cạ.
  pair,

  /// Thuộc một phỏm.
  meld,
}

/// Kết quả nút "Xếp bài".
final class SortedHand {
  /// Tạo kết quả xếp bài.
  const SortedHand({required this.cards, required this.roles});

  /// Thứ tự lá từ trái qua phải: rác → cạ → phỏm, mỗi nhóm tăng dần.
  final List<PlayingCard> cards;

  /// Vai trò của từng lá.
  final Map<PlayingCard, CardRole> roles;
}

/// Xếp bài theo yêu cầu nút "Xếp bài".
///
/// Phỏm được chọn theo cách giảm nhiều điểm nhất (và giữ các lá ăn [eaten]
/// trong phỏm). Rác còn lại được ghép cạ tham lam theo thứ tự tăng dần.
SortedHand sortHand(
  List<PlayingCard> hand, {
  Set<PlayingCard> eaten = const {},
}) {
  final arrangement =
      bestArrangement(hand, eaten: eaten) ??
      Arrangement(melds: const [], deadwood: [...hand]..sort());
  final pairs = _greedyPairs(arrangement.deadwood);
  final inPair = {for (final pair in pairs) ...pair};
  final singles = arrangement.deadwood.where((c) => !inPair.contains(c));
  final melds = [...arrangement.melds]
    ..sort((a, b) => a.cards.first.compareTo(b.cards.first));
  return SortedHand(
    cards: List.unmodifiable([
      ...singles,
      for (final pair in pairs) ...pair,
      for (final meld in melds) ...meld.cards,
    ]),
    roles: Map.unmodifiable({
      for (final card in singles) card: CardRole.deadwood,
      for (final card in inPair) card: CardRole.pair,
      for (final meld in melds)
        for (final card in meld.cards) card: CardRole.meld,
    }),
  );
}

List<List<PlayingCard>> _greedyPairs(List<PlayingCard> sortedDeadwood) {
  final taken = <PlayingCard>{};
  final pairs = <List<PlayingCard>>[];
  for (var i = 0; i < sortedDeadwood.length; i++) {
    final card = sortedDeadwood[i];
    if (taken.contains(card)) continue;
    final mate = sortedDeadwood
        .skip(i + 1)
        .where((other) => !taken.contains(other) && isPair(card, other))
        .firstOrNull;
    if (mate == null) continue;
    taken.addAll([card, mate]);
    pairs.add([card, mate]);
  }
  return pairs;
}
