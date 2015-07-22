part of couclient;

class BagWindow extends Modal {
	String id = 'bagWindow';

	BagWindow() {
		prepare();
		setupUiButton(view.inventorySearch);
	}
}
