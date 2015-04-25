library configs;

import 'dart:html';
import 'dart:async';

class Configs {
	static String baseAddress, utilServerAddress, websocketServerAddress, authAddress, authWebsocket;
	static double clientVersion = 0.13;

	static Future init() async
	{
		baseAddress = (await HttpRequest.getString('server_domain.txt')).trim();
		utilServerAddress = '$baseAddress:8181';
		websocketServerAddress = '$baseAddress:8282';
		authAddress = '$baseAddress:8383';
		authWebsocket = '$baseAddress:8484';

		//set the ur-login components addresses
		String prefix = baseAddress.contains('localhost')?'http://':'https://';
		Element urLogin = querySelector('ur-login');
		urLogin.attributes['serveraddress'] = prefix+authAddress;
		urLogin.attributes['serverwebsocket'] = 'ws://'+websocketServerAddress;

		//same for auction-house
		Element auctionHouse = querySelector('auction-house');
		auctionHouse.attributes['serverAddress'] = 'http://$utilServerAddress';
	}
}