import 'package:meta/meta.dart';

/// Lý do phát sinh một khoản điểm.
enum ScoreReason {
  /// Bị ăn cây thường.
  regularEat,

  /// Bị ăn cây chốt.
  chotEat,

  /// Về Nhì, trả Nhất.
  second,

  /// Về Ba, trả Nhất.
  third,

  /// Về Bét, trả Nhất.
  last,

  /// Móm, trả Nhất.
  mom,

  /// Trả tiền Ù.
  u,

  /// Đền làng: trả thay phần Ù của cả bàn.
  uDen,
}

/// Một khoản điểm: [payer] trừ [amount], [payee] cộng [amount].
///
/// Mọi khoản đều cân bằng nên tổng điểm của cả bàn luôn bằng 0.
@immutable
final class ScoreEntry {
  /// Tạo khoản điểm từ ghế [payer] sang ghế [payee].
  const ScoreEntry({
    required this.payer,
    required this.payee,
    required this.amount,
    required this.reason,
  });

  /// Ghế bị trừ điểm.
  final int payer;

  /// Ghế được cộng điểm.
  final int payee;

  /// Số điểm (luôn dương).
  final int amount;

  /// Lý do.
  final ScoreReason reason;

  @override
  bool operator ==(Object other) =>
      other is ScoreEntry &&
      other.payer == payer &&
      other.payee == payee &&
      other.amount == amount &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(payer, payee, amount, reason);

  @override
  String toString() => '$payer→$payee $amount (${reason.name})';
}

/// Điểm cộng/trừ của từng ghế từ danh sách [entries].
List<int> netScores(Iterable<ScoreEntry> entries, int seatCount) {
  final totals = List<int>.filled(seatCount, 0);
  for (final entry in entries) {
    totals[entry.payer] -= entry.amount;
    totals[entry.payee] += entry.amount;
  }
  return totals;
}
