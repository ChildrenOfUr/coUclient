library auction_buy_confirm;

import '../imports.dart';

@CustomTag('auction-buy-confirm')
class AuctionBuyConfirm extends PolymerElement
{
	@published String item_style;
	@published int total_cost, item_count;

	AuctionBuyConfirm.created() : super.created();
	factory AuctionBuyConfirm() => new Element.tag('auction-buy-confirm');

	buyItem(Event event, var detail, Element target)
	{

	}

	dismiss(Event event, var detail, Element target)
	{
		this.remove();
	}
}