/// Các loại Ù.
enum UKind {
  /// Ù thường: 9 lá thành phỏm, đánh lá còn lại.
  regular,

  /// Ù tròn: cả 10 lá thành phỏm.
  full,

  /// Ù gửi: hết rác nhờ gửi bài vào phỏm nhà đã hạ trước.
  withSends,

  /// Ù khan: 9 lá vừa chia không có cạ nào.
  noPair,

  /// Ù khan tròn: người đi đầu, 10 lá vừa chia không có cạ nào.
  noPairFull,
}

/// Cài đặt phòng, chủ phòng chọn khi tạo phòng và áp dụng cả trận.
final class RoomSettings {
  /// Tạo cài đặt phòng với mức [base] (B) và các tuỳ chọn.
  const RoomSettings({
    required this.base,
    this.chargeRegularEats = true,
    this.turnDuration = const Duration(seconds: 25),
    this.pauseBudget = const Duration(minutes: 10),
    this.othersMayResumeAfter = const Duration(minutes: 1),
  }) : assert(base > 0, 'base phải dương');

  /// Mức base B; mọi khoản điểm là bội số của B.
  final int base;

  /// Có tính điểm ăn cây thường (cây 1/2/3 = 1B/2B/3B) hay không.
  final bool chargeRegularEats;

  /// Thời gian tối đa của một lượt.
  final Duration turnDuration;

  /// Tổng thời gian được tạm dừng trong cả trận.
  final Duration pauseBudget;

  /// Người khác (không phải người tạm dừng) phải chờ bao lâu mới được bỏ
  /// tạm dừng.
  final Duration othersMayResumeAfter;

  /// Điểm người ăn nhận từ người bị ăn khi ăn lá thứ [order] (1–3) của mình.
  ///
  /// Cây chốt luôn là 4B, kể cả khi là cây thứ 2 hay 3. Cây thường là
  /// `order × B` nếu bật [chargeRegularEats], ngược lại 0.
  int eatAmount({required int order, required bool isChot}) {
    if (isChot) return 4 * base;
    return chargeRegularEats ? order * base : 0;
  }

  /// Điểm người về vị trí [place] (1 = Nhì, 2 = Ba, 3 = Bét) trả cho Nhất.
  int rankAmount(int place) => place * base;

  /// Điểm người Móm trả cho Nhất.
  int get momAmount => 4 * base;

  /// Điểm mỗi nhà trả cho người Ù loại [kind].
  int uAmountPerPlayer(UKind kind) => switch (kind) {
    UKind.regular || UKind.withSends || UKind.noPair => 5 * base,
    UKind.full || UKind.noPairFull => 10 * base,
  };
}
