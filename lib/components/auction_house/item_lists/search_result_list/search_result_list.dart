library search_result_list;

import '../../imports.dart';

@CustomTag('search-result-list')
class SearchResultList extends PolymerElement
{
	@published List<SearchResult> results = toObservable([]);

	SearchResultList.created() : super.created()
	{
		new Service(['searchUpdate'], (Message m) {
			results.clear();
			List<Auction> initialResults = m.content;
			List<String> type = [];
			initialResults.forEach((Auction auction) {
				if(!type.contains(auction.item_name))
				{
					results.add(new SearchResult(auction));
					type.add(auction.item_name);
				}
			});
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

	changeFav(Event event, var detail, InputElement target)
	{
		String itemName = target.attributes['data-item-name'];
		SearchResult.changeFav(itemName,target.checked);

		if(target.checked)
			new Message('addFavToList', results.singleWhere((SearchResult result) => result.auction.item_name == itemName));
		else
			new Message('removeFavFromList', results.singleWhere((SearchResult result) => result.auction.item_name == itemName));
	}
}