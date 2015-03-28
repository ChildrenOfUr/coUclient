library configs;

import 'dart:html';
import 'dart:async';

class Configs
{
	static String baseAddress, utilServerAddress, websocketServerAddress, authAddress, authWebsocket;
    static double clientVersion = 0.12;

    static Future init() async
    {
    	baseAddress = (await HttpRequest.getString('server_domain.txt')).trim();
    	utilServerAddress = '$baseAddress:8181';
        websocketServerAddress = '$baseAddress:8282';
        authAddress = '$baseAddress:8383';
        authWebsocket = '$baseAddress:8484';
    }
}