import 'package:ta_la_engine/src/result.dart';

/// Lý do không thể tạm dừng / tiếp tục.
enum PauseViolation {
  /// Ván đang tạm dừng rồi.
  alreadyPaused,

  /// Ván không ở trạng thái tạm dừng.
  notPaused,

  /// Đã dùng hết quỹ tạm dừng của trận.
  budgetExhausted,

  /// Người khác phải chờ đủ thời gian mới được tiếp tục.
  mustWait,
}

/// Lần tạm dừng đang diễn ra.
final class ActivePause {
  /// Ghế [seat] tạm dừng từ thời điểm [since].
  const ActivePause({required this.seat, required this.since});

  /// Ghế đã tạm dừng.
  final int seat;

  /// Thời điểm bắt đầu tạm dừng (giờ server).
  final DateTime since;
}

/// Quỹ tạm dừng của cả trận.
///
/// Thời điểm `now` luôn được truyền vào (giờ server), không đọc đồng hồ
/// bên trong, để mọi client thấy cùng một con số và test tái lập được.
final class PauseClock {
  /// Tạo đồng hồ với quỹ [budget], thời gian chờ [othersMayResumeAfter] cho
  /// người khác, thời gian đã dùng [used] và lần tạm dừng [active].
  const PauseClock({
    required this.budget,
    required this.othersMayResumeAfter,
    this.used = Duration.zero,
    this.active,
  });

  /// Tổng thời gian được tạm dừng trong cả trận.
  final Duration budget;

  /// Người khác phải chờ bao lâu kể từ lúc tạm dừng mới được tiếp tục.
  final Duration othersMayResumeAfter;

  /// Thời gian đã tạm dừng của các lần trước (đã kết thúc).
  final Duration used;

  /// Lần tạm dừng đang diễn ra; `null` khi ván đang chạy.
  final ActivePause? active;

  /// Ván có đang tạm dừng không.
  bool get isPaused => active != null;

  /// Tổng thời gian đã tạm dừng tính tới [now].
  Duration usedAt(DateTime now) {
    final current = active;
    return current == null ? used : used + now.difference(current.since);
  }

  /// Quỹ tạm dừng còn lại tại [now] (không âm).
  Duration remainingAt(DateTime now) {
    final left = budget - usedAt(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Đã vượt quỹ chưa: khi đúng thì phải kết thúc trận ngay, đóng phòng và
  /// lưu bảng điểm hiện tại vào lịch sử.
  bool isExhaustedAt(DateTime now) => usedAt(now) >= budget;

  /// Ghế [seat] bấm tạm dừng tại [now].
  Result<PauseClock, PauseViolation> pause(int seat, DateTime now) {
    if (isPaused) return const Err(PauseViolation.alreadyPaused);
    if (isExhaustedAt(now)) return const Err(PauseViolation.budgetExhausted);
    return Ok(
      _copy(
        active: ActivePause(seat: seat, since: now),
      ),
    );
  }

  /// Ghế [seat] bấm tiếp tục tại [now]. Người tạm dừng tiếp tục được ngay;
  /// người khác phải chờ [othersMayResumeAfter].
  Result<PauseClock, PauseViolation> resume(int seat, DateTime now) {
    final current = active;
    if (current == null) return const Err(PauseViolation.notPaused);
    final elapsed = now.difference(current.since);
    if (seat != current.seat && elapsed < othersMayResumeAfter) {
      return const Err(PauseViolation.mustWait);
    }
    return Ok(_copy(used: used + elapsed));
  }

  /// Người khác còn phải chờ bao lâu nữa mới được tiếp tục (0 nếu được).
  Duration waitForOthersAt(DateTime now) {
    final current = active;
    if (current == null) return Duration.zero;
    final left = othersMayResumeAfter - now.difference(current.since);
    return left.isNegative ? Duration.zero : left;
  }

  PauseClock _copy({Duration? used, ActivePause? active}) => PauseClock(
    budget: budget,
    othersMayResumeAfter: othersMayResumeAfter,
    used: used ?? this.used,
    active: active,
  );
}
