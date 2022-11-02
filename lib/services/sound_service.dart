import 'package:dojo_app/services/play_audio_service.dart';

class SoundService {
  /// Constructor
  SoundService() {
    //
  }

  static pressPlay() {
    String audioToPlay = 'assets/audio/sfx-press-play-01.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static buttonClickOne() {
    String audioToPlay = 'assets/audio/button-click-02.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static timerExpires() {
    String audioToPlay = 'assets/audio/basketball_buzzer.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static goGoGo() {
    String audioToPlay = 'assets/audio/assets/audio/countdown_go_beep.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static trumpetSong() {
    String audioToPlay = 'assets/audio/trumpet_songB.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static cheer() {
    String audioToPlay = 'assets/audio/cheer1.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static roundPerfect() {
    String audioToPlay = 'assets/audio/round-perfect-01.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static lunaTalk() {
    String audioToPlay = 'assets/audio/luna-talk-01.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static popBonus() {
    String audioToPlay = 'assets/audio/pop02.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static youWin() {
    String audioToPlay = 'assets/audio/SFX_you_winB.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static resourceAddedToStack() {
    String audioToPlay = 'assets/audio/swap-resource02.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static singleCoin() {
    String audioToPlay = 'assets/audio/one-coin-02.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static slot1() {
    String audioToPlay = 'assets/audio/slot-01.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static slot2() {
    String audioToPlay = 'assets/audio/slot-02.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static slot3() {
    String audioToPlay = 'assets/audio/slot-03.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static roundSuccess() {
    String audioToPlay = 'assets/audio/round-success-01.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static f1Beep() {
    String audioToPlay = 'assets/audio/f1_beep.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static countdownOne() {
    String audioToPlay = 'assets/audio/countdown_1.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static countdownTwo() {
    String audioToPlay = 'assets/audio/countdown_2.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static countdownThree() {
    String audioToPlay = 'assets/audio/countdown_3.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }

  static levelUnlock() {
    String audioToPlay = 'assets/audio/SFX_unlock_levelB.mp3';
    PlayAudio soundSFX = PlayAudio(audioToPlay: audioToPlay);
    soundSFX.play();
  }
}

