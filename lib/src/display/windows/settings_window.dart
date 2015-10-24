part of couclient;

class SettingsWindow extends Modal {
	String id = 'settingsWindow';

	// SETTINGS BOOLS
	bool _showJoinMessages = false, _playMentionSound = true;

	SettingsWindow() {
		prepare();
		// SETTINGS WINDOW LISTENERS //

		//listen for onChange events so that clicking the label or the checkbox will call this method
		querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event) {
			PaperToggleButton checkbox = event.target as PaperToggleButton;
			if(checkbox.id == "ShowJoinMessages") {
				setJoinMessagesVisibility(checkbox.checked);
			}
			if(checkbox.id == "PlayMentionSound") {
				setPlayMentionSound(checkbox.checked);
			}
		});

		//setup saved variables
		if(localStorage["showJoinMessages"] != null) {
			//ugly because there is no method to parse bool from string in dart?
			if(localStorage["showJoinMessages"] == "true") {
				setJoinMessagesVisibility(true);
			} else {
				setJoinMessagesVisibility(false);
			}
		} else {
			localStorage["showJoinMessages"] = "false";
			setJoinMessagesVisibility(false);
		}

		(querySelector("#ShowJoinMessages") as PaperToggleButton).checked = joinMessagesVisibility;

		if(localStorage["playMentionSound"] != null) {
			if(localStorage["playMentionSound"] == "true") {
				setPlayMentionSound(true);
			} else {
				setPlayMentionSound(false);
			}
		} else {
			localStorage["playMentionSound"] = "true";
			setJoinMessagesVisibility(true);
		}

		(querySelector("#PlayMentionSound") as PaperToggleButton).checked = playMentionSound;

		// set graphicsblur
		PaperToggleButton graphicsBlur = querySelector("#GraphicsBlur") as PaperToggleButton;
		if(localStorage["GraphicsBlur"] != null) {
			if(localStorage["GraphicsBlur"] == "true") {
				graphicsBlur.checked = true;
			} else {
				graphicsBlur.checked = false;
			}
		}

		graphicsBlur.onChange.listen((_) => localStorage["GraphicsBlur"] = graphicsBlur.checked.toString());

		// set weather effects
		PaperToggleButton weatherEffects = querySelector("#WeatherEffectsEnabled") as PaperToggleButton;
		if(localStorage["WeatherEffectsEnabled"] != null) {
			if(localStorage["WeatherEffectsEnabled"] == "true") {
				weatherEffects.checked = true;
				querySelector("#weatherIntensity").classes.add("visible");
			} else {
				weatherEffects.checked = false;
				querySelector("#weatherIntensity").classes.remove("visible");
			}
		} else {
			weatherEffects.checked = true;
			querySelector("#weatherIntensity").classes.add("visible");
		}

		weatherEffects.onChange.listen((_) {
			WeatherManager.enabled = weatherEffects.checked;
			if (weatherEffects.checked) {
				querySelector("#weatherIntensity").classes.add("visible");
			} else {
				querySelector("#weatherIntensity").classes.remove("visible");
			}
		});

		PaperRadioGroup intensityGroup = querySelector("#WeatherEffectsIntensityGroup") as PaperRadioGroup;
		if(localStorage["WeatherEffectsIntensity"] != null) {
			List<String> intensities = ["light", "normal"];
			try {
				int index = int.parse(localStorage["WeatherEffectsIntensity"]);
				intensityGroup.selected = intensities[index];
			} catch(err) {
				print("Error setting intensity selection: $err");
			}
		}
		intensityGroup.on['core-activate'].listen((_) => WeatherManager.intensity = WeatherIntensity.values[intensityGroup.selectedIndex]);

		//setup volume controls
		UrSlider musicSlider = querySelector("#MusicSlider") as UrSlider;
		UrSlider effectSlider = querySelector("#EffectSlider") as UrSlider;
		try {
			musicSlider.value = int.parse(localStorage['musicVolume']);
			effectSlider.value = int.parse(localStorage['effectsVolume']);
		} catch(e) {
		}
		musicSlider.on['immediate-value-change'].listen((Event event) {
			num volume = musicSlider.value;
			audio.audioChannels['music'].gain = volume / 100;
		});
		musicSlider.on['core-change'].listen((Event event) {
			num volume = musicSlider.value;
			localStorage['musicVolume'] = volume.toString();
		});
		effectSlider.on['immediate-value-change'].listen((Event event) {
			num volume = effectSlider.value;
			audio.audioChannels['soundEffects'].gain = volume / 100;
		});
		effectSlider.on['core-change'].listen((Event event) {
			num volume = effectSlider.value;
			localStorage['effectsVolume'] = volume.toString();
		});

		setupUiButton(view.settingsButton);
		setupKeyBinding("Settings");
	}

	@override
	close() {
		querySelector("#${id}").hidden = true;
		toast("Settings saved");
		super.close();
	}

	/**
	 * Determines if messages like "<user> has joined" are shown to the player.
	 *
	 * Sets the visibility of join messages to [visible]
	 */
	void setJoinMessagesVisibility(bool visible) {
		_showJoinMessages = visible;
		localStorage["showJoinMessages"] = visible.toString();
	}

	/**
	 * Returns the visibility of messages like "<user> has joined"
	 */
	bool get joinMessagesVisibility => _showJoinMessages;

	void setPlayMentionSound(bool enabled) {
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}

	bool get playMentionSound => _playMentionSound;
}