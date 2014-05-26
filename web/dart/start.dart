part of couclient;

main()
{
  // initialize the userinterface.
	display.init();  
	display.mood = 3;
	display.energy = 15;
	
	// Begin the GAME!!!
	gameLoop(0.0);
}