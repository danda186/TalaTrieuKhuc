/// Lý do một thao tác trong ván bị từ chối. Mã ổn định để client dịch ra
/// thông báo, không phải chuỗi hiển thị.
enum RuleViolation {
  /// Bộ bài truyền vào không phải 52 lá khác nhau.
  invalidDeck,

  /// Số ghế hoặc ghế đi đầu không hợp lệ.
  invalidSeat,

  /// Ván đã kết thúc.
  gameEnded,

  /// Chưa tới lượt ghế này.
  notYourTurn,

  /// Thao tác không đúng bước của lượt (VD: đánh khi chưa bốc).
  wrongPhase,

  /// Nọc đã hết.
  deckEmpty,

  /// Không có lá nào vừa đánh để ăn.
  nothingToEat,

  /// Lá vừa đánh không tạo phỏm hợp lệ với bài trên tay.
  cannotEat,

  /// Lá không có trên tay.
  cardNotInHand,

  /// Một lá được dùng hai lần.
  duplicateCard,

  /// Không được đánh lá đã ăn.
  cannotDiscardEatenCard,

  /// Đánh lá này sẽ phá phỏm chứa lá đã ăn.
  discardBreaksEatenMeld,

  /// Các lá không tạo thành phỏm.
  invalidMeld,

  /// Có lá ăn chưa được hạ trong phỏm.
  eatenCardNotMelded,

  /// Một phỏm chứa hơn 1 lá ăn.
  twoEatenCardsInOneMeld,

  /// Gửi bài không hợp lệ.
  invalidSend,

  /// Không được gửi vào phỏm của chính mình.
  cannotSendToOwnMeld,

  /// Phải đánh 1 lá sau khi hạ.
  mustDiscard,

  /// Lá đánh ra không nằm trong phần bài còn lại.
  invalidDiscard,

  /// Không đủ điều kiện Ù khan.
  notEligibleForKhan,

  /// Không đủ điều kiện Ù.
  cannotDeclareU,
}
