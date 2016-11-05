part of couclient;

void sendLeftMessage(String streetName) {
	if (streetSocket != null && streetSocket.readyState == WebSocket.OPEN) {
		Map map = new Map();
		map["username"] = game.username;
		map["streetName"] = streetName;
		map["message"] = "left";
		streetSocket.send(JSON.encode(map));
	}
}

void sendJoinedMessage(String streetName, [String tsid]) {
	if (joined != streetName && streetSocket != null && streetSocket.readyState == WebSocket.OPEN) {
		Map map = new Map();
		map['clientVersion'] = Configs.clientVersion;
		map["username"] = game.username;
		map['email'] = game.email;
		map["streetName"] = streetName;
		map["tsid"] = tsid == null ? currentStreet.streetData['tsid'] : tsid;
		map["message"] = "joined";
		map['firstConnect'] = firstConnect;
		streetSocket.send(JSON.encode(map));
		joined = streetName;
		if (firstConnect) {
			firstConnect = false;
		}
	}
}

_updateChatBubble(Map map, Entity entity) {
	if (entity == null) {
		return;
	}

	if (map["bubbleText"] != null) {
		String bubbleText = map['bubbleText'].split('|||')[0];
		String buttons = map['bubbleText'].split('|||')[1];

		if (entity.chatBubble == null) {
			String heightString = entity.canvas.height.toString();
			String translateY = entity.canvas.attributes['translateY'];

			if (entity.canvas.attributes['actualHeight'] != null) {
				heightString = entity.canvas.attributes['actualHeight'];
				num diff = entity.canvas.height - num.parse(heightString);
				translateY = (num.parse(translateY) + diff).toString();
			}

			DivElement bubbleParent = new DivElement()
				..style.position = 'absolute'
				..style.width = entity.canvas.width.toString() + 'px'
				..style.height = heightString + 'px'
				..style.transform =
					'translateX(${map['x']}px) translateY(${translateY}px)';
			view.playerHolder.append(bubbleParent);
			entity.chatBubble = new ChatBubble(
				bubbleText, entity, bubbleParent,
				autoDismiss: false, removeParent: true, gains: map['gains'],
				buttons: buttons);

			String type = entity.canvas.attributes['type'];
			Chat.localChat.addMessage('($type)', bubbleText,
				overrideUsernameLink: 'http://childrenofur.com/encyclopedia/#/entity/${type.replaceAll(' ', '')}');
		}

		entity.chatBubble.update(1.0);
	} else if (entity.chatBubble != null) {
		entity.chatBubble.removeBubble();
	}
}