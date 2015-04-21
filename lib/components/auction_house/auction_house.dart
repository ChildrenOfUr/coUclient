library auction_house;

import 'imports.dart';

@CustomTag('auction-house')
class AuctionHouse extends PolymerElement
{
	@published List<Auction> results = toObservable([]);
	@observable int leftSelected = 0, rightSelected = 0, dataSelected = 0;

	AuctionHouse.created() : super.created()
	{
		//generateNewAuctions();
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
}