part of couclient;

class VolumeSliderWidget
{
	bool muted = false;
	Element volumeGlyph = querySelector('#volumeGlyph');
	Element volumeIcon = querySelector('#volumeGlyph > i');
	bool doToasts = false;

	VolumeSliderWidget()
	{
		//load current mute state
		if(localStorage.containsKey('mute') && localStorage['mute'] == 'true')
		{
			muted = true;
			volumeIcon.classes
	            ..remove('fa-volume-up')
	            ..add('fa-volume-off');
		}

		//click toggles mute
		volumeGlyph.onClick.listen((_)
		{
			if(muted == true) {
				muted = false;
				if (doToasts) {
					new Toast("Sound unmuted");
				}
			} else {
				muted = true;
				if (doToasts) {
					new Toast("Sound muted");
				}
			}

			update();
		});
	}

	update()
	{
    	// Update the audio icon
		if (muted == true)
		{
			volumeIcon.classes
				..remove('fa-volume-up')
				..add('fa-volume-off');
		}
		else
		{
			volumeIcon.classes
				..remove('fa-volume-off')
				..add('fa-volume-up');
		}

		// Updates the stored mute state
		localStorage['mute'] = muted.toString();

		// Update the audio mute state
		audio.setMute(muted);
	}
}
