part of couclient;

abstract class Door extends Entity
{
	// Maps <entity tsid> to <street tsid>
	Map <String, String> entityMap = {
		"ILI10F80E0J1M8N":"tsid2"
	};


	String destinationTSID;

	void update(double dt)
	{
		if (intersect(CurrentPlayer.avatarRect, entityRect))
		{
			CurrentPlayer.intersectingObjects[id] = entityRect;
			destinationTSID = entityMap[id];
			print("hit object " + id + " / " + destinationTSID);
		}

		else
		{
			CurrentPlayer.intersectingObjects.remove(id);
		}
	}

	void goToLocation(String street)
	{
		playerTeleFrom = "door";
		street = street.trim();
		view.mapLoadingScreen.className = "MapLoadingScreenIn";
		view.mapLoadingScreen.style.opacity = "1.0";
		minimap.containerE.hidden = true;

		if (street.startsWith("L"))
		{
			street = street.replaceFirst("L", "G");
		}

		streetService.requestStreet(street);
	}
}