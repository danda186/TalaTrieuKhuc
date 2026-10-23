import 'package:ta_la_engine/ta_la_engine.dart';
import 'package:test/test.dart';

import 'support/scenario.dart';

/// Ván có D (ghế 3) ăn liền 3 cây của C (ghế 2) → Ù đền (mục 7.4).
const _threeEatsHands = [
  'AS 2S 3S 4S 6S 7S 8S 9S JS QS',
  'AC 3C 4C 6C 8C 9C 10C QC AD',
  '5C JH KC 2D 3D 4D 6D 8D 9D',
  '5S 5D 9H 10H KS KD 2C 7D 3H',
];

/// Ván 4 vòng không ai ăn trước vòng 4 (dùng cho ăn chốt và Móm).
const _fullRoundHands = [
  '3S 4S 5S 7C 7D 7H QH QD 2C 9D',
  '8S 9S 10S AC 3C 4D 6C 9H KH',
  'JC QC KC 6H AS 2D 8H 10D JS',
  '4H 5H 2S 6S 9C 3D KD 8C AH',
];
const _fullRoundDraws = '7S KS 4C 5C 10C AD 5D 6D 8D JD 2H 3H 10H JH QS';

GameState _playThreeEats(RoomSettings settings) {
  var s = dealFrom(stackDeck(hands: _threeEatsHands), settings: settings);
  s = play(s, [DiscardCard(0, card('9S'))]);
  s = drawToss(s, 1);
  s = play(s, [
    const DrawCard(2),
    DiscardCard(2, card('5C')),
    const EatCard(3),
    DiscardCard(3, card('2C')),
  ]);
  s = drawToss(drawToss(s, 0), 1);
  s = play(s, [
    const DrawCard(2),
    DiscardCard(2, card('JH')),
    const EatCard(3),
    DiscardCard(3, card('7D')),
  ]);
  s = drawToss(drawToss(s, 0), 1);
  return play(s, [
    const DrawCard(2),
    DiscardCard(2, card('KC')),
    const EatCard(3),
  ]);
}

/// Chơi 3 vòng đầu của [_fullRoundHands] rồi tới lượt hạ của A, B, C.
GameState _playToChot() {
  var s = dealFrom(stackDeck(hands: _fullRoundHands, draws: _fullRoundDraws));
  s = play(s, [DiscardCard(0, card('9D'))]);
  for (final seat in [1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]) {
    s = drawToss(s, seat);
  }
  return play(s, [
    const DrawCard(0),
    LayDown(
      0,
      melds: [parseCards('3S 4S 5S'), parseCards('7C 7D 7H')],
      discard: card('3H'),
    ),
    const DrawCard(1),
    LayDown(1, melds: [parseCards('8S 9S 10S')], discard: card('10H')),
    const DrawCard(2),
    LayDown(2, melds: [parseCards('JC QC KC')], discard: card('6H')),
  ]);
}

void main() {
  group('Chia bài', () {
    test('người đi đầu 10 lá, còn lại 9, nọc 15', () {
      final s = dealFrom(standardDeck(), firstSeat: 2);
      expect(s.hands.map((h) => h.length), [9, 9, 10, 9]);
      expect(s.deck, hasLength(15));
      expect(s.currentSeat, 2);
      expect(s.phase, TurnPhase.discard);
    });

    test('từ chối bộ bài sai', () {
      final result = TaLaEngine.deal(
        settings: settingsB5,
        deck: standardDeck().sublist(1),
        firstSeat: 0,
      );
      expect(violation(result), RuleViolation.invalidDeck);
    });

    test('chiều thuận: ghế tiếp theo là seat - 1', () {
      final s = dealFrom(
        standardDeck(),
        direction: TurnDirection.clockwise,
      );
      expect(s.next(0), 3);
      expect(s.previous(0), 1);
    });
  });

  group('Lượt đánh', () {
    test('sai lượt và sai bước bị từ chối', () {
      final s = dealFrom(stackDeck(hands: _threeEatsHands));
      expect(
        violation(TaLaEngine.apply(s, const DrawCard(1))),
        RuleViolation.notYourTurn,
      );
      expect(
        violation(TaLaEngine.apply(s, const DrawCard(0))),
        RuleViolation.wrongPhase,
      );
    });

    test('ăn rồi chuyển bài: lá của người đầu vòng sang người bị ăn', () {
      var s = dealFrom(
        stackDeck(
          hands: const [
            'AS 2S 3S 4S 6S 7S 8S 9S JS QS',
            '5C AC 3C 4C 6C 8C 9C 10C QC',
            '5S 5D 2D 3D 4D 6D 8D 9D AD',
            'JH KC 9H 10H KS KD 2C 7D 3H',
          ],
        ),
      );
      s = play(s, [
        DiscardCard(0, card('9S')),
        const DrawCard(1),
        DiscardCard(1, card('5C')),
      ]);
      expect(TaLaEngine.canEatNow(s, 2), isTrue);
      s = play(s, [const EatCard(2)]);
      expect(s.discards[0], isEmpty);
      expect(s.discards[1], [card('9S')]);
      expect(s.roundLeader, 1);
      expect(s.netScore, [0, -5, 5, 0]);
      expect(
        violation(TaLaEngine.apply(s, DiscardCard(2, card('5C')))),
        RuleViolation.cannotDiscardEatenCard,
      );
      expect(
        violation(TaLaEngine.apply(s, DiscardCard(2, card('5S')))),
        RuleViolation.discardBreaksEatenMeld,
      );
      s = play(s, [DiscardCard(2, card('2D'))]);
      s = drawToss(drawToss(s, 3), 0);
      expect(s.discards.map((d) => d.length), [1, 1, 1, 1]);
      expect(s.currentSeat, 1);
      expect(s.roundLeader, 1);
    });
  });

  group('Ù đền khi ăn cây thứ 3', () {
    test('kết thúc tự động, người cho ăn cây 3 đền làng (ví dụ 7.4)', () {
      final s = _playThreeEats(settingsB5);
      final outcome = s.outcome! as UFinish;
      expect(outcome.winner, 3);
      expect(outcome.denPayer, 2);
      expect(outcome.kind, UKind.regular);
      expect(s.netScore, [0, 0, -105, 105]);
    });

    test('tắt điểm ăn cây thường vẫn đền làng', () {
      final s = _playThreeEats(
        const RoomSettings(base: 5, chargeRegularEats: false),
      );
      expect(s.netScore, [0, 0, -75, 75]);
    });
  });

  group('Chốt chuyển hạ', () {
    test('A sắp hạ đầu ăn lá cuối vòng 3 của D → D mất chốt, B hạ đầu', () {
      var s = dealFrom(
        stackDeck(hands: _fullRoundHands, draws: _fullRoundDraws),
      );
      s = play(s, [DiscardCard(0, card('9D'))]);
      for (final seat in [1, 2, 3, 0, 1, 2, 3, 0, 1, 2]) {
        s = drawToss(s, seat);
      }
      // Lá cuối vòng 3: D đánh 6♠; A (đầu vòng 4, sắp hạ đầu) ăn với 3-4-5♠.
      s = play(s, [const DrawCard(3), DiscardCard(3, card('6S'))]);
      expect(s.roundLeader, 0);
      expect(s.discards.map((d) => d.length), [3, 3, 3, 3]);
      s = play(s, [const EatCard(0)]);
      expect(s.eaten[0].single.isChot, isTrue);
      expect(s.ledger.single.reason, ScoreReason.chotEat);
      expect(s.netScore, [20, 0, 0, -20]);
      // A không phải hạ đầu nữa: bị chuyển 1 lá sang D, B thành người hạ đầu.
      expect(s.phase, TurnPhase.discard);
      expect(s.discards[0], hasLength(2));
      expect(s.discards[3], hasLength(3));
      expect(s.roundLeader, 1);
      s = play(s, [DiscardCard(0, card('QH')), const DrawCard(1)]);
      expect(s.phase, TurnPhase.layDown);
    });
  });

  group('Vòng 4: ăn chốt', () {
    test('nhà đã hạ quay lại và Ù → người ăn chốt đền (ví dụ 7.4)', () {
      var s = _playToChot();
      s = play(s, [
        const EatCard(3),
        LayDown(3, melds: [parseCards('4H 5H 6H')], discard: card('KD')),
      ]);
      expect(s.currentSeat, 0);
      expect(s.returnDenBy, {0: 3});
      s = play(s, [const DrawCard(0)]);
      final outcome = s.outcome! as UFinish;
      expect(outcome.winner, 0);
      expect(outcome.denPayer, 3);
      expect(s.netScore, [75, 0, -20, -55]);
    });

    test('không ăn chốt: xếp hạng theo rác, người Móm trả 4B', () {
      var s = _playToChot();
      s = play(s, [
        const DrawCard(3),
        LayDown(3, melds: const [], discard: card('QS')),
      ]);
      final outcome = s.outcome! as NormalFinish;
      expect(outcome.ranking, [0, 1, 2, 3]);
      expect(outcome.points, [26, 36, 43, 51]);
      expect(outcome.momSeats, {3});
      expect(s.netScore, [35, -5, -10, -20]);
    });

    test('hạ bài kiểm tra luật', () {
      var s = _playToChot();
      s = play(s, [const EatCard(3)]);
      expect(
        violation(
          TaLaEngine.apply(s, LayDown(3, melds: const [], discard: card('KD'))),
        ),
        RuleViolation.eatenCardNotMelded,
      );
      expect(
        violation(
          TaLaEngine.apply(
            s,
            LayDown(3, melds: [parseCards('4H 5H 6H')]),
          ),
        ),
        RuleViolation.mustDiscard,
      );
      expect(
        violation(
          TaLaEngine.apply(
            s,
            LayDown(
              3,
              melds: [parseCards('4H 5H 6H')],
              sends: [SendMove(card('KD'), 0)],
              discard: card('2S'),
            ),
          ),
        ),
        RuleViolation.invalidSend,
      );
    });

    test('gửi bài vào phỏm nhà đã hạ trước', () {
      var s = _playToChot();
      s = play(s, [const EatCard(3)]);
      final plan = TaLaEngine.suggestLayDown(s, 3)!;
      expect(plan.melds.single.cards, parseCards('4H 5H 6H'));
      // 2♠ và 6♠ nối vào sảnh 3-4-5♠ của A (phỏm đầu tiên trên bàn).
      expect(plan.sends.map((m) => m.card).toSet(), {card('2S'), card('6S')});
      expect(plan.sends.every((m) => m.targetIndex == 0), isTrue);
      expect(plan.discard, card('KD'));
      expect(plan.remainingPoints, 9 + 3 + 8 + 1);
      final sent = play(s, [
        LayDown(
          3,
          melds: [plan.melds.single.cards],
          sends: plan.sends,
          discard: plan.discard,
        ),
      ]);
      expect(sent.tableMelds.first.meld.cards, parseCards('2S 3S 4S 5S 6S'));
      expect(sent.senders, {3});
    });
  });

  group('Ù và Ù khan', () {
    GameState leaderWith(String hand) => dealFrom(
      stackDeck(
        hands: [
          hand,
          '8S 9S 10S AC 3C 4D 6C 9H KH',
          'JC QC KC 6H AS 2D 8H 10D JS',
          '4H 5H 2S 6S 9C 3D KD 8C AH',
        ],
      ),
    );

    test('Ù thường từ bài chia: mỗi nhà trả 5B', () {
      final s = leaderWith('3S 4S 5S 7D 7C 2H JH QH 10C 2C');
      expect(TaLaEngine.canDeclareU(s, 0), isFalse);
      final u = leaderWith('3S 4S 5S 7D 7C 7S 10H JH QH 2C');
      expect(TaLaEngine.canDeclareU(u, 0), isTrue);
      final done = play(u, [const DeclareU(0)]);
      expect((done.outcome! as UFinish).kind, UKind.regular);
      expect(done.netScore, [75, -25, -25, -25]);
    });

    test('Ù tròn: mỗi nhà trả 10B', () {
      final s = play(leaderWith('3S 4S 5S 7D 7C 7S 7H 10H JH QH'), [
        const DeclareU(0),
      ]);
      expect((s.outcome! as UFinish).kind, UKind.full);
      expect(s.netScore, [150, -50, -50, -50]);
    });

    test('Ù khan (9 lá) chỉ trước khi thao tác', () {
      final s = dealFrom(
        stackDeck(
          hands: const [
            'QS QC QD 7C 7D 7H 3H 2D 9D JD',
            'AS 4S 7S 10S KS 2C 5C 8C JC',
            '3S 5S 6S 8S 9S 2S 3C 4C 6C',
            '9C 10C KC AD 3D 4D 5D 6D 8D',
          ],
        ),
      );
      expect(TaLaEngine.canDeclareKhan(s, 1), isTrue);
      expect(TaLaEngine.canDeclareKhan(s, 2), isFalse);
      final done = play(s, [const DeclareKhan(1)]);
      expect((done.outcome! as UFinish).kind, UKind.noPair);
      expect(done.netScore, [-25, 75, -25, -25]);
      final acted = play(s, [DiscardCard(0, card('JD')), const DrawCard(1)]);
      expect(TaLaEngine.canDeclareKhan(acted, 1), isFalse);
    });

    test('Ù khan tròn (người đi đầu 10 lá)', () {
      final dealt = dealFrom(
        stackDeck(
          hands: const [
            'AS 4S 7S 10S KS 2C 5C 8C JC 3D',
            'AC 3C 4C 6C 7C 9C 10C QC KC',
            '2S 3S 5S 6S 8S 9S JS QS AD',
            '2D 4D 5D 6D 7D 8D 9D 10D JD',
          ],
        ),
      );
      final s = play(dealt, [const DeclareKhan(0)]);
      expect((s.outcome! as UFinish).kind, UKind.noPairFull);
      expect(s.netScore, [150, -50, -50, -50]);
    });
  });

  group('Hết giờ lượt', () {
    const transferHands = [
      'AS 2S 3S 4S 6S 7S 8S 9S JS QS',
      '5C AC 3C 4C 6C 8C 9C 10C QC',
      '5S 5D 2D 3D 4D 6D 8D 9D AD',
      'JH KC 9H 10H KS KD 2C 7D 3H',
    ];

    test('tự bốc rồi đánh 1 lá không thuộc phỏm, chuyển lượt', () {
      var s = dealFrom(stackDeck(hands: transferHands));
      s = play(s, [
        DiscardCard(0, card('9S')),
        const DrawCard(1),
        DiscardCard(1, card('5C')),
      ]);
      // C ăn được 5♣ nhưng hết giờ thì chỉ bốc, không tự ăn.
      expect(TaLaEngine.canEatNow(s, 2), isTrue);
      final drawn = s.deck.first;
      final before = [...s.hands[2], drawn];
      final after = unwrap(playTimeout(s));
      expect(after.currentSeat, 3);
      expect(after.eaten[2], isEmpty);
      expect(after.hands[2], hasLength(9));
      final tossed = after.discards[2].single;
      final melded = bestArrangement(before)!.melds.expand((m) => m.cards);
      expect(melded, isNot(contains(tossed)));
      final deadwood = bestArrangement(before)!.deadwood;
      expect(tossed, deadwood.reduce((a, b) => a.compareTo(b) >= 0 ? a : b));
    });

    test('không tự báo Ù, đánh lá ngoài phỏm', () {
      final s = dealFrom(
        stackDeck(
          hands: const [
            '3S 4S 5S 7D 7C 7S 10H JH QH 2C',
            '8S 9S 10S AC 3C 4D 6C 9H KH',
            'JC QC KC 6H AS 2D 8H 10D JS',
            '4H 5H 2S 6S 9C 3D KD 8C AH',
          ],
        ),
      );
      final after = unwrap(playTimeout(s));
      expect(after.isOver, isFalse);
      expect(after.discards[0], [card('2C')]);
      expect(after.currentSeat, 1);
    });

    test('lượt hạ bài: tự hạ phỏm rồi đánh', () {
      var s = _playToChot();
      s = play(s, [const DrawCard(3)]);
      expect(s.phase, TurnPhase.layDown);
      final after = unwrap(playTimeout(s));
      expect(after.isOver, isTrue);
      expect(after.hasLaidDown(3), isTrue);
    });
  });
}
