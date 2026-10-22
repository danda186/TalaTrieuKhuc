import 'package:meta/meta.dart';
import 'package:ta_la_engine/src/cards/playing_card.dart';

/// Dạng phỏm.
enum MeldKind {
  /// Bộ 3–4 lá cùng giá trị, khác chất.
  set,

  /// Sảnh: từ 3 lá cùng chất, giá trị liên tiếp (A luôn nhỏ nhất).
  run,
}

/// Một phỏm hợp lệ. Chỉ tạo được qua [Meld.tryCreate] nên luôn đúng luật.
@immutable
final class Meld {
  const Meld._(this.cards, this.kind);

  /// Tạo phỏm từ [cards]; trả về `null` khi các lá không thành phỏm.
  static Meld? tryCreate(Iterable<PlayingCard> cards) {
    final sorted = [...cards]..sort();
    if (sorted.length < minSize) return null;
    if (_isSet(sorted)) return Meld._(List.unmodifiable(sorted), MeldKind.set);
    if (_isRun(sorted)) return Meld._(List.unmodifiable(sorted), MeldKind.run);
    return null;
  }

  /// Số lá tối thiểu của một phỏm.
  static const int minSize = 3;

  static bool _isSet(List<PlayingCard> sorted) {
    final rank = sorted.first.rank;
    return sorted.length <= Suit.values.length &&
        sorted.every((c) => c.rank == rank) &&
        sorted.map((c) => c.suit).toSet().length == sorted.length;
  }

  static bool _isRun(List<PlayingCard> sorted) {
    final first = sorted.first;
    for (var i = 0; i < sorted.length; i++) {
      final card = sorted[i];
      if (card.suit != first.suit || card.rank != first.rank + i) return false;
    }
    return true;
  }

  /// Các lá trong phỏm, sắp tăng dần.
  final List<PlayingCard> cards;

  /// Dạng phỏm: bộ hay sảnh.
  final MeldKind kind;

  /// Tổng điểm các lá trong phỏm (số điểm được giảm khi hạ phỏm này).
  int get points => sumPoints(cards);

  /// Phỏm mới sau khi gửi thêm [card]; `null` nếu gửi không hợp lệ.
  Meld? tryAdd(PlayingCard card) =>
      cards.contains(card) ? null : tryCreate([...cards, card]);

  @override
  bool operator ==(Object other) {
    if (other is! Meld || other.cards.length != cards.length) return false;
    for (var i = 0; i < cards.length; i++) {
      if (other.cards[i] != cards[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(cards);

  @override
  String toString() => cards.join(' ');
}

/// Hai lá [a] và [b] có phải **cạ** không: cùng giá trị, hoặc cùng chất và
/// cách nhau tối đa 2 bậc (còn cơ hội thành phỏm khi thêm 1 lá).
bool isPair(PlayingCard a, PlayingCard b) {
  if (a == b) return false;
  if (a.rank == b.rank) return true;
  return a.suit == b.suit && (a.rank - b.rank).abs() <= 2;
}

/// Bài **khan**: không có cặp lá nào là cạ (điều kiện Ù khan / Ù khan tròn).
bool hasNoPair(List<PlayingCard> hand) {
  for (var i = 0; i < hand.length; i++) {
    for (var j = i + 1; j < hand.length; j++) {
      if (isPair(hand[i], hand[j])) return false;
    }
  }
  return true;
}
