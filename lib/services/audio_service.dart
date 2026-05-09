import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  // SOM AO CONCLUIR TAREFA
  static Future<void> playTaskComplete() async {
    await _player.play(
      AssetSource('sounds/task_complete.mp3'),
    );
  }

  // SOM AO BEBER ÁGUA
  static Future<void> playWater() async {
    await _player.play(
      AssetSource('sounds/water.mp3'),
    );
  }

  // SOM AO RESGATAR RECOMPENSA
  static Future<void> playRewardRedeemed() async {
    await _player.play(
      AssetSource('sounds/reward.mp3'),
    );
  }

  // SOM DE CLIQUE
  static Future<void> playClick() async {
    await _player.play(
      AssetSource('sounds/click.mp3'),
    );
  }
}
