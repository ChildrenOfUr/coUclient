part of couclient;

class SettingsWindow extends Modal {
	String id = 'settingsWindow';

	// SETTINGS BOOLS
	bool _showJoinMessages = false, _playMentionSound = true;
	bool duplicateKeysFound = false;

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
			} catch (err) {
				logmessage("Error setting intensity selection: $err");
			}
		}
		intensityGroup.on['core-activate'].listen((_) => WeatherManager.intensity = WeatherIntensity.values[intensityGroup.selectedIndex]);

		// set dark ui
		PaperToggleButton darkUi = querySelector("#DarkMode") as PaperToggleButton;
		if(localStorage["DarkMode"] != null) {
			DarkUI.darkMode = darkUi.checked = (localStorage["DarkMode"] == "true");
		}

		darkUi.onChange.listen((_) {
			localStorage["DarkMode"] = darkUi.checked.toString();
			DarkUI.darkMode = darkUi.checked;
		});

		// set dark ui auto mode
		PaperToggleButton darkUiAuto = querySelector("#DarkModeAuto") as PaperToggleButton;
		if(localStorage["DarkModeAuto"] != null) {
			DarkUI.autoMode = darkUiAuto.checked = (localStorage["DarkModeAuto"] == "true");
			darkUi.disabled = darkUiAuto.checked;
			DarkUI.update();
		}

		darkUiAuto.onChange.listen((_) {
			localStorage["DarkModeAuto"] = darkUiAuto.checked.toString();
			DarkUI.autoMode = darkUiAuto.checked;
			darkUi.disabled = darkUiAuto.checked;
			if (!darkUiAuto.checked) {
				DarkUI.darkMode = darkUi.checked;
			}
			DarkUI.update();
		});

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
	open({bool ignoreKeys: false}) {
		checkDuplicateKeyAssignments();
		super.open(ignoreKeys: ignoreKeys);
	}

	@override
	close() {
		querySelector("#${id}").hidden = true;
		if (duplicateKeysFound) {
			new Toast(
				"Preferences saved, but you have multiple controls bound to the same key, and this may cause problems! Click here to fix it.",
				onClick: (_) {
					open();
				}
			);
		} else {
			new Toast("Preferences saved");
		}
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
		if(enabled) {
			Notification.requestPermission();
		}
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}

	bool get playMentionSound => _playMentionSound;

	void checkDuplicateKeyAssignments() {
		// <kbd> elements in the settings window
		ElementList elements = displayElement.querySelectorAll("kbd");

		// Returns number of other rows that have the specified key
		// (The same key can be assigned to both the primary and secondary controls and won't be counted)
		bool _keyDuplicated(String key) {
			// Controls bound to this key
			List<Element> controls = elements.where((Element kbd) {
				return kbd.text == key;
			}).toList();

			if (controls.length <= 1) {
				// Not duplicated
				return false;
			} else if (controls.length == 2) {
				// Primary + secondary => not duplicated
				return !(controls[0].parent == controls[1].parent);
			} else {
				// Duplicated
				return true;
			}
		}

		// Mark duplicates
		int found = 0;
		elements.forEach((Element kbd) {
			if (_keyDuplicated(kbd.text)) {
				// This key is assigned in a place other than the current control
				kbd.classes.add("duplicate-key");
				found++;
			} else {
				// This key is not assigned to any other controls
				kbd.classes.remove("duplicate-key");
			}
		});

		duplicateKeysFound = (found > 0);
	}
}
