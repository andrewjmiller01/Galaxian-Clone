
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer, chargeShotPlayer, monsterRocketPlayer, damagePlayer;

  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("explode.wav", 1024); 
    popPlayer = minimplay.loadSample("pop.wav", 1024);
    chargeShotPlayer = minimplay.loadSample("chargeshot.wav", 1024);
    monsterRocketPlayer = minimplay.loadSample("laserBlaster.wav", 1024);
    damagePlayer = minimplay.loadSample("damage.wav", 1024);
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    popPlayer.trigger();
  }
  
  void playChargeShot(){
    chargeShotPlayer.trigger();
  }
  
  void playMonsterRocket(){
    monsterRocketPlayer.trigger();
  }
  
  void playDamage(){
    damagePlayer.trigger();
  }
}