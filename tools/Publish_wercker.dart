import 'dart:io';






/*
 * This script compiles a web-publishable version of the client for our auto-build process
 * 
 * 
 */












main() {

        if (new Directory('./out').existsSync() == false)
          new Directory('./out').createSync(recursive: true);
   new Directory('./out').deleteSync(recursive: true);
   new Directory('./out/web').createSync(recursive: true);
  
  // Places our js in the output folder
  new File('./out/web/game.js').writeAsStringSync(
      new File('./web/game.js').readAsStringSync());
  
  // Places our html in the output folder
  new File('./out/web/game.html').writeAsStringSync(
      minifyHtml(
          new File('./web/game.html').readAsLinesSync()));
  

  for (FileSystemEntity ass in new Directory('../web/assets').listSync(recursive: true, followLinks: false))
  {
    if (ass is Directory)
    {
      print('Moving Directory:' + ass.path.replaceAll('/web/css', '/out/web/css'));
      new Directory(ass.path.replaceAll('/web/assets', '/out/web/assets')).createSync(recursive: true);
    }
  }
  
  for (FileSystemEntity ass in new Directory('../web/assets').listSync(recursive: true, followLinks: false))
  {
    if (ass is File)
    {
      print('Moving File:' + ass.path.replaceAll('/web/css', '/out/web/css'));
      new File(ass.path.replaceAll('/web/assets', '/out/web/assets')).writeAsBytesSync(
          new File(ass.path).readAsBytesSync());
    }
  }
  
  for (FileSystemEntity css in new Directory('../web/css').listSync(recursive: true, followLinks: false))
  {
    if (css is Directory)
    {
      print('Moving Directory:' + css.path.replaceAll('/web/css', '/out/web/css'));
      new Directory(css.path.replaceAll('/web/css', '/out/web/css')).createSync(recursive: true);
    }
  }

  for (FileSystemEntity css in new Directory('../web/css').listSync(recursive: true, followLinks: false))
  {
  if (css is File)
  {
    print('Moving File:' + css.path.replaceAll('/web/css', '/out/web/css'));
    new File(css.path.replaceAll('/web/css', '/out/web/css')).writeAsBytesSync(
        new File(css.path).readAsBytesSync());
  }
  }


  
  
// Deletes the unneeded files made when we used dart2js
  print('Cleaning Workspace.');
  new File('./web/game.js').deleteSync();
  new File('./web/game.js.deps').deleteSync();
  new File('./web/game.js.map').deleteSync();
  new File('./web/game.precompiled.js').deleteSync();
  print('.Done');
}

// Sets up the outputted html file to use JS instead of Dart, Plus optimizing media paths.
List <String> modeJS(List<String> fileLines){
  print('Converting HTML file to use JavaScript.');
  List<String> newHTML = new List();
  for (String line in fileLines)
  {
    line = line.replaceAll('<script type="application/dart" src="main.dart"></script>', '');
    line = line.replaceAll('packages/browser/dart.js', 'game.js');
    // Add other html replacement lines here.

    newHTML.add(line);
  }
  return newHTML;
}


String minifyCss(List<String> fileLines){
  print('Minifying CSS.');  
  // Remove Comments
  fileLines.removeWhere((e) => e.startsWith('/*'));
  
  // Remove Blank Lines
  fileLines.removeWhere((e)
      {
    // See if the line contains only white space.
    String test = e.replaceAll(' ','');
    return test.isEmpty;
      });
  
  
  // Turn into a String and return
  StringBuffer sb = new StringBuffer();
  sb.writeAll(fileLines);
  
  return sb.toString();
}

String minifyHtml(List<String> input){
  
   print('Converting HTML file to use JavaScript.');
   List<String> fileLines = new List();
   for (String line in input)
   {
    line = line.replaceAll('<script type="application/dart" src="main.dart"></script>', '');
    line = line.replaceAll('packages/browser/dart.js', 'game.js');
    // Add other html replacement lines here.

    fileLines.add(line);
   }

  
  
    print('Minifying HTML.');  
  
    // Remove Comments
    fileLines.removeWhere((e) => e.startsWith('<!--'));
    
    // Remove Blank Lines
    fileLines.removeWhere((e)
        {
        // See if the line contains only white space.
        String test = e.replaceAll(' ','');
        return test.isEmpty;
        });
    
    
    // Turn into a String and return
    StringBuffer sb = new StringBuffer();
    sb.writeAll(fileLines);
    
    return sb.toString();
}