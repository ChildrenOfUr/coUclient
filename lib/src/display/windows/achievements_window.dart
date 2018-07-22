part of couclient;

@JsonSerializable()
class Achievement {
	String id;
	String name;
	String description;
	String category;
	String imageUrl;
	String awarded = "false";

	Achievement();
	factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
}

class AchievementsWindow extends Modal {
	String id = 'achievementsWindow';
	DivElement categoryList;
	UListElement categories;

	AchievementsWindow() {
		prepare();
		categoryList = displayElement.querySelector('#categoryList');
		categories = displayElement.querySelector('#categories');

		categories.querySelectorAll("li").onClick.listen((MouseEvent event) async {
			// Update sidebar selection
			categories.children.forEach((Element li) {
				li.classes.remove("selected");
			});
			(event.target as LIElement).classes.add("selected");

			// Display achievements in category
			categoryList.children.clear();
			Element target = event.target;
			String category = target.text;
			String url = "${Configs.http}//${Configs.utilServerAddress}/listAchievements?email=${game
				.email}&excludeNonMatches=false&category=$category";
			Map map = jsonDecode(await HttpRequest.getString(url));
			List<Achievement> achievements = (map.values as List<Map<String, dynamic>>)
				.map((Map<String, dynamic> json) => Achievement.fromJson(json)).toList();

			DivElement earned = new DivElement()..classes = ['earned-achvments'];
			DivElement unearned = new DivElement()..classes = ['unearned-achvments'];
			achievements.forEach((Achievement a) {
				if(a.awarded == "true") {
					earned.append(_createAchieveIcon(a));
				} else {
					unearned.append(_createAchieveIcon(a));
				}
			});

			categoryList.append(new DivElement()..text="Earned"..className='title');
			categoryList.append(earned);
			categoryList.append(new BRElement());
			categoryList.append(new DivElement()..text="Unearned"..className='title');
			categoryList.append(unearned);
		});

		setupUiButton(querySelector('#open-achievements'));
		setupKeyBinding("Achievements");
	}

	Element _createAchieveIcon(Achievement achievement) {
		DivElement achvIcon = new DivElement()
			..classes = ["achvment-icon"]
			..dataset["achv-awarded"] = achievement.awarded.toString()
			..style.backgroundImage = "url(${achievement.imageUrl})"
			..title = achievement.name + "\n" + achievement.description;

		return achvIcon;
	}
}