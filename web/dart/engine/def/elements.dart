part of couclient;

// Game Screen
Element gameScreen = querySelector('#game');
DivElement layers = querySelector('#Layers');
Element exitsElement = querySelector("#Exits");
Element playerHolder = querySelector("#PlayerHolder");

// Name Meter Variables
Element nameMeter = querySelector('#playerName');

// Glyph Menu Variables
Element audioGlyph = querySelector('#AudioGlyph');
Element mobileAudioGlyph = querySelector('#MobileAudioGlyph');
InputElement volumeSlider = querySelector('#VolumeSlider');
Element volumeRangeValue = querySelector('#rangevalue');

// Currant Meter Variables
Element currantMeter = querySelector('#CurrCurrants');

// Img Meter Variables
Element imgMeter = querySelector('#CurrImagination');

// Music Meter Variables
Element titleMeter = querySelector('#TrackTitle');
Element artistMeter = querySelector('#TrackArtist');
AnchorElement scLink = querySelector('#SCLink');

// Energy Meter Variables
Element energymeterImage = querySelector('#EnergyIndicator');
Element energymeterImageLow = querySelector('#EnergyIndicatorRed');
Element currEnergyText = querySelector('#CurrEnergy');
Element maxEnergyText = querySelector('#MaxEnergy');

// Mood Meter Variables
Element moodmeterImageLow =  querySelector('#MoodCircleRed');
Element moodmeterImageEmpty = querySelector('#MoodCircleEmpty');
Element currMoodText = querySelector('#CurrMood');
Element maxMoodText = querySelector('#MaxMood');
Element moodPercent = querySelector('#MoodPercent');

//Location/Map Variables
Element currLocation =  querySelector('#Location');
Element map =  querySelector('#MapGlyph');
Element mapWindow = querySelector('#MapWindow');

// Time Meter Variables
Element currDay = querySelector('#CurrDay');
Element currTime = querySelector('#CurrTime');
Element currDate = querySelector('#CurrDate');

// Console Elements
Element devConsole = querySelector('#DevConsole');
TextAreaElement consoleInput = querySelector('.ConsoleInput');
Element consoleContainer = querySelector('#CommandConsole');

// Loading Elements
Element loadingScreen = querySelector('#MapLoadingScreen');
Element loadStatus = querySelector("#LoadStatus");
Element loadStatus2 = querySelector("#LoadStatus2");
Element streetLoadingStatus = querySelector('#StreetLoadingStatus');
Element mapLoadingBar = querySelector('#MapLoadingBar');
Element mapLoadingScreen = querySelector('#MapLoadingScreen');


// Settings Elements
Element settings = querySelector('#Settings');

// You Won!
Element youWon = querySelector('#YouWon');