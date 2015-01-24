part of couclient;

class SettingsWindow extends Modal {
  String id = 'settingsWindow';

  // SETTINGS BOOLS
  bool _showJoinMessages = false,
      _playMentionSound = true;

  SettingsWindow() {

    prepare();
    // SETTINGS WINDOW LISTENERS //
    view.settingsButton.onClick.listen((_) {
      this.open();
    });
    //listen for onChange events so that clicking the label or the checkbox will call this method
    querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event) {
      CheckboxInputElement checkbox = event.target as CheckboxInputElement;
      if (checkbox.id == "ShowJoinMessages") setJoinMessagesVisibility(checkbox.checked);
      if (checkbox.id == "PlayMentionSound") setPlayMentionSound(checkbox.checked);
    });

    //setup saved variables
    if (localStorage["showJoinMessages"] != null) {
      //ugly because there is no method to parse bool from string in dart?
      if (localStorage["showJoinMessages"] == "true") setJoinMessagesVisibility(true); else setJoinMessagesVisibility(false);
    } else {
      localStorage["showJoinMessages"] = "false";
      setJoinMessagesVisibility(false);
    }
    querySelectorAll("#ShowJoinMessages").forEach((Element element) {
      (element as CheckboxInputElement).checked = getJoinMessagesVisibility();
    });

    if (localStorage["playMentionSound"] != null) {
      if (localStorage["playMentionSound"] == "true") setPlayMentionSound(true); else setPlayMentionSound(false);
    } else {
      localStorage["playMentionSound"] = "true";
      setJoinMessagesVisibility(true);
    }

    querySelectorAll("#PlayMentionSound").forEach((Element element) {
      (element as CheckboxInputElement).checked = getPlayMentionSound();
    });

    // set graphicsblur
    CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
    if (localStorage["GraphicsBlur"] != null) {
      if (localStorage["GraphicsBlur"] == "true") graphicsBlur.checked = true; else graphicsBlur.checked = false;
    }
    graphicsBlur.onChange.listen((_) {
      localStorage["GraphicsBlur"] = graphicsBlur.checked.toString();
    });

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
  bool getJoinMessagesVisibility() => _showJoinMessages;

  void setPlayMentionSound(bool enabled) {
    _playMentionSound = enabled;
    localStorage["playMentionSound"] = enabled.toString();
  }

  bool getPlayMentionSound() => _playMentionSound;




}
