import 'package:ta_la_engine/ta_la_engine.dart';
import 'package:test/test.dart';

import 'support/scenario.dart';

void main() {
  group('PlayingCard', () {
    test('đọc mã chữ và ký hiệu', () {
      expect(card('10H'), const PlayingCard(10, Suit.hearts));
      expect(card('A♠'), const PlayingCard(1, Suit.spades));
      expect(card('kd').points, 13);
      expect(PlayingCard.tryParse('1H'), isNull);
      expect(PlayingCard.tryParse('ZZ'), isNull);
      expect(() => PlayingCard.parse('11X'), throwsFormatException);
    });

    test('điểm: A = 1, J = 11, Q = 12, K = 13', () {
      expect(parseCards('AS JC QD KH').map((c) => c.points), [1, 11, 12, 13]);
      expect(sumPoints(parseCards('AS 10C KH')), 24);
    });

    test('mã và hiển thị', () {
      expect(card('QH').code, 'QH');
      expect(card('QH').toString(), 'Q♥');
    });

    test('bộ bài chuẩn có 52 lá khác nhau', () {
      expect(standardDeck().toSet(), hasLength(52));
    });
  });

  group('Meld', () {
    test('bộ 3 và tứ quý cùng giá trị', () {
      expect(Meld.tryCreate(parseCards('7S 7H 7D'))?.kind, MeldKind.set);
      expect(Meld.tryCreate(parseCards('KS KC KD KH'))?.kind, MeldKind.set);
    });

    test('sảnh cùng chất liên tiếp, A nhỏ nhất, không vòng', () {
      expect(Meld.tryCreate(parseCards('AS 2S 3S'))?.kind, MeldKind.run);
      expect(Meld.tryCreate(parseCards('9C JC 10C QC'))?.kind, MeldKind.run);
      expect(Meld.tryCreate(parseCards('QH KH AH')), isNull);
    });

    test('không hợp lệ: 2 lá, khác chất, đứt quãng', () {
      expect(Meld.tryCreate(parseCards('7S 7H')), isNull);
      expect(Meld.tryCreate(parseCards('4H 5H 6S')), isNull);
      expect(Meld.tryCreate(parseCards('4H 5H 7H')), isNull);
    });

    test('gửi thêm lá vào phỏm', () {
      final run = Meld.tryCreate(parseCards('5H 6H 7H'))!;
      expect(run.tryAdd(card('8H'))?.cards, parseCards('5H 6H 7H 8H'));
      expect(run.tryAdd(card('4H')), isNotNull);
      expect(run.tryAdd(card('9H')), isNull);
      final set = Meld.tryCreate(parseCards('QS QC QD'))!;
      expect(set.tryAdd(card('QH'))?.cards, hasLength(4));
    });
  });

  group('Cạ và bài khan', () {
    test('cạ: cùng số, hoặc cùng chất cách nhau tối đa 2 bậc', () {
      expect(isPair(card('5H'), card('5S')), isTrue);
      expect(isPair(card('5H'), card('6H')), isTrue);
      expect(isPair(card('5H'), card('7H')), isTrue);
      expect(isPair(card('5H'), card('8H')), isFalse);
      expect(isPair(card('5H'), card('6S')), isFalse);
    });

    test('bài khan: không có cặp cạ nào', () {
      expect(hasNoPair(parseCards('AS 4S 7S 10S KS 2C 5C 8C JC')), isTrue);
      expect(hasNoPair(parseCards('AS 4S 7S 10S KS 2C 5C 8C JC 3D')), isTrue);
      expect(hasNoPair(parseCards('AS 3S 7S 10S KS 2C 5C 8C JC')), isFalse);
    });
  });

  group('Xếp phỏm tối ưu', () {
    test('chọn cách giảm nhiều điểm nhất', () {
      // 7♥ vào bộ 7 (21 điểm) tốt hơn vào sảnh 5-6-7♥ (18 điểm).
      final hand = parseCards('7S 7D 7H 5H 6H KC');
      final best = bestArrangement(hand)!;
      expect(best.melds.single.cards, parseCards('7S 7D 7H'));
      expect(best.deadwoodPoints, 5 + 6 + 13);
    });

    test('nhiều phỏm rời nhau', () {
      final hand = parseCards('3S 4S 5S 8D 8C 8H JH QH 2C KD');
      final best = bestArrangement(hand)!;
      expect(best.melds, hasLength(2));
      expect(best.deadwood, parseCards('2C JH QH KD'));
    });

    test('lá ăn phải nằm trong phỏm, mỗi phỏm tối đa 1 lá ăn', () {
      final hand = parseCards('8D 8C 8H 8S');
      expect(bestArrangement(hand, eaten: {card('8H')}), isNotNull);
      expect(
        bestArrangement(hand, eaten: {card('8H'), card('8S')}),
        isNull,
      );
    });
  });

  group('Điều kiện ăn', () {
    test('ăn được khi tạo phỏm ngay', () {
      final hand = parseCards('8D 8C 2S');
      expect(canEat(hand, const {}, card('8H')), isTrue);
      expect(canEat(hand, const {}, card('9H')), isFalse);
    });

    test('không ăn 2 lá vào cùng một phỏm', () {
      final hand = parseCards('8D 8C 8H 2S');
      expect(canEat(hand, {card('8H')}, card('8S')), isFalse);
    });

    test('không ăn nếu làm vỡ phỏm của lá ăn trước', () {
      // 5♥ đã ăn nằm trong 4-5-6♥; ăn 5♠ cần 5♥ cho bộ 5 → không được.
      final hand = parseCards('4H 5H 6H 5D');
      expect(canEat(hand, {card('5H')}, card('5S')), isFalse);
      // 7♥ chỉ vào được sảnh chứa cả 5♥ đã ăn → không được.
      expect(canEat(hand, {card('5H')}, card('7H')), isFalse);
      // Có thêm 5♣ thì 5♠ thành bộ 5 riêng → được.
      final more = parseCards('4H 5H 6H 5D 5C');
      expect(canEat(more, {card('5H')}, card('5S')), isTrue);
    });
  });

  group('Gửi bài và gợi ý hạ bài', () {
    test('gửi nối tiếp nhiều lá vào một sảnh', () {
      final run = Meld.tryCreate(parseCards('5H 6H 7H'))!;
      final sends = bestSends(parseCards('8H 9H KS'), [run]);
      expect(sends.map((s) => s.card), parseCards('8H 9H'));
      expect(applySends([run], sends)!.single.cards, hasLength(5));
    });

    test('ví dụ màn hạ bài: gửi 4♥ và Q♥, đánh K♦, còn 9 điểm', () {
      final hand = parseCards('3S 4S 5S 8D 8C 8H 4H QH 9C KD');
      final targets = [
        Meld.tryCreate(parseCards('5H 6H 7H'))!,
        Meld.tryCreate(parseCards('QS QC QD'))!,
        Meld.tryCreate(parseCards('2D 3D 4D'))!,
      ];
      final plan = planLayDown(
        hand,
        eaten: {card('8H')},
        sendTargets: targets,
      )!;
      expect(plan.melds, hasLength(2));
      expect(plan.sends.map((s) => s.card).toSet(), {card('4H'), card('QH')});
      expect(plan.discard, card('KD'));
      expect(plan.remaining, [card('9C')]);
      expect(plan.remainingPoints, 9);
    });

    test('ưu tiên không bị Móm khi điểm bằng nhau', () {
      // Gửi cả 5-6-7♥ vào 2-3-4♥ cũng hết bằng hạ phỏm, nhưng sẽ bị Móm.
      final plan = planLayDown(
        parseCards('5H 6H 7H KD QD'),
        sendTargets: [Meld.tryCreate(parseCards('2H 3H 4H'))!],
      )!;
      expect(plan.melds, isNotEmpty);
      expect(plan.remainingPoints, 12);
    });

    test('hết bài là đủ điều kiện Ù', () {
      final plan = planLayDown(parseCards('3S 4S 5S 8D 8C 8H JH QH KH 2C'))!;
      expect(plan.emptiesHand, isTrue);
      expect(plan.discard, card('2C'));
      final full = planLayDown(parseCards('3S 4S 5S 6S 8D 8C 8H JH QH KH'))!;
      expect(full.meldsWholeHand, isTrue);
    });
  });

  group('Nút Xếp bài', () {
    test('rác → cạ → phỏm, tăng dần từ trái qua phải', () {
      final sorted = sortHand(parseCards('KD 3S 8D QH 2C 5S 8C 4S JH 8H'));
      expect(sorted.cards, parseCards('2C KD JH QH 3S 4S 5S 8C 8D 8H'));
      expect(sorted.roles[card('KD')], CardRole.deadwood);
      expect(sorted.roles[card('JH')], CardRole.pair);
      expect(sorted.roles[card('8H')], CardRole.meld);
    });
  });
}
