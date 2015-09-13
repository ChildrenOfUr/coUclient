part of couclient;

class SoundCloudWidget {
  bool muted = false;

  Element musicPlayerElement = querySelector('ur-musicplayer');


  String SCsong = '-';
  String SCartist = '-';
  String SClink = '';

  SoundCloudWidget() {
    update();
	  if (new AudioElement().canPlayType('audio/mp3') == "") {
		  musicPlayerElement.hidden = true;
	  } else {
		  musicPlayerElement.hidden = false;
	  }
  }
  update() {

    // Update the soundcloud widget
    if (SCsong != musicPlayerElement.attributes['song'])
      musicPlayerElement.attributes['song'] = SCsong;
    if (SCartist != musicPlayerElement.attributes['artist'])
      musicPlayerElement.attributes['artist'] = SCartist;
    if (SClink != musicPlayerElement.attributes['link'])
      musicPlayerElement.attributes['link'] = SClink;

    window.requestAnimationFrame((_) => this.update());
  }

}