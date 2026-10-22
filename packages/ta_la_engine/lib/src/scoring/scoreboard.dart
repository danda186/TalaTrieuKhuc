import 'package:ta_la_engine/src/scoring/score_entry.dart';

/// Bảng điểm phòng cộng dồn qua các ván. Bắt đầu từ 0, tổng luôn bằng 0.
final class MatchScoreboard {
  /// Bảng điểm với tổng điểm [totals] theo ghế và điểm từng ván [games].
  const MatchScoreboard._(this.totals, this.games);

  /// Bảng điểm trống cho [seatCount] ghế.
  factory MatchScoreboard.empty(int seatCount) =>
      MatchScoreboard._(List.unmodifiable(List.filled(seatCount, 0)), const []);

  /// Tổng điểm hiện tại theo ghế.
  final List<int> totals;

  /// Điểm cộng/trừ theo ghế của từng ván đã chơi, theo thứ tự.
  final List<List<int>> games;

  /// Bảng điểm mới sau khi cộng các khoản [ledger] của một ván.
  MatchScoreboard addGame(List<ScoreEntry> ledger) {
    final delta = netScores(ledger, totals.length);
    return MatchScoreboard._(
      List.unmodifiable([
        for (var i = 0; i < totals.length; i++) totals[i] + delta[i],
      ]),
      List.unmodifiable([...games, List<int>.unmodifiable(delta)]),
    );
  }

  /// Các ghế xếp theo tổng điểm giảm dần (dương nhiều nhất đứng đầu).
  List<int> get standings =>
      List.generate(totals.length, (i) => i)
        ..sort((a, b) => totals[b].compareTo(totals[a]));
}
