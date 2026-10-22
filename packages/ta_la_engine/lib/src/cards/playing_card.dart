import 'package:meta/meta.dart';

/// Chất bài. Không có thứ tự mạnh/yếu, chỉ dùng để xét sảnh và hiển thị.
enum Suit {
  /// Bích ♠.
  spades('♠', 'S'),

  /// Tép (nhép) ♣.
  clubs('♣', 'C'),

  /// Rô ♦.
  diamonds('♦', 'D'),

  /// Cơ ♥.
  hearts('♥', 'H');

  const Suit(this.symbol, this.letter);

  /// Ký hiệu để hiển thị, ví dụ `♥`.
  final String symbol;

  /// Chữ cái viết tắt dùng khi phân tích chuỗi, ví dụ `H`.
  final String letter;
}

/// Một lá bài trong bộ 52 lá.
///
/// [rank] đi từ 1 (A) tới 13 (K) và cũng là điểm của lá khi tính rác.
@immutable
final class PlayingCard implements Comparable<PlayingCard> {
  /// Tạo lá bài có giá trị [rank] (1–13) và chất [suit].
  const PlayingCard(this.rank, this.suit)
    : assert(rank >= minRank && rank <= maxRank, 'rank phải trong 1..13');

  /// Đọc lá bài từ mã như `7H`, `10D`, `AS`, `K♠`.
  ///
  /// Ném [FormatException] khi mã không hợp lệ, giống `int.parse`.
  factory PlayingCard.parse(String code) {
    final card = tryParse(code);
    if (card == null) {
      throw FormatException('Mã lá bài không hợp lệ', code);
    }
    return card;
  }

  /// Giá trị nhỏ nhất (A).
  static const int minRank = 1;

  /// Giá trị lớn nhất (K).
  static const int maxRank = 13;

  static const _rankLabels = [
    'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', //
  ];

  /// Đọc lá bài từ mã; trả về `null` khi mã không hợp lệ.
  static PlayingCard? tryParse(String code) {
    final text = code.trim().toUpperCase();
    if (text.length < 2) return null;
    final suitText = text.substring(text.length - 1);
    final rankText = text.substring(0, text.length - 1);
    final suit = Suit.values
        .where((s) => s.letter == suitText || s.symbol == suitText)
        .firstOrNull;
    final rankIndex = _rankLabels.indexOf(rankText);
    if (suit == null || rankIndex < 0) return null;
    return PlayingCard(rankIndex + 1, suit);
  }

  /// Giá trị lá bài: A = 1, 2–10 theo số, J = 11, Q = 12, K = 13.
  final int rank;

  /// Chất của lá bài.
  final Suit suit;

  /// Điểm của lá khi nằm trong rác (bằng [rank]).
  int get points => rank;

  /// Nhãn giá trị để hiển thị: `A`, `2`…`10`, `J`, `Q`, `K`.
  String get rankLabel => _rankLabels[rank - 1];

  /// Mã ngắn ổn định, ví dụ `10H`; dùng để lưu trữ và truyền qua mạng.
  String get code => '$rankLabel${suit.letter}';

  /// So sánh theo giá trị trước, rồi theo thứ tự chất ♠ ♣ ♦ ♥.
  @override
  int compareTo(PlayingCard other) {
    final byRank = rank.compareTo(other.rank);
    return byRank != 0 ? byRank : suit.index.compareTo(other.suit.index);
  }

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => '$rankLabel${suit.symbol}';
}

/// Đọc nhiều lá bài cách nhau bởi khoảng trắng, ví dụ `'7H 8H 9H'`.
List<PlayingCard> parseCards(String codes) => [
  for (final code in codes.split(RegExp(r'\s+')))
    if (code.isNotEmpty) PlayingCard.parse(code),
];

/// Tổng điểm của các lá [cards].
int sumPoints(Iterable<PlayingCard> cards) =>
    cards.fold(0, (sum, card) => sum + card.points);
