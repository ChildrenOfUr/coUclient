library auction_result_list;

import '../../imports.dart';

@CustomTag('auction-result-list')
class AuctionResultList extends PolymerElement
{
	@published List<Auction> results = toObservable([]);

	AuctionResultList.created() : super.created()
	{
		new Service(['auctionSearchUpdate'], (Message m) => results = m.content);
	}

	buyConfirm(Event event, var detail, Element target) {
		AuctionBuyConfirm confirmDialog = new AuctionBuyConfirm();
		Auction auction = results.elementAt(int.parse(target.attributes['data-result-index']));
		confirmDialog.item_style = auction.style;
		confirmDialog.total_cost = auction.total_cost;
		confirmDialog.item_count = auction.item_count;
		document.body.append(confirmDialog);
	}
}