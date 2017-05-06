library configs;

import 'dart:html';
import 'dart:async';

class Configs {
	static String baseAddress, utilServerAddress, websocketServerAddress, authAddress, authWebsocket;
	static String http = baseAddress.contains('localhost') ? 'http:' : 'https:';
	static String ws = baseAddress.contains('localhost') ? 'ws:' : 'wss:';
	static final int clientVersion = 147;
	static bool testing;

	static Future init() async {
		baseAddress = (await HttpRequest.getString('server_domain.txt')).trim();
		utilServerAddress = '$baseAddress:8181';
		websocketServerAddress = '$baseAddress:8282';
		authAddress = '$baseAddress:8383';
		authWebsocket = '$baseAddress:8484';

		if (Configs.baseAddress == "localhost" || Configs.baseAddress == "robertmcdermot.com") {
			testing = true;
		} else {
			testing = false;
		}

		//set the ur-login components addresses
		Element urLogin = querySelector('ur-login');
		urLogin.attributes['server'] = '$http//$authAddress';
		urLogin.attributes['websocket'] = '$ws//authWebsocket';
		urLogin.attributes['base'] = 'blinding-fire-920'; //TODO have the server provide this

		//same for auction-house
		Element auctionHouse = querySelector('auction-house');
		auctionHouse.attributes['serverAddress'] = '$http//$utilServerAddress';
	}

	static String proxyImage(String imageUrl) {
		return 'https://childrenofur.com/assets/streets/?url=$imageUrl';
	}
}
