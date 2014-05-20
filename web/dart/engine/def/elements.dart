part of couclient;

// Game Screen
Element gameScreen = querySelector('#game'); //done
DivElement layers = gameScreen.append(new Element.div()); //done
Element exitsElement = gameScreen.append(new Element.div()); //done
Element playerHolder = gameScreen.append(new Element.div()); //done

// Name Meter Variables
Element nameMeter = querySelector('#playerName'); //done

// Glyph Menu Variables
Element audioGlyph = querySelector('#volumeGlyph');
Element mobileAudioGlyph = querySelector('#MobileAudioGlyph');
InputElement volumeSlider = querySelector('#VolumeSlider');
Element volumeRangeValue = querySelector('#rangevalue');

// Currant Meter Variables
Element currantMeter = querySelector('#currCurrants'); //done

// Img Meter Variables
Element imgMeter = querySelector('#CurrImagination');

// Music Meter Variables
Element titleMeter = querySelector('#trackTitle'); //done
Element artistMeter = querySelector('#trackArtist'); //done
AnchorElement scLink = querySelector('#SCLink'); //done

// Energy Meter Variables
Element energymeterImage = querySelector('#energyDisks .green'); //done
Element energymeterImageLow = querySelector('#energyDisks .red'); //done
Element currEnergyText = querySelector('#currEnergy'); //done
Element maxEnergyText = querySelector('#maxEnergy'); //done

// Mood Meter Variables
Element moodmeterImageLow =  querySelector('#leftDisk .hurt'); //done
Element moodmeterImageEmpty = querySelector('#leftDisk .dead'); //done
Element currMoodText = querySelector('#moodMeter .fraction .curr'); //done
Element maxMoodText = querySelector('#moodMeter .fraction .max'); //done
Element moodPercent = querySelector('#moodMeter .percent .number'); //done

//Location/Map Variables
Element currLocation =  querySelector('#Location');
Element map =  querySelector('#MapGlyph');
Element mapWindow = querySelector('#MapWindow');

// Time Meter Variables
Element currDay = querySelector('#currDay'); //done
Element currTime = querySelector('#currTime'); //done
Element currDate = querySelector('#currDate'); //done

// Console Elements
Element devConsole = querySelector('#consoleWindow article.console'); //done
TextAreaElement consoleInput = querySelector('.ConsoleInput');
Element consoleContainer = querySelector('#consoleWindow'); //done

// Loading Elements
Element loadStatus = querySelector("#loading #loadstatus"); //done
Element loadStatus2 = querySelector("#loading #loadstatus2"); //done
Element loadingScreen = querySelector('#loading'); //done
Element playButton = querySelector("#playButton"); //done
Element streetLoadingStatus = querySelector('#StreetLoadingStatus');
Element mapLoadingBar = querySelector('#MapLoadingBar');
Element mapLoadingScreen = querySelector('#MapLoadingScreen');


// Settings Elements
Element settings = querySelector('#settings');

// You Won!
Element youWon = querySelector('#youWon'); // done