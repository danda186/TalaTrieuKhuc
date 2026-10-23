import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/melds/meld.dart';
import 'package:ta_la_engine/src/scoring/room_settings.dart';
import 'package:ta_la_engine/src/scoring/score_entry.dart';

/// Chiều chia bài và đánh bài trong một ván.
enum TurnDirection {
  /// Ngược chiều kim đồng hồ: ghế tiếp theo là `seat + 1`.
  counterClockwise,

  /// Thuận chiều kim đồng hồ: ghế tiếp theo là `seat - 1`.
  clockwise,
}

/// Chiều đánh khi người đi đầu [firstSeat] chọn [nextSeat] là người được
/// chia bài và đánh ngay sau mình (cách chọn chiều trên giao diện).
///
/// `null` khi [nextSeat] không ngồi cạnh [firstSeat] hoặc ghế không hợp lệ.
TurnDirection? directionToward({
  required int firstSeat,
  required int nextSeat,
  int seatCount = 4,
}) {
  bool valid(int seat) => seat >= 0 && seat < seatCount;
  if (seatCount < 2 || !valid(firstSeat) || !valid(nextSeat)) return null;
  if ((firstSeat + 1) % seatCount == nextSeat) {
    return TurnDirection.counterClockwise;
  }
  if ((firstSeat - 1) % seatCount == nextSeat) return TurnDirection.clockwise;
  return null;
}

/// Bước hiện tại trong lượt của người đang đánh.
enum TurnPhase {
  /// Đầu lượt: chọn Ăn hoặc Bốc.
  drawOrEat,

  /// Đã ăn/bốc (hoặc lượt đầu của người đi đầu): đánh 1 lá. Nhà đã hạ
  /// được quay lại đánh tiếp cũng có thể hạ thêm phỏm / gửi bài ở bước này.
  discard,

  /// Lượt hạ bài (đã đánh đủ 3 lá): hạ phỏm, gửi bài và đánh lá cuối.
  layDown,

  /// Ván đã kết thúc.
  ended,
}

/// Một lá đã ăn.
final class EatenCard {
  /// Ghi nhận lá [card] ăn của ghế [fromSeat].
  const EatenCard({
    required this.card,
    required this.fromSeat,
    required this.order,
    required this.isChot,
  });

  /// Lá đã ăn.
  final PlayingCard card;

  /// Ghế bị ăn.
  final int fromSeat;

  /// Thứ tự lá ăn của người ăn trong ván (1–3).
  final int order;

  /// Lá ăn có phải cây chốt (lá đánh thứ 4 của người bị ăn) không.
  final bool isChot;
}

/// Một phỏm đã hạ trên bàn.
final class TableMeld {
  /// Phỏm [meld] của ghế [owner].
  const TableMeld({required this.owner, required this.meld});

  /// Ghế đã hạ phỏm này.
  final int owner;

  /// Phỏm hiện tại, gồm cả các lá người khác đã gửi vào.
  final Meld meld;
}

/// Lá vừa được đánh ra, người ngồi sau có thể ăn.
final class LastDiscard {
  /// Lá [card] do ghế [seat] vừa đánh.
  const LastDiscard({
    required this.seat,
    required this.card,
    required this.isChot,
  });

  /// Ghế vừa đánh.
  final int seat;

  /// Lá vừa đánh.
  final PlayingCard card;

  /// Đây có phải lá đánh thứ 4 (cây chốt) của ghế đó.
  final bool isChot;
}

/// Kết quả của một ván đã kết thúc.
sealed class GameOutcome {
  const GameOutcome();

  /// Ghế thắng (Nhất hoặc người Ù), cũng là người đi đầu ván sau.
  int get winner;
}

/// Ván kết thúc bình thường sau khi mọi người hạ bài.
final class NormalFinish extends GameOutcome {
  /// Xếp hạng [ranking] (Nhất trước), điểm rác [points] theo ghế và các
  /// ghế bị Móm [momSeats].
  const NormalFinish({
    required this.ranking,
    required this.points,
    required this.momSeats,
  });

  /// Các ghế theo thứ tự Nhất, Nhì, Ba, Bét.
  final List<int> ranking;

  /// Điểm rác còn lại theo ghế.
  final List<int> points;

  /// Các ghế bị Móm.
  final Set<int> momSeats;

  @override
  int get winner => ranking.first;
}

/// Ván kết thúc vì có người Ù.
final class UFinish extends GameOutcome {
  /// Ghế [winner] Ù loại [kind]; [denPayer] là ghế đền làng nếu có.
  const UFinish({required this.winner, required this.kind, this.denPayer});

  @override
  final int winner;

  /// Loại Ù.
  final UKind kind;

  /// Ghế phải đền làng; `null` khi mỗi nhà tự trả.
  final int? denPayer;
}

/// Toàn bộ trạng thái một ván. Bất biến: mọi thao tác tạo trạng thái mới.
///
/// Đây là dữ liệu đầy đủ của server; khi gửi cho client cần ẩn bài trên tay
/// người khác và thứ tự nọc.
final class GameState {
  /// Tạo trạng thái; chỉ engine nên gọi.
  const GameState({
    required this.settings,
    required this.seatCount,
    required this.direction,
    required this.firstSeat,
    required this.deck,
    required this.hands,
    required this.eaten,
    required this.discards,
    required this.tableMelds,
    required this.layDownOrder,
    required this.currentSeat,
    required this.phase,
    required this.roundLeader,
    required this.lastDiscard,
    required this.returnDenBy,
    required this.senders,
    required this.actedSeats,
    required this.ledger,
    required this.outcome,
  });

  /// Cài đặt phòng.
  final RoomSettings settings;

  /// Số người chơi (2–4).
  final int seatCount;

  /// Chiều đánh của ván.
  final TurnDirection direction;

  /// Ghế đi đầu (nhận 10 lá).
  final int firstSeat;

  /// Nọc, lá đầu danh sách được bốc trước.
  final List<PlayingCard> deck;

  /// Bài trên tay theo ghế (gồm cả lá ăn chưa hạ).
  final List<List<PlayingCard>> hands;

  /// Các lá đã ăn theo ghế.
  final List<List<EatenCard>> eaten;

  /// Hàng bài đánh ra (đang hiển thị) theo ghế.
  final List<List<PlayingCard>> discards;

  /// Các phỏm đã hạ trên bàn.
  final List<TableMeld> tableMelds;

  /// Thứ tự các ghế đã hạ bài.
  final List<int> layDownOrder;

  /// Ghế đang tới lượt.
  final int currentSeat;

  /// Bước hiện tại của lượt.
  final TurnPhase phase;

  /// Người đánh đầu vòng hiện tại (thay đổi khi chuyển bài).
  final int roundLeader;

  /// Lá vừa đánh, có thể bị ăn; `null` khi không còn ăn được.
  final LastDiscard? lastDiscard;

  /// Nhà đã hạ được quay lại đánh do bị chuyển bài → ghế người ăn chốt sẽ
  /// đền nếu nhà đó Ù trong lượt quay lại.
  final Map<int, int> returnDenBy;

  /// Các ghế đã gửi bài trong ván.
  final Set<int> senders;

  /// Các ghế đã thực hiện thao tác (dùng để xét Ù khan).
  final Set<int> actedSeats;

  /// Các khoản điểm đã phát sinh trong ván.
  final List<ScoreEntry> ledger;

  /// Kết quả ván; `null` khi ván còn đang chơi.
  final GameOutcome? outcome;

  /// Ván đã kết thúc chưa.
  bool get isOver => outcome != null;

  /// Ghế đánh sau [seat] theo chiều đã chọn.
  int next(int seat) => _step(seat, 1);

  /// Ghế đánh trước [seat] theo chiều đã chọn.
  int previous(int seat) => _step(seat, -1);

  int _step(int seat, int delta) {
    final signed = direction == TurnDirection.counterClockwise ? delta : -delta;
    return (seat + signed) % seatCount;
  }

  /// Ghế [seat] đã hạ bài chưa.
  bool hasLaidDown(int seat) => layDownOrder.contains(seat);

  /// Các lá ăn của [seat] còn trên tay (chưa hạ).
  Set<PlayingCard> unlaidEaten(int seat) => {
    for (final e in eaten[seat])
      if (hands[seat].contains(e.card)) e.card,
  };

  /// Điểm cộng/trừ của từng ghế trong ván tính tới hiện tại.
  List<int> get netScore => netScores(ledger, seatCount);
}
