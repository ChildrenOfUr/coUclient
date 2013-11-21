import 'dart:io';






/*
 * This script compiles a web-publishable version of the client
 * 
 * TODO when compiling a production ready app, we need to transfer the asset folder still. This should be automated.
 * 
 */












main() {
  
  //Detect where dart2js is
  String PATH_TO_DART2JS;
  if (Platform.isWindows)
  PATH_TO_DART2JS = Platform.executable.substring(0, Platform.executable.length - 4)+ 'dart2js.exe';
  else
  PATH_TO_DART2JS = Platform.executable.substring(0, Platform.executable.length - 4)+ 'dart2js';
  
  
  
  print(Platform.executable);
  print('Running dart2js + minify...');
  Process.run(PATH_TO_DART2JS,['../web/main.dart','--out=../web/game.js','--minify'])
  .then((_) => print('Cleaning Output Directory...'))
  .then((_) 
      {
        if (new Directory('../out').existsSync() == false)
          new Directory('../out').createSync(recursive: true);
    
      })
  .then((_) => new Directory('../out').deleteSync(recursive: true))
  .then((_) => new Directory('../out/web').createSync(recursive: true))
  
  // Places our js in the output folder
  .then((_) => new File('../out/web/game.js').writeAsStringSync(
      new File('../web/game.js').readAsStringSync()))
  
  // Places our html in the output folder
  .then((_) => new File('../out/web/game.html').writeAsStringSync(
      minifyHtml(
          new File('../web/game.html').readAsLinesSync())))
  
      
  // Create css and font folders
  .then((_) => new Directory('../out/web/css/font').createSync(recursive: true))
      
  // Places our css in the output folder
  .then((_) => new File('../out/web/css/base.css').writeAsStringSync(
      minifyCss(
        new File('../web/css/base.css').readAsLinesSync()
          )))
   
  // Copies FontAwesome to the output folder
  .then((_) => new File('../out/web/css/font-awesome.min.css').writeAsBytesSync(
        new File('../web/css/font-awesome.min.css').readAsBytesSync()))
  .then((_) => new File('../out/web/css/font/fontawesome-webfont.eot').writeAsBytesSync(
        new File('../web/css/font/fontawesome-webfont.eot').readAsBytesSync()))
  .then((_) => new File('../out/web/css/font/fontawesome-webfont.svg').writeAsBytesSync(
        new File('../web/css/font/fontawesome-webfont.svg').readAsBytesSync()))
  .then((_) => new File('../out/web/css/font/fontawesome-webfont.ttf').writeAsBytesSync(
        new File('../web/css/font/fontawesome-webfont.ttf').readAsBytesSync()))
  .then((_) => new File('../out/web/css/font/fontawesome-webfont.woff').writeAsBytesSync(
        new File('../web/css/font/fontawesome-webfont.woff').readAsBytesSync()))
  .then((_) => new File('../out/web/css/font/FontAwesome.otf').writeAsBytesSync(
        new File('../web/css/font/FontAwesome.otf').readAsBytesSync()))
   
// Deletes the unneeded files made when we used dart2js
  .then((_) => print('Cleaning Workspace...'))  
  .then((_) => new File('../web/game.js').deleteSync())
  .then((_) => new File('../web/game.js.deps').deleteSync())
  .then((_) => new File('../web/game.js.map').deleteSync())
  .then((_) => new File('../web/game.precompiled.js').deleteSync())
  .then((_) => print('...Done'))
  .catchError(print);
}

// Sets up the outputted html file to use JS instead of Dart, Plus optimizing media paths.
List <String> modeJS(List<String> fileLines){
  print('Converting HTML file to use JavaScript...');
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
  print('Minifying CSS...');  
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
  
   print('Converting HTML file to use JavaScript...');
   List<String> fileLines = new List();
   for (String line in input)
   {
    line = line.replaceAll('<script type="application/dart" src="main.dart"></script>', '');
    line = line.replaceAll('packages/browser/dart.js', 'game.js');
    // Add other html replacement lines here.

    fileLines.add(line);
   }

  
  
    print('Minifying HTML...');  
  
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