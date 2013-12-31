part of coUclient;
// Handles all the engine's audio needs

//respect previous volume setting (if any)
String prevVolume = localStorage['prevVolume'];
String isMuted = localStorage['isMuted'];

init_audio()
{
	if(prevVolume != null)
	{
		setVolume(prevVolume);
		(querySelector('#VolumeSlider') as InputElement).value = prevVolume;
		querySelector('#rangevalue').innerHtml = prevVolume;
	}
	else
	{
		prevVolume = '50';
		localStorage['prevVolume'] = '50';
	}
	if(isMuted == null)
	{
		isMuted = '0';
		localStorage['isMuted'] = '0';
	}
	ui._setMute(isMuted);
}

Future load_audio()
{
  final c = new Completer();
  // Load all our user interface sounds.
  assets.loadPack('sounds', './assets/sounds.pack')// These will just be non-music sounds.
  	.then((AssetPack sounds) 
	{
		// Load all our SoundCloud songs and store the resulting SCsongs in the jukebox
		//TODO: Someday we may want to do this individually when a street loads, rather than all at once.
		List songsToLoad = new List();
		for (String song in sounds['music'].keys)
		{
			Future future = ui.sc.load(sounds['music'][song]['scid']).then((s)=>ui.jukebox[song] = s);
			songsToLoad.add(future);
		}
		c.complete(Future.wait(songsToLoad));
	});
	return c.future;
}