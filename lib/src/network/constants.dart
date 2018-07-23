part of couclient;

@JsonSerializable()
class Constants {
	static Future<Constants> download() async {
		String json = await HttpRequest.getString("${Configs.http}//${Configs.utilServerAddress}/constants/json");
		return Constants.fromJson(jsonDecode(json));
	}

	Constants();

	factory Constants.fromJson(Map<String, dynamic> json) => _$ConstantsFromJson(json);

	Map<String, dynamic> toJson() => _$ConstantsToJson(this);

	int changeUsernameCost;

	int quoinLimit;

	num quoinMultiplierLimit;
}
