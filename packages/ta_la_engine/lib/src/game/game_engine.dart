import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/game/game_action.dart';
import 'package:ta_la_engine/src/game/game_state.dart';
import 'package:ta_la_engine/src/game/lay_down_check.dart';
import 'package:ta_la_engine/src/game/rule_violation.dart';
import 'package:ta_la_engine/src/game/table_draft.dart';
import 'package:ta_la_engine/src/melds/arrangement.dart';
import 'package:ta_la_engine/src/melds/lay_down_planner.dart';
import 'package:ta_la_engine/src/melds/meld.dart';
import 'package:ta_la_engine/src/result.dart';
import 'package:ta_la_engine/src/scoring/room_settings.dart';
import 'package:ta_la_engine/src/scoring/score_entry.dart';

/// Kết quả một thao tác: trạng thái mới, hoặc lý do bị từ chối.
typedef GameResult = Result<GameState, RuleViolation>;

/// Trọng tài của một ván Tá lả: chia bài và kiểm tra/áp dụng từng thao tác.
///
/// Mọi hàm đều thuần (không đọc đồng hồ, không ngẫu nhiên) để server và
/// test tái lập được ván từ bộ bài và chuỗi thao tác.
abstract final class TaLaEngine {
  /// Số lá mỗi người nhận khi chia (người đi đầu nhận thêm 1).
  static const int handSize = 9;

  /// Chia bài cho [seatCount] người từ [deck] (52 lá đã xáo).
  ///
  /// Chia vòng theo [direction] bắt đầu từ [firstSeat]; người đi đầu nhận
  /// 10 lá và đánh trước, không bốc.
  static GameResult deal({
    required RoomSettings settings,
    required List<PlayingCard> deck,
    required int firstSeat,
    TurnDirection direction = TurnDirection.counterClockwise,
    int seatCount = 4,
  }) {
    if (seatCount < 2 ||
        seatCount > 4 ||
        firstSeat < 0 ||
        firstSeat >= seatCount) {
      return const Err(RuleViolation.invalidSeat);
    }
    if (deck.length != 52 || deck.toSet().length != 52) {
      return const Err(RuleViolation.invalidDeck);
    }
    final step = direction == TurnDirection.counterClockwise ? 1 : -1;
    final hands = List.generate(seatCount, (_) => <PlayingCard>[]);
    var drawn = 0;
    for (var round = 0; round < handSize; round++) {
      for (var k = 0; k < seatCount; k++) {
        hands[(firstSeat + step * k) % seatCount].add(deck[drawn++]);
      }
    }
    hands[firstSeat].add(deck[drawn++]);
    return Ok(
      GameState(
        settings: settings,
        seatCount: seatCount,
        direction: direction,
        firstSeat: firstSeat,
        deck: List.unmodifiable(deck.sublist(drawn)),
        hands: List.unmodifiable([
          for (final h in hands) List<PlayingCard>.unmodifiable(h),
        ]),
        eaten: List.unmodifiable([
          for (var i = 0; i < seatCount; i++) const <EatenCard>[],
        ]),
        discards: List.unmodifiable([
          for (var i = 0; i < seatCount; i++) const <PlayingCard>[],
        ]),
        tableMelds: const [],
        layDownOrder: const [],
        currentSeat: firstSeat,
        phase: TurnPhase.discard,
        roundLeader: firstSeat,
        lastDiscard: null,
        returnDenBy: const {},
        senders: const {},
        actedSeats: const {},
        ledger: const [],
        outcome: null,
      ),
    );
  }

  /// Kiểm tra và áp dụng [action] lên [state].
  static GameResult apply(GameState state, GameAction action) {
    if (state.isOver) return const Err(RuleViolation.gameEnded);
    final seat = action.seat;
    if (seat < 0 || seat >= state.seatCount) {
      return const Err(RuleViolation.invalidSeat);
    }
    return switch (action) {
      DeclareKhan() => _declareKhan(state, seat),
      _ when seat != state.currentSeat => const Err(RuleViolation.notYourTurn),
      DrawCard() => _draw(state, seat),
      EatCard() => _eat(state, seat),
      DiscardCard(:final card) => _discard(state, seat, card),
      LayDown() => _layDown(state, action),
      DeclareU() => _declareU(state, seat),
    };
  }

  /// Ghế [seat] có đang được ăn lá vừa đánh không (để bật nút "Ăn").
  static bool canEatNow(GameState state, int seat) {
    final last = state.lastDiscard;
    return !state.isOver &&
        seat == state.currentSeat &&
        state.phase == TurnPhase.drawOrEat &&
        last != null &&
        last.seat == state.previous(seat) &&
        canEat(state.hands[seat], state.unlaidEaten(seat), last.card);
  }

  /// Ghế [seat] có đủ điều kiện bấm "Hạ bài báo Ù" không.
  static bool canDeclareU(GameState state, int seat) =>
      !state.isOver &&
      seat == state.currentSeat &&
      (state.phase == TurnPhase.discard || state.phase == TurnPhase.layDown) &&
      TableDraft.from(state).uPlan(seat) != null;

  /// Ghế [seat] có được báo Ù khan / Ù khan tròn không.
  static bool canDeclareKhan(GameState state, int seat) =>
      !state.isOver &&
      !state.actedSeats.contains(seat) &&
      hasNoPair(state.hands[seat]);

  /// Gợi ý hạ bài giảm nhiều điểm nhất cho [seat] (gửi theo vị trí trong
  /// `state.tableMelds`); `null` khi không xếp được lá ăn.
  static LayDownPlan? suggestLayDown(GameState state, int seat) {
    final draft = TableDraft.from(state);
    final targets = draft.sendTargets(seat);
    final plan = planLayDown(
      state.hands[seat],
      eaten: state.unlaidEaten(seat),
      sendTargets: [for (final t in targets) t.meld],
      alreadyHasMelds: state.hasLaidDown(seat),
    );
    if (plan == null) return null;
    return LayDownPlan(
      melds: plan.melds,
      sends: [
        for (final s in plan.sends)
          SendMove(s.card, targets[s.targetIndex].index),
      ],
      discard: plan.discard,
      remaining: plan.remaining,
    );
  }

  static GameResult _declareKhan(GameState state, int seat) {
    if (!canDeclareKhan(state, seat)) {
      return const Err(RuleViolation.notEligibleForKhan);
    }
    final kind = state.hands[seat].length > handSize
        ? UKind.noPairFull
        : UKind.noPair;
    final draft = TableDraft.from(state)..finishU(seat, kind);
    return Ok(draft.freeze());
  }

  static GameResult _draw(GameState state, int seat) {
    if (state.phase != TurnPhase.drawOrEat) {
      return const Err(RuleViolation.wrongPhase);
    }
    if (state.deck.isEmpty) return const Err(RuleViolation.deckEmpty);
    final draft = TableDraft.from(state);
    draft.hands[seat].add(draft.deck.removeAt(0));
    draft
      ..actedSeats.add(seat)
      ..lastDiscard = null
      ..afterTake(seat);
    return Ok(draft.freeze());
  }

  static GameResult _eat(GameState state, int seat) {
    if (state.phase != TurnPhase.drawOrEat) {
      return const Err(RuleViolation.wrongPhase);
    }
    final last = state.lastDiscard;
    if (last == null || last.seat != state.previous(seat)) {
      return const Err(RuleViolation.nothingToEat);
    }
    if (!canEat(state.hands[seat], state.unlaidEaten(seat), last.card)) {
      return const Err(RuleViolation.cannotEat);
    }
    final draft = TableDraft.from(state);
    draft.discards[last.seat].removeLast();
    draft.hands[seat].add(last.card);
    final order = draft.eaten[seat].length + 1;
    draft.eaten[seat].add(
      EatenCard(
        card: last.card,
        fromSeat: last.seat,
        order: order,
        isChot: last.isChot,
      ),
    );
    _chargeEat(draft, seat, last, order);
    draft
      ..rebalanceAfterEat(victim: last.seat, eater: seat)
      ..actedSeats.add(seat)
      ..lastDiscard = null;
    final plan = order == 3 ? draft.uPlan(seat) : null;
    if (plan != null) {
      draft.finishU(
        seat,
        draft.classifyU(seat, plan),
        plan: plan,
        denPayer: last.seat,
      );
    } else {
      draft.afterTake(seat);
    }
    return Ok(draft.freeze());
  }

  static void _chargeEat(
    TableDraft draft,
    int seat,
    LastDiscard last,
    int order,
  ) {
    final amount = draft.settings.eatAmount(
      order: order,
      isChot: last.isChot,
    );
    if (amount <= 0) return;
    draft.ledger.add(
      ScoreEntry(
        payer: last.seat,
        payee: seat,
        amount: amount,
        reason: last.isChot ? ScoreReason.chotEat : ScoreReason.regularEat,
      ),
    );
  }

  static GameResult _discard(GameState state, int seat, PlayingCard card) {
    if (state.phase != TurnPhase.discard) {
      return const Err(RuleViolation.wrongPhase);
    }
    final hand = state.hands[seat];
    if (!hand.contains(card)) return const Err(RuleViolation.cardNotInHand);
    final locked = state.unlaidEaten(seat);
    if (locked.contains(card)) {
      return const Err(RuleViolation.cannotDiscardEatenCard);
    }
    if (locked.isNotEmpty && state.hasLaidDown(seat)) {
      return const Err(RuleViolation.eatenCardNotMelded);
    }
    if (!keepsEatenMelds([...hand]..remove(card), locked)) {
      return const Err(RuleViolation.discardBreaksEatenMeld);
    }
    final draft = TableDraft.from(state)..pushDiscard(seat, card);
    return Ok(draft.freeze());
  }

  static GameResult _declareU(GameState state, int seat) {
    if (state.phase != TurnPhase.discard && state.phase != TurnPhase.layDown) {
      return const Err(RuleViolation.wrongPhase);
    }
    final draft = TableDraft.from(state);
    final plan = draft.uPlan(seat);
    if (plan == null) return const Err(RuleViolation.cannotDeclareU);
    draft.finishU(seat, draft.classifyU(seat, plan), plan: plan);
    return Ok(draft.freeze());
  }

  static GameResult _layDown(GameState state, LayDown action) {
    final seat = action.seat;
    final allowed =
        state.phase == TurnPhase.layDown ||
        (state.phase == TurnPhase.discard && state.hasLaidDown(seat));
    if (!allowed) return const Err(RuleViolation.wrongPhase);
    return switch (LayDownCheck.validate(state, action)) {
      Err(:final failure) => Err(failure),
      Ok(value: final checked) => Ok(_applyLayDown(state, seat, checked)),
    };
  }

  static GameState _applyLayDown(
    GameState state,
    int seat,
    CheckedLayDown checked,
  ) {
    final draft = TableDraft.from(state);
    final plan = LayDownPlan(
      melds: checked.melds,
      sends: checked.sends,
      discard: checked.discard,
      remaining: checked.remaining,
    );
    if (checked.remaining.isEmpty) {
      final kind = draft.classifyU(seat, plan);
      draft.finishU(seat, kind, plan: plan);
      return draft.freeze();
    }
    draft.layOut(seat, checked.melds, checked.sends);
    final discard = checked.discard;
    if (discard != null) draft.pushDiscard(seat, discard);
    return draft.freeze();
  }
}
