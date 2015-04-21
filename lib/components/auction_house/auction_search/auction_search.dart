library auction_search;

import '../imports.dart';

@CustomTag('auction-search')
class AuctionSearch extends PolymerElement
{
	@observable String searchString = '';

	AuctionSearch.created() : super.created();

	Future doSearch(Event event, var detail, InputElement textElement) async
	{
		Map parameters = {};
		List<Auction> results = [];

		if(searchString.trim() != "")
		{
			parameters = {'where':"lower(item_name) LIKE lower('%$searchString%')"};
			results = await getAuctions(parameters);
		}

		//broadcast the results to anyone who is listening to us
		new Message('searchUpdate',results);
	}

	static Future getAuctions(Map parameters) async
    {
    	HttpRequest req = await HttpRequest.request('$serverAddress/ah/list',
    		method: "POST", requestHeaders: {"content-type": "application/json"},
    		sendData: JSON.encode(parameters));

    	List results = decode(JSON.decode(req.responseText),Auction);
    	List<Future> futures = [];
    	results.forEach((Auction auction) => futures.add(_getImage(auction)));
    	await Future.wait(futures);
    	return results;
    }

	static Future _getImage(Auction auction) async
    {
		auction.unit_price = auction.total_cost~/auction.item_count;
		auction.since = timeSince(auction.start_time);
		auction.until = timeUntil(auction.end_time);

    	String response = await HttpRequest.getString('$serverAddress/getItemByName?name=${auction.item_name}');
		try
		{
			Map i = JSON.decode(response);

			auction.style = 'width: calc(100% - 10px);';
			auction.style += 'height: calc(100% - 10px);';
			auction.style += 'background-image: url(${i['iconUrl']});';
			auction.style += 'background-repeat: no-repeat;';
			auction.style += 'background-size: contain;';
			auction.style += 'background-position: 50% 50%;';
			auction.style += 'margin: auto;';
		}
		catch(err){}
    }

	static String timeSince(DateTime date, {String prefix : '', String postfix : ''})
    {
    	Duration relative = new DateTime.now().difference(date);
        int seconds = relative.inSeconds;
        if (relative.inDays > 7 || relative.inDays < 0)
        {
        	DateFormat format = new DateFormat("M d y");
            return format.format(date);
        }
        else if(relative.inDays == 1)
            return '1 day$postfix';
        else if(relative.inDays > 1)
            return '$prefix${relative.inDays} days$postfix';
        else if(seconds <= 1)
            return 'just now';
        else if(seconds < 60)
            return '$prefix$seconds seconds$postfix';
        else if(seconds < 120)
            return '1 minute ago';
        else if(seconds < 3600)
            return '$prefix${seconds~/60} minutes$postfix';
        else if(seconds < 7200)
            return '${prefix}1 hour$postfix';
        else
            return '$prefix${seconds~/3600} hours$postfix';
    }

    static String timeUntil(DateTime date, {String prefix : '', String postfix : ''})
    {
    	Duration relative = date.difference(new DateTime.now());
        int seconds = relative.inSeconds;

        if(seconds <= 1)
    		return 'right now';
        else if(seconds < 60)
        	return '$prefix$seconds seconds$postfix';
        else if(seconds < 120)
        	return '${prefix}1 minute$postfix';
        else if(seconds < 3600)
        	return '$prefix${seconds~/60} minutes$postfix';
    	else if(seconds < 7200)
    		return '${prefix}1 hour$postfix';
    	else if(relative.inDays < 1)
    		return '$prefix${seconds~/3600} hours$postfix';
    	else if(relative.inDays == 1)
            return '${prefix}1 day$postfix';
        else if(relative.inDays > 1)
            return '$prefix${relative.inDays} days$postfix';
        else
        {
        	DateFormat format = new DateFormat("M d y");
            return format.format(date);
        }
    }
}