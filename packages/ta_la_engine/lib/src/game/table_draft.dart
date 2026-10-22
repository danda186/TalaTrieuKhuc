import 'package:ta_la_engine/src/cards/playing_card.dart';
import 'package:ta_la_engine/src/game/game_state.dart';
import 'package:ta_la_engine/src/melds/lay_down_planner.dart';
import 'package:ta_la_engine/src/melds/meld.dart';
import 'package:ta_la_engine/src/scoring/room_settings.dart';
import 'package:ta_la_engine/src/scoring/score_entry.dart';

/// Bản nháp có thể sửa của [GameState], chỉ dùng bên trong engine để tạo
/// trạng thái mới sau một thao tác đã được kiểm tra hợp lệ.
final class TableDraft {
  /// Sao chép sâu [state] thành bản nháp.
  TableDraft.from(GameState state)
    : settings = state.settings,
      seatCount = state.seatCount,
      direction = state.direction,
      firstSeat = state.firstSeat,
      deck = [...state.deck],
      hands = [
        for (final h in state.hands) [...h],
      ],
      eaten = [
        for (final e in state.eaten) [...e],
      ],
      discards = [
        for (final d in state.discards) [...d],
      ],
      tableMelds = [...state.tableMelds],
      layDownOrder = [...state.layDownOrder],
      currentSeat = state.currentSeat,
      phase = state.phase,
      roundLeader = state.roundLeader,
      lastDiscard = state.lastDiscard,
      returnDenBy = {...state.returnDenBy},
      senders = {...state.senders},
      actedSeats = {...state.actedSeats},
      ledger = [...state.ledger],
      outcome = state.outcome;

  /// Xem [GameState.settings].
  final RoomSettings settings;

  /// Xem [GameState.seatCount].
  final int seatCount;

  /// Xem [GameState.direction].
  final TurnDirection direction;

  /// Xem [GameState.firstSeat].
  final int firstSeat;

  /// Xem [GameState.deck].
  final List<PlayingCard> deck;

  /// Xem [GameState.hands].
  final List<List<PlayingCard>> hands;

  /// Xem [GameState.eaten].
  final List<List<EatenCard>> eaten;

  /// Xem [GameState.discards].
  final List<List<PlayingCard>> discards;

  /// Xem [GameState.tableMelds].
  final List<TableMeld> tableMelds;

  /// Xem [GameState.layDownOrder].
  final List<int> layDownOrder;

  /// Xem [GameState.currentSeat].
  int currentSeat;

  /// Xem [GameState.phase].
  TurnPhase phase;

  /// Xem [GameState.roundLeader].
  int roundLeader;

  /// Xem [GameState.lastDiscard].
  LastDiscard? lastDiscard;

  /// Xem [GameState.returnDenBy].
  final Map<int, int> returnDenBy;

  /// Xem [GameState.senders].
  final Set<int> senders;

  /// Xem [GameState.actedSeats].
  final Set<int> actedSeats;

  /// Xem [GameState.ledger].
  final List<ScoreEntry> ledger;

  /// Xem [GameState.outcome].
  GameOutcome? outcome;

  /// Trạng thái bất biến tương ứng với bản nháp.
  GameState freeze() => GameState(
    settings: settings,
    seatCount: seatCount,
    direction: direction,
    firstSeat: firstSeat,
    deck: List.unmodifiable(deck),
    hands: List.unmodifiable([
      for (final h in hands) List<PlayingCard>.unmodifiable(h),
    ]),
    eaten: List.unmodifiable([
      for (final e in eaten) List<EatenCard>.unmodifiable(e),
    ]),
    discards: List.unmodifiable([
      for (final d in discards) List<PlayingCard>.unmodifiable(d),
    ]),
    tableMelds: List.unmodifiable(tableMelds),
    layDownOrder: List.unmodifiable(layDownOrder),
    currentSeat: currentSeat,
    phase: phase,
    roundLeader: roundLeader,
    lastDiscard: lastDiscard,
    returnDenBy: Map.unmodifiable(returnDenBy),
    senders: Set.unmodifiable(senders),
    actedSeats: Set.unmodifiable(actedSeats),
    ledger: List.unmodifiable(ledger),
    outcome: outcome,
  );

  /// Ghế đánh sau [seat].
  int next(int seat) {
    final step = direction == TurnDirection.counterClockwise ? 1 : -1;
    return (seat + step) % seatCount;
  }

  /// Ghế [seat] đã hạ bài chưa.
  bool hasLaidDown(int seat) => layDownOrder.contains(seat);

  /// Các lá ăn của [seat] còn trên tay.
  Set<PlayingCard> unlaidEaten(int seat) => {
    for (final e in eaten[seat])
      if (hands[seat].contains(e.card)) e.card,
  };

  /// Các phỏm [seat] được gửi vào (của nhà khác đã hạ), kèm vị trí trong
  /// [tableMelds].
  List<({int index, Meld meld})> sendTargets(int seat) => [
    for (var i = 0; i < tableMelds.length; i++)
      if (tableMelds[i].owner != seat) (index: i, meld: tableMelds[i].meld),
  ];

  /// Chuyển bài sau khi ghế [eater] ăn lá của [victim].
  ///
  /// Nếu [victim] là người đánh đầu vòng thì không cần chuyển và [eater]
  /// thành người đánh đầu vòng. Ngược lại, lá đánh gần nhất của người đánh
  /// đầu vòng chuyển sang [victim] và người kế tiếp thành người đánh đầu
  /// vòng. Người bị hụt lá (người đầu vòng) mà đã hạ bài thì được quay lại
  /// đánh; Ù trong lượt đó thì [eater] (người ăn chốt) đền.
  void rebalanceAfterEat({required int victim, required int eater}) {
    final shortSeat = roundLeader;
    if (victim == roundLeader) {
      roundLeader = eater;
    } else {
      discards[victim].add(discards[roundLeader].removeLast());
      roundLeader = next(roundLeader);
    }
    if (hasLaidDown(shortSeat)) returnDenBy[shortSeat] = eater;
  }

  /// Gợi ý hạ hết bài của [seat] (đủ điều kiện Ù); `null` nếu không Ù được.
  /// Các lần gửi trong kết quả dùng vị trí trong [tableMelds].
  LayDownPlan? uPlan(int seat) {
    final targets = sendTargets(seat);
    final plan = planLayDown(
      hands[seat],
      eaten: unlaidEaten(seat),
      sendTargets: [for (final t in targets) t.meld],
      alreadyHasMelds: hasLaidDown(seat),
    );
    if (plan == null || !plan.emptiesHand) return null;
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

  /// Loại Ù khi [seat] hạ hết bài theo [plan].
  UKind classifyU(int seat, LayDownPlan plan) {
    if (plan.sends.isNotEmpty || senders.contains(seat)) return UKind.withSends;
    if (!hasLaidDown(seat) && plan.meldsWholeHand) return UKind.full;
    return UKind.regular;
  }

  /// Sau khi ăn/bốc: tự kết thúc nếu là trường hợp đền, nếu không thì
  /// chuyển sang bước đánh hoặc hạ bài.
  void afterTake(int seat) {
    final denBy = returnDenBy[seat];
    final plan = denBy == null ? null : uPlan(seat);
    if (denBy != null && plan != null) {
      finishU(seat, classifyU(seat, plan), plan: plan, denPayer: denBy);
      return;
    }
    final mustLayDown = !hasLaidDown(seat) && discards[seat].length == 3;
    phase = mustLayDown ? TurnPhase.layDown : TurnPhase.discard;
  }

  /// Bày [melds] và áp [sends] của [seat] lên bàn, bỏ các lá khỏi tay.
  void layOut(int seat, List<Meld> melds, List<SendMove> sends) {
    for (final meld in melds) {
      tableMelds.add(TableMeld(owner: seat, meld: meld));
      meld.cards.forEach(hands[seat].remove);
    }
    for (final send in sends) {
      final target = tableMelds[send.targetIndex];
      final grown = target.meld.tryAdd(send.card);
      if (grown == null) continue;
      tableMelds[send.targetIndex] = TableMeld(
        owner: target.owner,
        meld: grown,
      );
      hands[seat].remove(send.card);
    }
    if (sends.isNotEmpty) senders.add(seat);
    if (!hasLaidDown(seat)) layDownOrder.add(seat);
  }

  /// Đánh lá [card] của [seat] ra hàng bài, rồi chuyển lượt hoặc kết thúc.
  void pushDiscard(int seat, PlayingCard card) {
    hands[seat].remove(card);
    discards[seat].add(card);
    actedSeats.add(seat);
    returnDenBy.remove(seat);
    lastDiscard = LastDiscard(
      seat: seat,
      card: card,
      isChot: discards[seat].length == 4,
    );
    final everyoneDone =
        layDownOrder.length == seatCount &&
        discards.every((d) => d.length == 4);
    if (everyoneDone) {
      finishNormal();
      return;
    }
    final nextSeat = next(seat);
    if (discards.every((d) => d.length == discards[seat].length)) {
      roundLeader = nextSeat;
    }
    currentSeat = nextSeat;
    phase = TurnPhase.drawOrEat;
  }

  /// Kết thúc ván bình thường: xếp hạng theo điểm rác và tính tiền.
  void finishNormal() {
    final points = [for (final hand in hands) sumPoints(hand)];
    final momSeats = {
      for (var seat = 0; seat < seatCount; seat++)
        if (!tableMelds.any((m) => m.owner == seat)) seat,
    };
    int sortKey(int seat) =>
        (momSeats.contains(seat) ? 1 : 0) * 1000000 +
        points[seat] * 100 +
        layDownOrder.indexOf(seat);
    final ranking = List.generate(seatCount, (i) => i)
      ..sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    final winner = ranking.first;
    var place = 0;
    for (final seat in ranking.skip(1)) {
      if (momSeats.contains(seat)) {
        _pay(seat, winner, settings.momAmount, ScoreReason.mom);
      } else {
        place++;
        _pay(seat, winner, settings.rankAmount(place), _rankReason(place));
      }
    }
    outcome = NormalFinish(
      ranking: List.unmodifiable(ranking),
      points: List.unmodifiable(points),
      momSeats: Set.unmodifiable(momSeats),
    );
    phase = TurnPhase.ended;
  }

  ScoreReason _rankReason(int place) {
    if (place == seatCount - 1) return ScoreReason.last;
    return place == 1 ? ScoreReason.second : ScoreReason.third;
  }

  /// Kết thúc ván vì [winner] Ù loại [kind]. Bày [plan] lên bàn nếu có.
  /// [denPayer] (nếu có) trả thay phần của mọi nhà.
  void finishU(
    int winner,
    UKind kind, {
    LayDownPlan? plan,
    int? denPayer,
  }) {
    if (plan != null) {
      layOut(winner, plan.melds, plan.sends);
      final discard = plan.discard;
      if (discard != null) {
        hands[winner].remove(discard);
        discards[winner].add(discard);
      }
    }
    final perPlayer = settings.uAmountPerPlayer(kind);
    if (denPayer != null) {
      _pay(denPayer, winner, perPlayer * (seatCount - 1), ScoreReason.uDen);
    } else {
      for (var seat = 0; seat < seatCount; seat++) {
        if (seat != winner) _pay(seat, winner, perPlayer, ScoreReason.u);
      }
    }
    outcome = UFinish(winner: winner, kind: kind, denPayer: denPayer);
    phase = TurnPhase.ended;
    lastDiscard = null;
  }

  void _pay(int payer, int payee, int amount, ScoreReason reason) {
    if (amount <= 0) return;
    ledger.add(
      ScoreEntry(payer: payer, payee: payee, amount: amount, reason: reason),
    );
  }
}
