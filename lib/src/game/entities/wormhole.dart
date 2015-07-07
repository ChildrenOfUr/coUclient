part of couclient;

abstract class Wormhole extends Entity {
	// Maps <entity tsid> to <street tsid>
	Map <String, String> entityMap = {
		"ILI10F80E0J1M8N":"tsid2"
	};


	String destinationTSID;

	void update(double dt) {
		if(intersect(CurrentPlayer.avatarRect, entityRect)) {
			CurrentPlayer.intersectingObjects[id] = entityRect;
			destinationTSID = entityMap[id];
			print("hit object " + id + " / " + destinationTSID);
			goToLocation(destinationTSID);
		}

		else {
			CurrentPlayer.intersectingObjects.remove(id);
		}
	}

	void goToLocation(String street) {
		playerTeleFrom = "wormhole";
		street = street.trim();

		streetService.requestStreet(street);
	}
}