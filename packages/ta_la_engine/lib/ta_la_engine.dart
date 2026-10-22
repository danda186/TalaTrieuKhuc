/// Luật chơi Tá lả (Phỏm): lá bài, phỏm, cạ, xếp bài, gợi ý hạ bài, điều
/// khiển ván, tính điểm theo base và quỹ tạm dừng.
///
/// Đặc tả luật: `docs/luat-choi-ta-la.md` ở thư mục gốc repo.
library;

export 'src/cards/deck.dart';
export 'src/cards/playing_card.dart';
export 'src/game/auto_play.dart';
export 'src/game/game_action.dart';
export 'src/game/game_engine.dart' show GameResult, TaLaEngine;
export 'src/game/game_state.dart';
export 'src/game/rule_violation.dart';
export 'src/match/pause_clock.dart';
export 'src/melds/arrangement.dart';
export 'src/melds/hand_sorter.dart';
export 'src/melds/lay_down_planner.dart';
export 'src/melds/meld.dart';
export 'src/result.dart';
export 'src/scoring/room_settings.dart';
export 'src/scoring/score_entry.dart';
export 'src/scoring/scoreboard.dart';
