part of couclient;

class SettingsWindow extends Modal
{
	String id = 'settingsWindow';

	// SETTINGS BOOLS
	bool _showJoinMessages = false, _playMentionSound = true, _closeTpWindowOnClick = true;

	SettingsWindow()
	{
		prepare();
		// SETTINGS WINDOW LISTENERS //
		view.settingsButton.onClick.listen((_) => this.open());

		//listen for onChange events so that clicking the label or the checkbox will call this method
		querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event)
		{
			CheckboxInputElement checkbox = event.target as CheckboxInputElement;
			if(checkbox.id == "ShowJoinMessages")
				setJoinMessagesVisibility(checkbox.checked);
			if(checkbox.id == "PlayMentionSound")
				setPlayMentionSound(checkbox.checked);
			if(checkbox.id == "CloseTpWindowOnClick")
				setcloseTpWindowOnClick(checkbox.checked);
		});

		//setup saved variables
		if (localStorage["showJoinMessages"] != null)
		{
			//ugly because there is no method to parse bool from string in dart?
			if(localStorage["showJoinMessages"] == "true")
				setJoinMessagesVisibility(true);
			else
				setJoinMessagesVisibility(false);
		}
		else
		{
			localStorage["showJoinMessages"] = "false";
			setJoinMessagesVisibility(false);
		}

		(querySelector("#ShowJoinMessages") as CheckboxInputElement).checked = joinMessagesVisibility;

		if(localStorage["playMentionSound"] != null)
		{
			if(localStorage["playMentionSound"] == "true")
				setPlayMentionSound(true);
			else
				setPlayMentionSound(false);
		}
		else
		{
			localStorage["playMentionSound"] = "true";
			setJoinMessagesVisibility(true);
		}

		(querySelector("#PlayMentionSound") as CheckboxInputElement).checked = playMentionSound;

		// set graphicsblur
		CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
		if(localStorage["GraphicsBlur"] != null)
		{
			if(localStorage["GraphicsBlur"] == "true")
				graphicsBlur.checked = true;
			else
				graphicsBlur.checked = false;
		}

		graphicsBlur.onChange.listen((_) => localStorage["GraphicsBlur"] = graphicsBlur.checked.toString());

		// set weather effects
		CheckboxInputElement weatherEffects = querySelector("#WeatherEffectsEnabled") as CheckboxInputElement;
		if(localStorage["WeatherEffectsEnabled"] != null) {
			if(localStorage["WeatherEffectsEnabled"] == "true") {
				weatherEffects.checked = true;
			} else {
				weatherEffects.checked = false;
			}
		}

		weatherEffects.onChange.listen((_) => WeatherManager.enabled = weatherEffects.checked);

		Element intensityGroup = querySelector("#WeatherEffectsIntensityGroup");
		if(localStorage["WeatherEffectsIntensity"] != null) {
			List<String> intensities = ["light","medium","heavy"];
			try {
				int index = int.parse(localStorage["WeatherEffectsIntensity"]);
				intensityGroup.attributes['selected'] = intensities[index];
			} catch(err) {
				print("Error setting intensity selection: $err");
			}
		}
		intensityGroup.on['core-activate'].listen((_) => WeatherManager.intensity = WeatherIntensity.values[intensityGroup.selectedIndex]);

		// set tp window closing

		CheckboxInputElement closeTpWindow = querySelector("#CloseTpWindowOnClick") as CheckboxInputElement;
		if(localStorage["closeTpWindowOnClick"] == null) {
			localStorage["closeTpWindowOnClick"] = "true";
		} else {
			if (localStorage["closeTpWindowOnClick"] == "true")
				closeTpWindow.checked = true;
			else
				closeTpWindow.checked = false;
		}

		//setup volume controls
		UrSlider musicSlider = querySelector("#MusicSlider") as UrSlider;
		UrSlider effectSlider = querySelector("#EffectSlider") as UrSlider;
		try
		{
			musicSlider.value = int.parse(localStorage['musicVolume']);
			effectSlider.value = int.parse(localStorage['effectsVolume']);
		}
		catch(e){}
		musicSlider.on['immediate-value-change'].listen((Event event)
		{
			num volume = musicSlider.value;
			audio.audioChannels['music'].gain = volume/100;
		});
		musicSlider.on['core-change'].listen((Event event)
		{
			num volume = musicSlider.value;
			localStorage['musicVolume'] = volume.toString();
		});
		effectSlider.on['immediate-value-change'].listen((Event event)
		{
			num volume = effectSlider.value;
			audio.audioChannels['soundEffects'].gain = volume/100;
		});
		effectSlider.on['core-change'].listen((Event event)
		{
			num volume = effectSlider.value;
			localStorage['effectsVolume'] = volume.toString();
		});
	}

	close() {
		querySelector("#${id}").hidden = true;
		toast("Settings saved");
	}

	/**
	* Determines if messages like "<user> has joined" are shown to the player.
	*
	* Sets the visibility of join messages to [visible]
	*/
	void setJoinMessagesVisibility(bool visible)
	{
		_showJoinMessages = visible;
		localStorage["showJoinMessages"] = visible.toString();
	}

	/**
    * Returns the visibility of messages like "<user> has joined"
    */
	bool get joinMessagesVisibility => _showJoinMessages;

	void setPlayMentionSound(bool enabled)
	{
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}

	bool get playMentionSound => _playMentionSound;

	/**
	 * Controls whether or not to close the teleport window after clicking a street
	 */

	bool get closeTpWindowOnClick => _closeTpWindowOnClick;

	void setcloseTpWindowOnClick(bool enabled) {
		_closeTpWindowOnClick = enabled;
		localStorage["closeTpWindowOnClick"] = enabled.toString();
	}
}
