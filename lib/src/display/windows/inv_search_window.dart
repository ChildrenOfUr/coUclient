part of couclient;

class InventorySearchMatch {
	String name;
	String iconUrl;
	int qty;
	int slot;
	int subSlot;
	num relevance;

	InventorySearchMatch({
		this.name, this.iconUrl,
		this.qty, this.slot, this.subSlot: -1,
		this.relevance
	}) {
		assert(name != null);
		assert(iconUrl != null);
		assert(qty != null);
		assert(slot != null);
		assert(subSlot != null);
		assert(relevance != null);
	}
}

class InventorySearchWindow extends Modal {
	final String id = 'invSearchWindow';

	Element trigger;
	TextInputElement input;
	DivElement output;

	InventorySearchWindow() {
		prepare();

		setupUiButton(querySelector('#inventorySearch'));
		document.onKeyDown.listen((KeyboardEvent k) {
			if (inputManager == null || ignoreShortcuts) {
				return;
			}

			//if F3 is pressed or ctrl+f is pressed
			if (k.keyCode == 114 || (k.ctrlKey && k.keyCode == 70)) {
				k.preventDefault();
				if (displayElement.hidden) {
					open();
				}
			}
		});

		input = displayElement.querySelector('#invSearchInput');
		output = displayElement.querySelector('#invSearchOutput');

		input
			..onKeyDown.listen((KeyboardEvent e) { if (e.keyCode == 27) close(); })
			..onInput.listen((_) => _update())
			..onClick.listen((_) => input.value = '');
	}

	@override
	void open({bool ignoreKeys: false}) {
		input.value = localStorage['inv_search_query'] ?? '';
		_update();
		super.open(ignoreKeys: ignoreKeys);
		input.focus();
	}

	void _update() {
		String query = input.value.trim().toLowerCase();
		localStorage['inv_search_query'] = query;
		List<InventorySearchMatch> matches =  _findResults(query);
		_displayResults(matches);
	}

	bool _contained(String a, String b) {
		a = a.toLowerCase();
		b = b.toLowerCase();
		return (a.contains(b) || b.contains(a));
	}

	List<InventorySearchMatch> _findResults(String query) {
		List<InventorySearchMatch> matches = new List();

		for (int si = 0; si < playerInventory.slots.length; si++) {
			Slot slot = playerInventory.slots[si];

			if (slot.item == null) {
				continue;
			}

			if (
				(slot.item.isContainer ?? false) &&
				slot.item.metadata?.containsKey('slots') ?? false
			) {
				List<Map> subSlots = JSON.decode(slot.item.metadata['slots']);
				for (int ssi = 0; ssi < slot.item.subSlots; ssi++) {
					if (subSlots[ssi]['item'] == null) {
						continue;
					}

					String itemName = subSlots[ssi]['item']['name'];
					String iconUrl = subSlots[ssi]['item']['iconUrl'];
					int qty = subSlots[ssi]['count'];
					bool contains = _contained(query, itemName);
					if (contains) {
						int dist = levenshtein(itemName, query);
						matches.add(new InventorySearchMatch(
							name: itemName,
							iconUrl: iconUrl,
							qty: qty,
							slot: si,
							subSlot: ssi,
							relevance: (contains ? 0 : dist)
							));
					}
				}
			} else {
				bool contains = _contained(slot.item.name, query);
				int dist = levenshtein(slot.item.name, query);
				matches.add(new InventorySearchMatch(
					name: slot.item.name,
					iconUrl: slot.item.iconUrl,
					qty: slot.count,
					slot: si,
					relevance: (contains ? 0 : dist)
				));
			}
		}

		matches.sort((InventorySearchMatch a, InventorySearchMatch b) {
			return a.relevance.compareTo(b.relevance);
		});

		return (matches.length > 5 ? matches.sublist(0, 5) : matches);
	}

	void _displayResults(List<InventorySearchMatch> items) {
		output.children.clear();

		items.forEach((InventorySearchMatch item) {
			ImageElement icon = new ImageElement()
				..classes = ['inv-search-result-icon']
				..src = item.iconUrl;

			SpanElement label = new SpanElement()
				..classes = ['inv-search-result-label']
				..text = item.name;

			SpanElement qty = new SpanElement()
				..classes = ['inv-search-result-qty']
				..text = item.qty.toString() + 'x';

			DivElement result = new DivElement()
				..classes = ['inv-search-result']
				..append(icon)
				..append(label)
				..append(qty)
				..onClick.listen((_) {
					_highlightItem(item);
					_reset();
				});

			output.append(result);
		});
	}

	Future _highlightItem(InventorySearchMatch item) async {
		final String HL_CSS = 'inv-highlight';

		Element topLevel = querySelectorAll('#inventory .box').toList()[item.slot];
		Element toHighlight;

		if (item.subSlot == -1) {
			// Top-level slot
			toHighlight = topLevel;
		} else {
			// Open bag window
			topLevel.querySelector('.item-container-toggle').click();

			// Find bag window
			BagWindow bagWindow = BagWindow.bagWindows.singleWhere((BagWindow w) {
				return (w.sourceSlotNum == item.slot);
			});

			// Wait for it to refresh
			if (!(bagWindow.loadUpdate?.isCompleted) ?? false) {
				await bagWindow.loadUpdate.future;
			}

			// Find slot
			toHighlight = bagWindow.displayElement
				.querySelectorAll('.box')
				.toList()[item.subSlot];
		}

		// Highlight specfied slot
		toHighlight.classes.add(HL_CSS);

		// Wait for last event to end
		await new Future.delayed(new Duration(milliseconds: 100));
		// On next click
		document.body.onClick.first.then((_) {
			// Remove highlight
			toHighlight.classes.remove(HL_CSS);
		});
	}

	void _reset() {
		close();
		_update();
	}
}
