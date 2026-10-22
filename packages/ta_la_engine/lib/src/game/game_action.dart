import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/melds/lay_down_planner.dart';

/// Ý định của một người chơi, client gửi lên server để engine kiểm tra.
sealed class GameAction {
  const GameAction(this.seat);

  /// Ghế thực hiện thao tác.
  final int seat;
}

/// Bốc 1 lá từ nọc.
final class DrawCard extends GameAction {
  /// Ghế [seat] bốc bài.
  const DrawCard(super.seat);
}

/// Ăn lá người ngồi trước vừa đánh.
final class EatCard extends GameAction {
  /// Ghế [seat] ăn bài.
  const EatCard(super.seat);
}

/// Đánh 1 lá.
final class DiscardCard extends GameAction {
  /// Ghế [seat] đánh lá [card].
  const DiscardCard(super.seat, this.card);

  /// Lá đánh ra.
  final PlayingCard card;
}

/// Hạ bài: hạ phỏm, gửi bài vào phỏm nhà đã hạ, rồi đánh 1 lá.
final class LayDown extends GameAction {
  /// Ghế [seat] hạ [melds], gửi [sends] và đánh [discard].
  const LayDown(
    super.seat, {
    required this.melds,
    this.sends = const [],
    this.discard,
  });

  /// Các phỏm hạ ra, mỗi phỏm là danh sách lá.
  final List<List<PlayingCard>> melds;

  /// Các lần gửi; `targetIndex` là vị trí trong `GameState.tableMelds`.
  final List<SendMove> sends;

  /// Lá đánh ra sau khi hạ; bỏ trống khi hạ hết bài (Ù).
  final PlayingCard? discard;
}

/// Bấm nút "Hạ bài báo Ù": engine tự hạ theo cách tối ưu.
final class DeclareU extends GameAction {
  /// Ghế [seat] báo Ù.
  const DeclareU(super.seat);
}

/// Báo Ù khan / Ù khan tròn ngay sau khi chia.
final class DeclareKhan extends GameAction {
  /// Ghế [seat] báo Ù khan.
  const DeclareKhan(super.seat);
}
