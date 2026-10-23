import 'package:ta_la_engine/ta_la_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Bảng điểm theo base', () {
    test('B = 5: Nhì/Ba/Bét/Móm, chốt, Ù', () {
      const s = RoomSettings(base: 5);
      expect([1, 2, 3].map(s.rankAmount), [5, 10, 15]);
      expect(s.momAmount, 20);
      expect(s.eatAmount(order: 1, isChot: true), 20);
      expect(s.uAmountPerPlayer(UKind.regular), 25);
      expect(s.uAmountPerPlayer(UKind.full), 50);
      expect(s.uAmountPerPlayer(UKind.withSends), 25);
      expect(s.uAmountPerPlayer(UKind.noPair), 25);
      expect(s.uAmountPerPlayer(UKind.noPairFull), 50);
    });

    test('mức base nhập tay: chỉ số nguyên dương', () {
      expect(RoomSettings.parseBase('5'), 5);
      expect(RoomSettings.parseBase(' 12 '), 12);
      expect(RoomSettings.parseBase('007'), 7);
      for (final bad in [
        '',
        '0',
        '-5',
        '2.5',
        '1,000',
        '5đ',
        'abc',
        '1234567',
      ]) {
        expect(RoomSettings.parseBase(bad), isNull, reason: bad);
      }
      const s = RoomSettings(base: 7);
      expect([1, 2, 3].map(s.rankAmount), [7, 14, 21]);
    });

    test('B = 10 nhảy bậc tương ứng', () {
      const s = RoomSettings(base: 10);
      expect([1, 2, 3].map(s.rankAmount), [10, 20, 30]);
      expect(s.eatAmount(order: 3, isChot: true), 40);
    });

    test('ăn cây thường 1/2/3 = 1B/2B/3B khi bật, 0 khi tắt', () {
      const on = RoomSettings(base: 5);
      expect(
        [1, 2, 3].map((o) => on.eatAmount(order: o, isChot: false)),
        [5, 10, 15],
      );
      const off = RoomSettings(base: 5, chargeRegularEats: false);
      expect(off.eatAmount(order: 2, isChot: false), 0);
      expect(off.eatAmount(order: 2, isChot: true), 20);
    });
  });

  group('Bảng điểm phòng', () {
    test('cộng dồn, tổng luôn 0, xếp theo tổng giảm dần', () {
      final board = MatchScoreboard.empty(4)
          .addGame(const [
            ScoreEntry(
              payer: 1,
              payee: 0,
              amount: 5,
              reason: ScoreReason.second,
            ),
            ScoreEntry(
              payer: 2,
              payee: 0,
              amount: 10,
              reason: ScoreReason.third,
            ),
          ])
          .addGame(const [
            ScoreEntry(payer: 0, payee: 3, amount: 50, reason: ScoreReason.u),
          ]);
      expect(board.totals, [-35, -5, -10, 50]);
      expect(board.totals.reduce((a, b) => a + b), 0);
      expect(board.standings, [3, 1, 2, 0]);
      expect(board.games, hasLength(2));
    });
  });

  group('Quỹ tạm dừng', () {
    final t0 = DateTime.utc(2026, 10, 22, 20);
    const clock = PauseClock(
      budget: Duration(minutes: 10),
      othersMayResumeAfter: Duration(minutes: 1),
    );

    PauseClock ok(Result<PauseClock, PauseViolation> r) => switch (r) {
      Ok(:final value) => value,
      Err(:final failure) => fail('Bị từ chối: $failure'),
    };

    PauseViolation err(Result<PauseClock, PauseViolation> r) => switch (r) {
      Ok() => fail('Mong đợi bị từ chối'),
      Err(:final failure) => failure,
    };

    test('người tạm dừng tiếp tục được ngay', () {
      final paused = ok(clock.pause(2, t0));
      final resumed = ok(paused.resume(2, t0.add(const Duration(seconds: 5))));
      expect(resumed.isPaused, isFalse);
      expect(resumed.used, const Duration(seconds: 5));
    });

    test('người khác phải chờ 1 phút', () {
      final paused = ok(clock.pause(2, t0));
      final early = t0.add(const Duration(seconds: 42));
      expect(err(paused.resume(0, early)), PauseViolation.mustWait);
      expect(paused.waitForOthersAt(early), const Duration(seconds: 18));
      expect(
        ok(paused.resume(0, t0.add(const Duration(minutes: 1)))).isPaused,
        isFalse,
      );
    });

    test('không tạm dừng chồng', () {
      final paused = ok(clock.pause(1, t0));
      expect(err(paused.pause(3, t0)), PauseViolation.alreadyPaused);
      expect(err(clock.resume(1, t0)), PauseViolation.notPaused);
    });

    test('quỹ 10 phút cộng dồn cả trận, hết quỹ thì kết thúc', () {
      var c = ok(clock.pause(0, t0));
      c = ok(c.resume(0, t0.add(const Duration(minutes: 6))));
      final later = t0.add(const Duration(hours: 1));
      c = ok(c.pause(1, later));
      final at = later.add(const Duration(minutes: 3));
      expect(c.remainingAt(at), const Duration(minutes: 1));
      expect(c.isExhaustedAt(at), isFalse);
      expect(c.isExhaustedAt(later.add(const Duration(minutes: 4))), isTrue);
      final done = ok(c.resume(1, later.add(const Duration(minutes: 5))));
      expect(done.remainingAt(later), Duration.zero);
      expect(err(done.pause(2, later)), PauseViolation.budgetExhausted);
    });
  });
}
