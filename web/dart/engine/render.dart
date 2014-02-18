part of coUclient;

//TODO: comment the begining of files with brief descriptions as to what they do.
var last = new DateTime.now();
Element fpsDisplay = querySelector('#fps');
NumberFormat twoDigit = new NumberFormat("#0");
bool showFps = false;

// Our renderloop
render() 
{
	if(showFps)
	{
		fpsDisplay.style.display = "block";
		var now = new DateTime.now();
		var fps = 1/(now.difference(last).inMilliseconds/1000);
		fpsDisplay.text = "fps:"+twoDigit.format(fps);
		last = now;
	}
	else
		fpsDisplay.style.display = "none";
	// Update clock
	refreshClock();
	//Draw Street
	var start = new DateTime.now();
	if (currentStreet is Street)
		currentStreet.render();
	//Draw Player
	if(CurrentPlayer is Player)
		CurrentPlayer.render();
}