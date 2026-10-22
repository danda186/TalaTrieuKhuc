import 'dart:math';

import 'package:ta_la_engine/src/cards/playing_card.dart';

/// Bộ 52 lá theo thứ tự cố định (♠ A→K, ♣, ♦, ♥).
List<PlayingCard> standardDeck() => [
  for (final suit in Suit.values)
    for (var rank = PlayingCard.minRank; rank <= PlayingCard.maxRank; rank++)
      PlayingCard(rank, suit),
];

/// Bộ 52 lá đã xáo bằng [random] được truyền vào.
///
/// Server nên truyền một `Random.secure()`; test truyền `Random(seed)` để
/// tái lập được ván.
List<PlayingCard> shuffledDeck(Random random) =>
    standardDeck()..shuffle(random);
