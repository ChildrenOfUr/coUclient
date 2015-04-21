library item_browse;

import '../imports.dart';

@CustomTag('item-browse')
class ItemBrowse extends PolymerElement
{
	@published Map<String, List<String>> items = {'Tools':['Pick', 'Fancy Pick', 'Shovel'], 'Basic Resources':['Cherry', 'Chunk of Dullite', 'Chunk of Beryl', 'Chunk of Sparkly', 'Chunk of Metal Rock']};

	ItemBrowse.created() : super.created()
	{
		//generate the item list dynamically from the server in the future
	}

	search(Event event, var detail, Element target) async
	{
		String itemName = target.text;

		new Message('itemDetailRequest', itemName);

		//show auctions
		Map parameters = {'where':"item_name = '$itemName'"};
		List<Auction> auctions = await AuctionSearch.getAuctions(parameters);
		new Message('auctionSearchUpdate', auctions);
	}
}