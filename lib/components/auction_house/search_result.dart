library search_result;

import 'imports.dart';

class SearchResult
{
	Auction auction;
	bool isFav = false;
	static Map<String,String> favSaves = null;

	SearchResult(this.auction)
	{
		if(favSaves == null)
		{
			if(window.localStorage.containsKey('favSaves'))
				favSaves = JSON.decode(window.localStorage['favSaves']);
			else
				favSaves = {};
		}

		if(favSaves[auction.item_name] == "true")
			isFav = true;
	}

	static changeFav(String itemName, bool isFav)
	{
		favSaves[itemName] = isFav.toString();
		window.localStorage['favSaves'] = JSON.encode(favSaves);
	}
}