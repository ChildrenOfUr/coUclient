part of couclient;

class UseWindow extends Modal {
	static Map<String, UseWindow> instances = {};
	String id = 'useWindow' + WindowManager.randomId.toString();
	String itemType, itemName;
	String listUrl;
	List<Map> recipeList;
	Element well;
	bool makingCancelled;

	factory UseWindow(String itemType, String itemName) {
		if (instances[itemType] == null) {
			instances[itemType] = new UseWindow._(itemType, itemName);
		} else {
			instances[itemType].open();
		}
		return instances[itemType];
	}

	UseWindow._(this.itemType, this.itemName) {
		load().then((Element el) {
			querySelector("#windowHolder").append(el);
			prepare();
			open(refresh: false);
		});
	}

	Future<Element> load() async {
		await updateRecipes();

		// Header

		Element closeButton = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("close");

		Element icon = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-bars");

		SpanElement titleSpan = new SpanElement()
			..text = "Using a $itemName";

		Element header = new Element.header()
			..append(icon)..append(titleSpan);

		// Container

		well = new Element.tag("ur-well")
			..classes.add("useitem-well");

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("useWindow")
			..append(closeButton)..append(header)..append(well);

		return (window);
	}

	Future<Element> listRecipes([bool clearWell = true]) async {
		if (clearWell) {
			well
				..children.clear()
				..classes.remove("col3");
		}

		DivElement recipeContainer = new DivElement()
			..classes.add("useitem-recipes")
			..hidden = false;

		if (recipeList.length > 0) {
			recipeList.forEach((Map recipe) {
				List<int> itemMax = [];

				//decide if we can make this recipe
				recipe['input'].forEach((Map itemMap) {
					int userHas = util.getNumItems(itemMap['itemType']);
					itemMap['userHas'] = userHas;

					int qty = itemMap['qtyReq'];
					if (userHas >= qty) {
						itemMax.add((userHas / qty).floor());
					} else {
						itemMax.add(0);
					}

					itemMax.sort();

					if (itemMax.length > 0) {
						recipe["canMake"] = itemMax.first;
					} else {
						recipe["canMake"] = 0;
					}
				});

				DivElement image = new DivElement()
					..classes.add("useitem-recipe-image")
					..style.backgroundImage = "url(${recipe["output_map"]["iconUrl"]})";

				DivElement info = new DivElement()
					..classes.add("useitem-recipe-text")
					..text = recipe["output_map"]["recipeName"] ?? recipe['output_map']['name'];

				DivElement recipeBtn = new DivElement()
					..classes.addAll(["useitem-recipe", "white-btn"])
					..append(image)..append(info)
					..onClick.listen((_) => openRecipe(recipe["id"]));

				if (recipe["canMake"] == 0) {
					recipeBtn
						..classes.add("cannot-make")
						..title = "You don't have everything to make this. Click to see what you need.";
				}

				recipeContainer.append(recipeBtn);
			});
		} else {
			SpanElement noRecipes = new SpanElement()
				..classes.add("useitem-norecipes")
				..text = "You don't know how to make anything with this.";

			recipeContainer.append(noRecipes);
		}

		return recipeContainer;
	}

	openRecipe(String id) {
		int qty = 1;
		Map recipe = getRecipe(id);

		// output info

		DivElement backToList = new DivElement()
			..classes.addAll(["recipeview-backtolist", "white-btn"])
			..setInnerHtml('<i class="fa fa-chevron-left"></i>&emsp;Cancel')
			..onClick.listen((_) async => well.append(await listRecipes()));

		DivElement itemImage = new DivElement()
			..classes.addAll(["recipeview-image", "white-btn"])
			..style.backgroundImage = "url(${recipe["output_map"]["iconUrl"]})"
			..onClick.listen((_) => new ItemWindow(recipe["output_map"]["name"]));

		String recipeName = recipe['output_map']['recipeName'] ?? recipe['output_map']['name'];
		DivElement itemName = new DivElement()
			..classes.add("recipeview-text")
			..text = recipeName;

		DivElement outputQty = new DivElement()
			..classes.add("recipeview-outputqty");

		if (recipe["output_amt"] == 1) {
			outputQty.setInnerHtml(
				"This recipe makes <br><b>one</b> $recipeName"
				);
		} else {
			if (recipeName.endsWith("y")) {
				outputQty.setInnerHtml(
					"This recipe makes <br><b>${recipe["output_amt"]}</b> ${recipeName
						.substring(0, recipeName.length - 1)}ies"
					);
			} else if (recipeName.endsWith("s")) {
				outputQty.setInnerHtml(
					"This recipe makes <br><b>${recipe["output_amt"]}</b> ${recipeName}es"
					);
			} else {
				outputQty.setInnerHtml(
					"This recipe makes <br><b>${recipe["output_amt"]}</b> ${recipeName}s"
					);
			}
		}

		DivElement leftCol = new DivElement()
			..classes.add("recipeview-leftcol")
			..append(backToList)..append(itemImage)..append(itemName)..append(outputQty);

		DivElement makeBtn;

		// qty controls

		DivElement hmTitle = new DivElement()
			..classes.add("recipeview-ing-title");

		if (recipe["canMake"] > 0) {
			hmTitle.text = "How many?";
		} else {
			hmTitle.text = "You don't have all the ingredients needed to make this.";
		}

		NumberInputElement qtyDisplay;
		qtyDisplay = new NumberInputElement()
			..classes.add("rv-qty-disp")
			..value = qty.toString()
			..min = "1"
			..max = recipe["maxAmt"].toString()
			..onChange.listen((_) => checkReqEnergy(recipe, makeBtn, qtyDisplay));

		DivElement qtyMinus = new DivElement()
			..classes.add("rv-qty-minus")
			..onClick.listen((_) {
				if (qty > 1) {
					qty--;
				}
				checkReqEnergy(recipe, makeBtn, qtyDisplay);
				qtyDisplay.value = qty.toString();
			})
			..setInnerHtml('<i class="fa fa-fw fa-minus rv-red"></i>');

		DivElement qtyPlus = new DivElement()
			..classes.add("rv-qty-plus")
			..onClick.listen((_) {
				if (qty < recipe["canMake"]) {
					qty++;
				}
				checkReqEnergy(recipe, makeBtn, qtyDisplay);
				qtyDisplay.value = qty.toString();
			})
			..setInnerHtml('<i class="fa fa-fw fa-plus rv-green"></i>');

		DivElement qtyParent = new DivElement()
			..classes.add("recipeview-qtyparent")
			..append(qtyMinus)..append(qtyDisplay)..append(qtyPlus);

		DivElement maxDisp = new DivElement()
			..classes.add("rv-max-disp")
			..text = "You can make ${recipe["canMake"].toString()} of these";

		DivElement maxBtn = new DivElement()
			..classes.addAll(["rv-max-btn", "white-btn"])
			..text = "Make ${recipe["canMake"].toString()}"
			..onClick.listen((_) {
				qtyDisplay.value = recipe["canMake"].toString();
				checkReqEnergy(recipe, makeBtn, qtyDisplay);
			});

		makeBtn = new DivElement()
			..classes.addAll(["rv-makebtn", "white-btn"])
			..text = "Do It!"
			..onClick.listen((Event e) {
				if (!(e.target as Element).classes.contains("disabled")) {
					makeRecipe(id, int.parse(qtyDisplay.value));
				}
			});

		DivElement centerCol = new DivElement()
			..classes.add("recipeview-centercol")
			..append(hmTitle);

		if (recipe["canMake"] > 0) {
			centerCol..append(qtyParent)..append(maxDisp)..append(maxBtn)..append(new HRElement())..append(makeBtn);
		}

		// ingredients

		DivElement ingTitle = new DivElement()
			..classes.add("recipeview-ing-title")
			..text = "Ingredients";

		TableElement ingList = new TableElement()
			..classes.add("recipeview-ing-list");

		(recipe["input"] as List<Map>).forEach((Map ingmap) {
			TableCellElement img = new TableCellElement()
				..style.backgroundImage = "url(${ingmap["iconUrl"]})"
				..classes.add("rv-ing-list-img");

			TableCellElement text = new TableCellElement()
				..setInnerHtml("<b>${ingmap["qtyReq"]}x</b> " + ingmap["name"])
				..classes.add("rv-ing-list-ing-name");

			Element status = new Element.tag("i");
			if (ingmap["userHas"] >= ingmap["qtyReq"]) {
				status
					..classes.addAll(["fa", "fa-check", "fa-fw", "rv-green"])
					..title = "You have enough";
			} else {
				status
					..classes.addAll(["fa", "fa-times", "fa-fw", "rv-red"])
					..title = "You don't have enough";
			}

			TableCellElement statusCol = new TableCellElement()
				..append(status);

			TableRowElement item = new TableRowElement()
				..append(img)..append(text)..append(statusCol)
				..onClick.listen((_) => new ItemWindow(ingmap["name"]))
				..title = "Click to open item information";

			ingList.append(item);
		});

		DivElement rightCol = new DivElement()
			..classes.add("recipeview-rightcol")
			..append(ingTitle)..append(ingList);

		// display
		well
			..children.clear()
			..append(leftCol)..append(centerCol)..append(rightCol)
			..classes.add("col3");

		//need to call prepare again so that it is listening for our
		//input to get focus to ignore keys
		prepare();
	}

	makeRecipe(String id, [int qty = 1]) async {
		Map recipe = getRecipe(id);

		int current = 1;

		ImageElement animation = new ImageElement()
			..src = "http://childrenofur.com/game-assets/tool_animations/${recipe["tool"]}.gif";

		DivElement animationParent = new DivElement()
			..classes.add("makerecipe-anim")
			..append(animation);

		Element progBar = new Element.tag("ur-progress")
			..attributes["percent"] = "1"
			..attributes["status"] = "Making ${current.toString()} of ${qty.toString()}...";

		Element cancelBtn;
		cancelBtn = new DivElement()
			..classes = ["white-btn", "rmake-cancel", "rv-red"]
			..setInnerHtml('<i class="fa fa-chevron-left"></i>&emsp;Cancel')
			..onClick.first.then((_) {
				makingCancelled = true;
				cancelBtn
					..setInnerHtml('<i class="fa fa-spin fa-spinner"></i>&emsp;Finishing up...')
					..classes.add("disabled");
			});

		// display
		well
			..children.clear()
			..append(animationParent)..append(progBar)..append(cancelBtn);

		await Future.doWhile(() async {
			if (makingCancelled) {
				await _stopMakingRecipes();
				return false;
			} else {
				String serverResponse = await HttpRequest.requestCrossOrigin(
					"http://${Configs.utilServerAddress}/recipes/make"
						"?token=$rsToken"
						"&id=${recipe["id"]}"
						"&email=${game.email}"
						"&username=${game.username}"
					);

				if (current >= qty || serverResponse != "OK") {
					// Stop
					if (serverResponse != "OK") {
						// Server says no
						new Toast(
							"You had to stop using your ${itemName} because $serverResponse.",
							notify: NotifyRule.UNFOCUSED
							);
					}

					// We're done
					await _stopMakingRecipes();
					return false;
				} else {
					// Increase the number we've made
					current++;

					// Update the progress bar
					progBar
						..attributes["percent"] = ((100 / qty) * current).toString()
						..attributes["status"] = "Making ${current.toString()} of ${qty
							.toString()}";
				}
			}

			return true;
		});
	}

	Future _stopMakingRecipes() async {
		// Update recipe data
		await updateRecipes(false);
		// Reset the UI
		well.append(await listRecipes());
	}

	Map getRecipe(String id) {
		return recipeList
			.where((Map r) => r["id"] == id)
			.first;
	}

	@override
	open({bool ignoreKeys: false, bool refresh: true}) async {
		if (refresh) {
			await updateRecipes();
		}
		well.append(await listRecipes(true));
		makingCancelled = false;
		displayElement.hidden = false;
		elementOpen = true;
		this.focus();
	}

	@override
	close() {
		if (instances[itemType] != null) {
			instances[itemType].displayElement.hidden = true;
			super.close();
		}
	}

	updateRecipes([bool notify = true]) async {
		if (notify) {
			new Toast("Reading recipe book...");
		}
		recipeList = await JSON.decode(await HttpRequest.requestCrossOrigin(
			"http://${Configs.utilServerAddress}/recipes/list?token=$rsToken&tool=$itemType&email=${game.email}"));
		return;
	}

	bool checkReqEnergy(Map recipe, Element makeBtn, NumberInputElement qtyDisplay) {
		if (metabolics.energy < (recipe["energy"] as int).abs() * (qtyDisplay.valueAsNumber)) {
			makeBtn.classes.add("disabled");
			makeBtn.title = "Not enough energy :(";
			return false;
		} else {
			makeBtn.classes.remove("disabled");
			makeBtn.title = "";
			return true;
		}
	}
}
