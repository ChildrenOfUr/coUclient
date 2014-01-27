import 'dart:io';






/*
 * This script compiles a web-publishable, JavaScript, version of the client
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
  

  

        if (new Directory('../out').existsSync() == false)
          new Directory('../out').createSync(recursive: true);
    
  
  new Directory('../out').delete(recursive: true)
  .then((_) => new Directory('../out/web').create(recursive: true))
  
  .then((_) => print('Running dart2js + minify...'))
  .then((_) => print('dart2js path: $PATH_TO_DART2JS'))
  .then((_) => Process.run(PATH_TO_DART2JS,['../web/main.dart','--out=../out/web/game.js']))
  //.then((_) => Process.run(PATH_TO_DART2JS,['../web/main.dart','--out=../out/web/game.dart', '--output-type=dart']))
  .then((_) => print('Cleaning Output Directory...'))
  
  // Deletes the unneeded files made when we used dart2js
  .then((_) => print('Cleaning Workspace...'))  

  //.then((_) => new File('../out/web/game.dart.deps').deleteSync())
  .then((_) => new File('../out/web/game.js.deps').deleteSync())
  .then((_) => new File('../out/web/game.js.map').deleteSync())
  .then((_) => new File('../out/web/game.precompiled.js').deleteSync())
  
  // Places our html in the output folder
  .then((_) => new File('../out/web/game.html').writeAsStringSync(
      minifyHtml(
          new File('../web/game.html').readAsLinesSync())))
	.then((_) => new File('../out/web/index.html').writeAsStringSync(minifyHtml(
    new File('../web/game.html').readAsLinesSync())))
          
  .then((_) {
    
    
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
    
    
  })
   
  .then((_) => print('...Done'))
  .catchError(print);
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
    line = line.replaceAll('main.dart', 'game.js');
    line = line.replaceAll('type="application/dart" ', '');
    //line = line.replaceAll('packages/browser/interop.js', 'interop.js');
    line = line.replaceAll('<script src="packages/browser/dart.js"></script>', '');
    // Add other html replacement lines here.

    fileLines.add(line + '\n');
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