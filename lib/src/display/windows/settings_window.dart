part of couclient;

class SettingsWindow extends Modal {
	String id = 'settingsWindow';

	// SETTINGS BOOLS
	bool _showJoinMessages = false, _playMentionSound = true, _logNpcMessages = true;
	bool duplicateKeysFound = false;

	SettingsWindow() {
		prepare();
		// SETTINGS WINDOW LISTENERS //

		//listen for onChange events so that clicking the label or the checkbox will call this method
		querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event) {
			CheckboxInputElement checkbox = event.target as CheckboxInputElement;
			if(checkbox.id == "ShowJoinMessages") {
				joinMessagesVisibility = checkbox.checked;
			}
			if(checkbox.id == "PlayMentionSound") {
				playMentionSound = checkbox.checked;
			}
		});

		//setup saved variables
		if(localStorage["showJoinMessages"] != null) {
			//ugly because there is no method to parse bool from string in dart?
			if(localStorage["showJoinMessages"] == "true") {
				joinMessagesVisibility = true;
			} else {
				joinMessagesVisibility = false;
			}
		} else {
			localStorage["showJoinMessages"] = "false";
			joinMessagesVisibility = false;
		}

		(querySelector("#ShowJoinMessages") as CheckboxInputElement).checked = joinMessagesVisibility;

		if(localStorage["playMentionSound"] != null) {
			if(localStorage["playMentionSound"] == "true") {
				playMentionSound = true;
			} else {
				playMentionSound = false;
			}
		} else {
			localStorage["playMentionSound"] = "true";
			playMentionSound = true;
		}

		(querySelector("#PlayMentionSound") as CheckboxInputElement).checked = playMentionSound;

		if(localStorage["logNpcMessages"] != null) {
			if(localStorage["logNpcMessages"] == "true") {
				logNpcMessages = true;
			} else {
				logNpcMessages = false;
			}
		} else {
			localStorage["logNpcMessages"] = "true";
			logNpcMessages = true;
		}

		(querySelector("#LogNPCMessages") as CheckboxInputElement).checked = playMentionSound;

		// set graphicsblur
		CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
		if(localStorage["GraphicsBlur"] != null) {
			if(localStorage["GraphicsBlur"] == "true") {
				graphicsBlur.checked = true;
			} else {
				graphicsBlur.checked = false;
			}
		}

		graphicsBlur.onChange.listen((_) => localStorage["GraphicsBlur"] = graphicsBlur.checked.toString());

		// set weather effects
		CheckboxInputElement weatherEffects = querySelector("#WeatherEffectsEnabled") as CheckboxInputElement;
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

		CheckboxInputElement lightWeatherEffects = querySelector("#WeatherEffectsIntensity");
		if (localStorage["LightWeatherEffects"] != null) {
			try {
				lightWeatherEffects.checked = localStorage["LightWeatherEffects"] == "true";
				WeatherManager.intensity = lightWeatherEffects.checked ? WeatherIntensity.LIGHT : WeatherIntensity.NORMAL;
			} catch (err) {
				logmessage("Error setting weather effects intensity intensity: $err");
			}
		}
		lightWeatherEffects.onChange.listen((_) {
			WeatherManager.intensity = lightWeatherEffects.checked ? WeatherIntensity.LIGHT : WeatherIntensity.NORMAL;
			localStorage["LightWeatherEffects"] = lightWeatherEffects.checked.toString();
		});

		// set dark ui
		CheckboxInputElement darkUi = querySelector("#DarkMode") as CheckboxInputElement;
		if(localStorage["DarkMode"] != null) {
			DarkUI.darkMode = darkUi.checked = (localStorage["DarkMode"] == "true");
		}

		darkUi.onChange.listen((_) {
			localStorage["DarkMode"] = darkUi.checked.toString();
			DarkUI.darkMode = darkUi.checked;
		});

		// set dark ui auto mode
		CheckboxInputElement darkUiAuto = querySelector("#DarkModeAuto") as CheckboxInputElement;
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
		RangeInputElement musicSlider = querySelector("#MusicSlider") as RangeInputElement;
		RangeInputElement effectSlider = querySelector("#EffectSlider") as RangeInputElement;
		RangeInputElement weatherSlider = querySelector("#WeatherSlider") as RangeInputElement;
		try {
			musicSlider.value = localStorage['musicVolume'];
			effectSlider.value = localStorage['effectsVolume'];
			weatherSlider.value = localStorage['weatherVolume'];
		} catch(_) { }

		musicSlider.onChange.listen((Event event) {
			num volume = num.parse(musicSlider.value);
			audio.audioChannels['music'].gain = volume / 100;
			localStorage['musicVolume'] = volume.toString();
		});

		effectSlider.onChange.listen((Event event) {
			num volume = num.parse(effectSlider.value);
			audio.audioChannels['soundEffects'].gain = volume / 100;
			localStorage['effectsVolume'] = volume.toString();
		});

		weatherSlider.onChange.listen((Event event) {
			num volume = num.parse(weatherSlider.value);
			audio.audioChannels['weather'].gain = volume / 100;
			localStorage['weatherVolume'] = weatherSlider.value.toString();
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
	void set joinMessagesVisibility(bool visible) {
		_showJoinMessages = visible;
		localStorage["showJoinMessages"] = visible.toString();
	}

	/**
	 * Returns the visibility of messages like "<user> has joined"
	 */
	bool get joinMessagesVisibility => _showJoinMessages;

	///

	void set playMentionSound(bool enabled) {
		if(enabled) {
			Notification.requestPermission();
		}
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}

	bool get playMentionSound => _playMentionSound;

	///

	void set logNpcMessages(bool enabled) {
		_logNpcMessages = enabled;
		localStorage["logNpcMessages"] = enabled.toString();
	}

	bool get logNpcMessages => _logNpcMessages;

	///

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
