library configs;

import 'dart:html';
import 'dart:async';

class Configs
{
	static String baseAddress, utilServerAddress, websocketServerAddress, authAddress;
    static double clientVersion = 0.12;

    static Future init() async
    {
    	baseAddress = await HttpRequest.getString('server_domain.txt');
    	utilServerAddress = '$baseAddress:8181'.trim().replaceAll('\n', '');
        websocketServerAddress = '$baseAddress:8282'.trim().replaceAll('\n', '');
        authAddress = '$baseAddress:8383'.trim().replaceAll('\n', '');
    }
}