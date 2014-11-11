part of couclient;

class SoundCloudWidget {
  bool muted = false;

  // Music Meter Variables
  Element titleElement = querySelector('#trackTitle');
  Element artistElement = querySelector('#trackArtist');
  AnchorElement SClinkElement = querySelector('#SCLink');

  String SCsong = '-';
  String SCartist = '-';
  String SClink = '';

  SoundCloudWidget() {
    update();
  }
  update() {
    // Update all audioElements to the correct volume
    for (AudioElement audio in querySelectorAll('audio')) {
      if (audio.volume != view.slider.volume / 100) audio.volume = view.slider.volume / 100;
    }

    // Update the soundcloud widget
    if (SCsong != titleElement.text) titleElement.text = SCsong;
    if (SCartist != artistElement.text) artistElement.text = SCartist;
    if (SClink != SClinkElement.href) SClinkElement.href = SClink;

    window.requestAnimationFrame((_) => this.update());
  }

}