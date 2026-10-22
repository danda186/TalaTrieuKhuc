import 'dart:math';

import 'package:ta_la_engine/ta_la_engine.dart';
import 'package:test/test.dart';

import 'support/scenario.dart';

/// Chơi một ván ngẫu nhiên tới hết: ăn khi được với xác suất [eatChance],
/// còn lại dùng [autoAction]. Kiểm tra bất biến sau mỗi thao tác.
GameState _playRandomGame(int seed, {double eatChance = 0.7}) {
  final rng = Random(seed);
  var state = dealFrom(
    shuffledDeck(rng),
    firstSeat: seed % 4,
    direction: seed.isEven
        ? TurnDirection.counterClockwise
        : TurnDirection.clockwise,
    settings: RoomSettings(base: 5, chargeRegularEats: seed % 3 != 0),
  );
  for (var step = 0; !state.isOver; step++) {
    expect(step, lessThan(120), reason: 'ván $seed không kết thúc');
    final seat = state.currentSeat;
    final wantsEat =
        state.phase == TurnPhase.drawOrEat &&
        TaLaEngine.canEatNow(state, seat) &&
        rng.nextDouble() < eatChance;
    final action = wantsEat ? EatCard(seat) : autoAction(state)!;
    final result = TaLaEngine.apply(state, action);
    if (result is Err<GameState, RuleViolation>) {
      fail(
        'ván $seed bước $step: ${action.runtimeType} bị từ chối '
        '(${result.failure})',
      );
    }
    state = (result as Ok<GameState, RuleViolation>).value;
    _checkInvariants(state, seed);
  }
  return state;
}

void _checkInvariants(GameState state, int seed) {
  expect(cardsInPlay(state), 52, reason: 'ván $seed mất/thừa lá');
  final counts = state.discards.map((d) => d.length).toList();
  expect(counts.every((c) => c <= 4), isTrue, reason: 'ván $seed: $counts');
  expect(counts.reduce(max) - counts.reduce(min), lessThanOrEqualTo(1));
  for (var seat = 0; seat < state.seatCount; seat++) {
    for (final eaten in state.eaten[seat]) {
      final inHand = state.hands[seat].contains(eaten.card);
      final onTable = state.tableMelds.any(
        (m) => m.owner == seat && m.meld.cards.contains(eaten.card),
      );
      expect(inHand || onTable, isTrue, reason: 'ván $seed: lá ăn bị mất');
    }
  }
}

void main() {
  test('3000 ván ngẫu nhiên: luôn kết thúc, đủ 52 lá, tổng điểm = 0', () {
    final outcomes = <String, int>{};
    for (var seed = 0; seed < 3000; seed++) {
      final state = _playRandomGame(seed);
      expect(state.netScore.reduce((a, b) => a + b), 0);
      final outcome = state.outcome!;
      final label = switch (outcome) {
        NormalFinish() => 'thường',
        UFinish(:final kind, :final denPayer) =>
          denPayer == null ? 'Ù ${kind.name}' : 'Ù đền ${kind.name}',
      };
      outcomes[label] = (outcomes[label] ?? 0) + 1;
      if (outcome is NormalFinish) {
        expect(state.discards.every((d) => d.length == 4), isTrue);
        expect(state.layDownOrder.toSet(), hasLength(4));
        expect(outcome.ranking.toSet(), hasLength(4));
      }
    }
    printOnFailure('$outcomes');
    expect(outcomes['thường'], greaterThan(0));
    expect(outcomes.keys.where((k) => k.startsWith('Ù đền')), isNotEmpty);
    expect(outcomes.keys.where((k) => k.contains('withSends')), isNotEmpty);
  });

  test('không ai ăn: ván luôn đúng 4 vòng, dùng hết 15 lá nọc', () {
    for (var seed = 0; seed < 300; seed++) {
      final state = _playRandomGame(seed, eatChance: 0);
      if (state.outcome is NormalFinish) {
        expect(state.deck, isEmpty, reason: 'ván $seed');
      }
    }
  });
}
