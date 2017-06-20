import 'dart:async';
import 'dart:io';
import 'package:barback/barback.dart';

class ConfigsTransformer extends Transformer
{
	ConfigsTransformer.asPlugin(BarbackSettings);

	@override
	String get allowedExtensions => '.html';
//	@override
//	Future<bool> isPrimary(AssetId id) {
//		bool neededFile = false;
//		if(id.path.endsWith('index.html') || id.path.endsWith('auctionwindow.html')) {
//			neededFile = true;
//		}
//
//		return new Future.value(neededFile);
//	}

	@override
	Future apply(Transform transform) async	{
		File file = new File('web/server_domain.txt');
		String baseAddress = await file.readAsString();

		String utilServerAddress = '$baseAddress:8181';
		String authAddress = '$baseAddress:8383';
		String authWebsocket = '$baseAddress:8484';

		String newContent = await transform.primaryInput.readAsString();

		String prefix = baseAddress.contains('localhost') ? 'http://' : 'https://';
		String wsPrefix = baseAddress.contains('localhost') ? 'ws://' : 'wss://';

		if(newContent.contains('<ur-login>')) {
			//set the ur-login components addresses
			newContent = newContent.replaceAll('<ur-login>','<ur-login server="$prefix$authAddress" websocket="$wsPrefix$authWebsocket" base="blinding-fire-920">');
		}
		if(newContent.contains('<auction-house>')) {
			//same for auction-house
			newContent = newContent.replaceAll('<auction-house>','<auction-house serverAddress="$prefix$utilServerAddress">');
		}
		if(newContent.contains('<ur-meters>')) {
			newContent = newContent.replaceAll('<ur-meters>','<ur-meters serverAddress="$prefix$utilServerAddress">');
		}
		if(newContent.contains('></ur-mailbox>')) {
			//this one is different because of the dnd-retarget attribute
			newContent = newContent.replaceAll('></ur-mailbox>',' serverAddress="$prefix$utilServerAddress"></ur-mailbox>');
		}

		AssetId id = transform.primaryInput.id;
		transform.addOutput(new Asset.fromString(id, newContent));
	}
}