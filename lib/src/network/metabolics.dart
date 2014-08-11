part of couclient;

/**
 * 
 * This class will be responsible for querying the database and writing back to it
 * with the details of the player (currants, mood, etc.)
 * 
**/

Metabolics metabolics = new Metabolics();

class Metabolics
{
	//will return a future containing the result of the action
	Future<int> get(String metabolic)
	{
		Completer c = new Completer();
		new Timer(new Duration(milliseconds:100), () => c.complete(1337));
		return c.future;
	}
	
	//will return a future describing the success of the action
	Future<bool> set(String metabolic, dynamic newValue)
	{
		Completer c = new Completer();
		new Timer(new Duration(milliseconds:100), () => c.complete(true));
		return c.future;
	}
}