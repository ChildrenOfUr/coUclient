library favorite_list;

import '../../imports.dart';

@CustomTag('favorite-list')
class FavoriteList extends PolymerElement
{
	@published List<SearchResult> results = toObservable([]);
	Map<String, String> favSaves = {};

	FavoriteList.created() : super.created()
	{
		if(window.localStorage.containsKey('favSaves'))
			favSaves = JSON.decode(window.localStorage['favSaves']);

		new Service(['addFavToList'], (Message m) {
			results.add(m.content);
		});
		new Service(['removeFavFromList'], (Message m) {
			results.removeWhere((SearchResult result) => result.auction.item_name == m.content.auction.item_name);
		});

		getItems();
	}

	getItems() async {
		String whereClause = "item_name = ";
		favSaves.forEach((String itemName, String isFav) {
			if(isFav == "true")
				whereClause += "'$itemName' OR item_name = ";
		});
		//add a bogus item to the end so that we don't have a hanging OR clause
		whereClause += "'invlaid_item1234%^^'";

		Map parameters = {'where':whereClause};
		List<Auction> auctions = await AuctionSearch.getAuctions(parameters);

		List<String> type = [];
		auctions.forEach((Auction auction) {
			if(!type.contains(auction.item_name))
			{
				type.add(auction.item_name);
				results.add(new SearchResult(auction));
			}
		});
	}

	showDetails(Event event, var detail, Element target) async
	{
		String itemName = target.attributes['data-item-name'];
		new Message('itemDetailRequest', itemName);

		//show auctions
		Map parameters = {'where':"item_name = '$itemName'"};
		List<Auction> auctions = await AuctionSearch.getAuctions(parameters);
		new Message('auctionSearchUpdate',auctions);
	}

	removeFav(Event event, var detail, Element target) {
		String itemName = target.attributes['data-item-name'];
		SearchResult.changeFav(itemName, false);
		results.removeWhere((SearchResult result) => result.auction.item_name == itemName);
	}
}