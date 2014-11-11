part of couclient;

class VolumeSlider {
  int volume;
  bool muted;

  Element volumeGlyph = querySelector('#volumeGlyph');
  InputElement volumeSlider = querySelector('#volumeSlider *');

  VolumeSlider() {

    // Load saved volume level
    if (localStorage['volume'] != null) {
      volume = int.parse(localStorage['volume']);
    } else volume = 10;
    localStorage['volume'] = volume.toString();
    volumeSlider.value = volume.toString();

    // Controls the volume slider and glyph
    volumeGlyph.onClick.listen((_) {
      if (muted == true) {
        volume = int.parse(localStorage['volume']);
        muted = false;
        volumeSlider.value = volume.toString();
      } else if (muted == false) {
        localStorage['volume'] = volume.toString();
        muted = true;
        volumeSlider.value = '0';
      }
      update();
    });

    volumeSlider.onMouseMove.listen((_) {
      update();
    });
  }

  update() {
    // Update the volume slider
    if (int.parse(volumeSlider.value) == 0) muted = true; else muted = false;
    if (volume != int.parse(volumeSlider.value)) {
      volume = int.parse(volumeSlider.value);

      // Update the audio icon
      if (muted == true && volumeGlyph.classes.contains('fa-volume-up')) {
        volumeGlyph.classes
            ..remove('fa-volume-up')
            ..add('fa-volume-off');
      }
      if (muted == false && volumeGlyph.classes.contains('fa-volume-off')) {
        volumeGlyph.classes
            ..remove('fa-volume-off')
            ..add('fa-volume-up');
      }
    }

    // Updates the stored volume level
    if (volume != localStorage['volume'] && muted == false) localStorage['volume'] = volume.toString();

  }


}
