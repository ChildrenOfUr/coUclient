library auction_list;

import 'package:polymer/polymer.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:intl/intl.dart';

import 'auction.dart';

import 'dart:convert';
import 'dart:html';
import 'dart:async';
import 'dart:math';

@CustomTag('auction-list')
class AuctionList extends PolymerElement
{
	String serverAddress = "http://server.childrenofur.com:8181";
	@observable String searchString = '';
	@observable List<Auction> results = toObservable([]);

	AuctionList.created() : super.created()
	{
		generateNewAuctions().then((_) => getAuctions({}));
	}

	doSearch(Event event, var detail, InputElement textElement)
	{
		Map parameters = {};

		if(searchString.trim().length != 0)
			parameters = {'where':"lower(username) LIKE lower('%$searchString%') or lower(item_name) LIKE lower('%$searchString%')"};

		getAuctions(parameters);
	}

	Future getAuctions(Map parameters) async
    {
    	HttpRequest req = await HttpRequest.request('$serverAddress/ah/list',
    		method: "POST", requestHeaders: {"content-type": "application/json"},
    		sendData: JSON.encode(parameters));

    	List results = decode(JSON.decode(req.responseText),Auction);
    	List<Future> futures = [];
    	results.forEach((Auction auction) => futures.add(getImage(auction)));
    	await Future.wait(futures);
    	this.results = results;
    }

	Future getImage(Auction auction) async
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

	Future postAuction(Auction auction)
    {
    	return HttpRequest.request("$serverAddress/ah/create",
        			method: "POST", requestHeaders: {"content-type": "application/json"},
        			sendData: JSON.encode(encode(auction)));
    }

	Future generateNewAuctions() async
    {
    	Random rand = new Random();
    	String response = await HttpRequest.getString('$serverAddress/ah/dropAll');

    	//print('dropped $response entries');

    	List<Future> futures = [];
    	List<String> users = ['Thaderator','Lead','Paul ♖ DarkKiero','Klikini'];
    	List<String> items = ['Shovel','Pick','Bean','Chunk of Beryl','Chunk of Sparkly','Cherry'];
    	for(int i=0; i<10; i++)
    	{
    		Auction auction = new Auction()
    	        ..username = users.elementAt(rand.nextInt(users.length))
    	        ..item_name = items.elementAt(rand.nextInt(items.length))
    	        ..item_count = rand.nextInt(10)+1
    	        ..total_cost = rand.nextInt(1000)+1
    	        ..start_time = new DateTime.now().subtract(new Duration(minutes:rand.nextInt(1000)))
    			..end_time = new DateTime.now().add(new Duration(minutes:rand.nextInt(1000)));

    		futures.add(postAuction(auction));
    	}

    	await Future.wait(futures);
    }

	String timeSince(DateTime date, {String prefix : '', String postfix : ''})
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

    String timeUntil(DateTime date, {String prefix : '', String postfix : ''})
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