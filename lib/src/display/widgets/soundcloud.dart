part of couclient;

class SoundCloudWidget {
	bool muted = false;

	Element musicPlayerElement, songElement, artistElement;
	AnchorElement linkElement;

	String SCsong = '-';
	String SCartist = '-';
	String SClink = '';

	SoundCloudWidget() {
		musicPlayerElement = querySelector('#SCwidget');
		songElement = musicPlayerElement.querySelector('.song');
		artistElement = musicPlayerElement.querySelector('.artist');
		linkElement = musicPlayerElement.querySelector('#SCLink');

		update();
		musicPlayerElement.hidden = new AudioElement().canPlayType('audio/mp3') == "";
	}

	void update() {
		// Update the soundcloud widget
		if (SCsong != songElement.text) {
			songElement.text = SCsong;
		}

		if (SCartist != artistElement.text) {
			artistElement.text = SCartist;
		}

		if (SClink != linkElement.href) {
			linkElement.href = SClink;
		}

		window.requestAnimationFrame((_) => this.update());
	}
}
