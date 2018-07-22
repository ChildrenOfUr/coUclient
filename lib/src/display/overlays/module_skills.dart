part of couclient;

abstract class Skills {
	static List<Map<String, dynamic>> data;

	static Future<String> loadData() async {
		String json = await HttpRequest.getString(
			"${Configs.http}//${Configs.utilServerAddress}/skills/get/${game.email}"
		);
		data = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
		return json;
	}

	static Map<String, dynamic> getSkill(String id) {
		List<Map<String, dynamic>> skills = data.where((Map skill) {
			return skill["id"] == id;
		}).toList();

		return (skills.length > 0 ? skills.single : null);
	}
}

class SkillIndicator {
	static List<SkillIndicator> INSTANCES = [];

	Map skill;
	Element parent, fill;

	SkillIndicator(String skillId) {
		// Remove old indicators (if any)
		INSTANCES.forEach((SkillIndicator si) => si.close());

		Skills.loadData().then((_) {
			skill = Skills.getSkill(skillId);

			if (skill != null) {
				// Prepare

				num heightPercent = ((skill["player_points"] / skill["player_nextPoints"]) * 100).clamp(20, 100);

				fill = new DivElement()
					..classes = ["skillindicator-fill"]
					..style.height = "calc($heightPercent% - 10px)"
					..style.backgroundImage = "url(${skill["player_iconUrl"]})";

				parent = new DivElement()
					..classes = ["skillindicator-parent"]
					..append(fill);

				CurrentPlayer.superParentElement.append(parent);

				// Position

				Rectangle outlineRect = parent.client;
				int outlineWidth = outlineRect.width;
				int outlineHeight = outlineRect.height;
				num playerX = num.parse(CurrentPlayer.playerParentElement.attributes['translatex']);
				num playerY = num.parse(CurrentPlayer.playerParentElement.attributes['translatey']);
				int x = playerX ~/ 1 - outlineWidth ~/ 2 - CurrentPlayer.width ~/ 3;
				int y = playerY ~/ 1 + outlineHeight - 45;

				parent.style
					..left = "${x}px"
					..top = "${y}px";
			}
		});

		INSTANCES.add(this);
	}

	void close() {
		parent?.remove();
	}
}
