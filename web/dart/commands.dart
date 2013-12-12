part of coUclient;
//TODO, clean this up, comment, and simplify.


// To Create new commands, add them to this list.
List <List> Commands = new List()
      // The console command, the description, the function called
..add(['print','"print <your message>" Prints a message to the console.',printConsole])
..add(['clear','clears out the visible console',printClear])
..add(['help','Displays this dialog.',printHelp])
..add(['hideConsole','Hides the console from view',hideConsole]);

// Contains console entries.
List <String> ConsoleText = new List();




// We'll use this for handing console commands, and responses to menu options.
doThisForMe(String consoleCommand){
  
  for (List command in Commands)
  {
    if (consoleCommand.startsWith(command[0])){
      Function action = command[2];
      String commandID = command[0]; 
      String data = consoleCommand.replaceAll(commandID,'').replaceAll('\n', '');
      action(data);
    return;
    }
  }
}


updateConsole(){
  Element container = querySelector('#DevConsole').querySelector('.Console');
  container.children.clear();
  for (String item in ConsoleText){
   DivElement n = new DivElement()
      ..classes.add('ConsoleEntry')
      ..text = item;
   container.append(n);
   n.scrollIntoView(ScrollAlignment.BOTTOM);
  }
  
  
}

StreamSubscription consolelistener;// the eventlistener for entering console commands.
showConsole(){
  querySelector('#DevConsole').hidden = false;
  querySelector('.ConsoleInput').focus();
  consolelistener = querySelector('.ConsoleInput').onKeyUp.listen
  ((key){
       if (key.keyCode == 13)
         runConsoleCommand();
});}
hideConsole(var nothing){
  querySelector('#DevConsole').hidden = true;
  consolelistener.cancel();
}


// To print to the in-game console
printConsole(String message){
  ConsoleText.add(message);
  updateConsole();
}


runConsoleCommand(){
  TextAreaElement input = querySelector('.ConsoleInput');
  String value = input.value;
  printConsole('> $value');
  doThisForMe(value);
  input.value = '';
}

printHelp(var nothing){
  printConsole('List of Commands:');
  for (List command in Commands)
    printConsole(command[0] + ' : ' + command[1]);
  
}
printClear(var nothing){
 ConsoleText.clear();
 updateConsole();
}

// A blank action.
doNothing(var nothing){}

