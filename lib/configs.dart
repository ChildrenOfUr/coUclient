library configs;

import 'dart:html';
import 'dart:async';

class Configs {
	static String baseAddress, utilServerAddress, websocketServerAddress, authAddress, authWebsocket;
	static double clientVersion = 0.14;
	static bool testing;

	static Future init() async
	{
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
		String prefix = baseAddress.contains('localhost')?'http://':'https://';
		Element urLogin = querySelector('ur-login');
		urLogin.attributes['server'] = prefix+authAddress;
		urLogin.attributes['websocket'] = 'ws://'+authWebsocket;
		urLogin.attributes['base'] = 'blinding-fire-920'; //TODO have the server provide this

		//same for auction-house
		Element auctionHouse = querySelector('auction-house');
		auctionHouse.attributes['serverAddress'] = 'http://$utilServerAddress';
	}
}