part of couclient;

class HomeStreet {
	static Future<String> getForPlayer([String username]) async {
		String result = await HttpRequest.getString(
			'${Configs.http}//${Configs.utilServerAddress}/homestreet/get/${username ?? game.username}');
		return (result.length == 0 ? null : result);
	}

	static Future<bool> setForSelf(String tsid) async {
		String result = await HttpRequest.getString(
			'${Configs.http}//${Configs.utilServerAddress}/homestreet/set/${game.username}/$tsid');
		return result == 'true';
	}
}