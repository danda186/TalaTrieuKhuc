import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/melds/meld.dart';

/// Một cách xếp bài trên tay: các phỏm rời nhau và phần rác còn lại.
final class Arrangement {
  /// Tạo cách xếp gồm [melds] và [deadwood].
  const Arrangement({required this.melds, required this.deadwood});

  /// Các phỏm, không phỏm nào dùng chung lá.
  final List<Meld> melds;

  /// Các lá không thuộc phỏm nào, sắp tăng dần.
  final List<PlayingCard> deadwood;

  /// Tổng điểm rác.
  int get deadwoodPoints => sumPoints(deadwood);

  /// Tổng điểm các lá nằm trong phỏm.
  int get meldedPoints => melds.fold(0, (sum, m) => sum + m.points);

  /// Số lá nằm trong phỏm.
  int get meldedCount => melds.fold(0, (sum, m) => sum + m.cards.length);
}

/// Mọi phỏm có thể tạo từ các lá trên [hand] (có thể dùng chung lá).
List<Meld> candidateMelds(List<PlayingCard> hand) {
  final result = <Meld>[];
  final byRank = <int, List<PlayingCard>>{};
  for (final card in hand) {
    (byRank[card.rank] ??= []).add(card);
  }
  for (final group in byRank.values) {
    for (var size = Meld.minSize; size <= group.length; size++) {
      result.addAll(_combinations(group, size).map(Meld.tryCreate).nonNulls);
    }
  }
  for (final suit in Suit.values) {
    final sameSuit = hand.where((c) => c.suit == suit).toList()..sort();
    result.addAll(_runsWithin(sameSuit));
  }
  return result;
}

Iterable<Meld> _runsWithin(List<PlayingCard> sortedSameSuit) sync* {
  for (var start = 0; start < sortedSameSuit.length; start++) {
    for (var end = start + Meld.minSize; end <= sortedSameSuit.length; end++) {
      final run = Meld.tryCreate(sortedSameSuit.sublist(start, end));
      if (run == null) break;
      yield run;
    }
  }
}

Iterable<List<PlayingCard>> _combinations(
  List<PlayingCard> items,
  int size, [
  int start = 0,
]) sync* {
  if (size == 0) {
    yield const [];
    return;
  }
  for (var i = start; i <= items.length - size; i++) {
    for (final rest in _combinations(items, size - 1, i + 1)) {
      yield [items[i], ...rest];
    }
  }
}

/// Mọi cách chọn các phỏm rời nhau từ [hand] sao cho mỗi lá trong [eaten]
/// nằm trong một phỏm, và không phỏm nào chứa quá 1 lá ăn.
///
/// Bao gồm cả cách chọn chưa tối đa (VD: không hạ phỏm nào khi [eaten] rỗng),
/// để người gọi tự chọn theo tiêu chí riêng (gửi bài, tránh Móm…).
Iterable<Arrangement> arrangements(
  List<PlayingCard> hand, {
  Set<PlayingCard> eaten = const {},
}) {
  final candidates = candidateMelds(
    hand,
  ).where((m) => m.cards.where(eaten.contains).length <= 1).toList();
  return _search(hand, eaten, candidates, 0, [], {});
}

Iterable<Arrangement> _search(
  List<PlayingCard> hand,
  Set<PlayingCard> eaten,
  List<Meld> candidates,
  int start,
  List<Meld> chosen,
  Set<PlayingCard> used,
) sync* {
  if (eaten.every(used.contains)) {
    yield Arrangement(
      melds: List.unmodifiable(chosen),
      deadwood: List.unmodifiable(
        hand.where((c) => !used.contains(c)).toList()..sort(),
      ),
    );
  }
  for (var i = start; i < candidates.length; i++) {
    final meld = candidates[i];
    if (meld.cards.any(used.contains)) continue;
    chosen.add(meld);
    used.addAll(meld.cards);
    yield* _search(hand, eaten, candidates, i + 1, chosen, used);
    chosen.removeLast();
    used.removeAll(meld.cards);
  }
}

/// Cách xếp giảm được nhiều điểm nhất (ít điểm rác nhất); hoà thì chọn cách
/// có nhiều lá trong phỏm hơn. `null` khi không thể xếp các lá ăn vào phỏm.
Arrangement? bestArrangement(
  List<PlayingCard> hand, {
  Set<PlayingCard> eaten = const {},
}) {
  Arrangement? best;
  for (final candidate in arrangements(hand, eaten: eaten)) {
    if (best == null || _better(candidate, best)) best = candidate;
  }
  return best;
}

bool _better(Arrangement a, Arrangement b) {
  if (a.deadwoodPoints != b.deadwoodPoints) {
    return a.deadwoodPoints < b.deadwoodPoints;
  }
  return a.meldedCount > b.meldedCount;
}

/// Các lá ăn [eaten] trên [hand] có còn xếp được vào các phỏm riêng biệt.
bool keepsEatenMelds(List<PlayingCard> hand, Set<PlayingCard> eaten) =>
    eaten.isEmpty || arrangements(hand, eaten: eaten).isNotEmpty;

/// Có được ăn [card] không: [card] phải tạo phỏm ngay với bài trên [hand],
/// mà mọi lá đã ăn [eaten] (kể cả [card]) vẫn nằm ở các phỏm khác nhau.
bool canEat(
  List<PlayingCard> hand,
  Set<PlayingCard> eaten,
  PlayingCard card,
) => keepsEatenMelds([...hand, card], {...eaten, card});
