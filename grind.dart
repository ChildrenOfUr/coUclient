import 'package:grinder/grinder.dart' as grinder;
import 'dart:io';

// Important Files
File gamehtml = new File('./web/game.html');
File gamecss = new File('./web/base.css');
File mobilecss = new File('./web/mobile.css');
File gamedart = new File('./web/main.dart');

// Important Directories
Directory outfolder = new Directory('./out');
Directory glosfolder = new Directory('./web/glos');
Directory toolsfolder = new Directory('./tools');

// Compilers
Function d2js = new grinder.Dart2jsTools().compile;

void main([List<String> args]) {
  grinder.defineTask('init', taskFunction: init);
  grinder.defineTask('compileJS', taskFunction: compileJS, depends : ['init']);
  grinder.defineTask('compileCSS', taskFunction: compileCSS, depends : ['init']);
  grinder.defineTask('build', taskFunction: build, depends : ['compileJS', 'compileCSS']);
  grinder.defineTask('deploy', taskFunction: deploy, depends : ['build']);
  // Running from DartEditor? I'll assume you want to build.
  if (args.length == 0){
    print('Assuming you want to "build"..');
    grinder.startGrinder(['build']);}
  else
    grinder.startGrinder(args);
}

init(grinder.GrinderContext context) {
  context.log('Initializing Grinder..');

  // make our output folder
  context.log('Creating "out" folder');
  if (outfolder.existsSync() == true)
    outfolder.deleteSync(recursive: true);
  outfolder.createSync(recursive: true); 
}

compileJS(grinder.GrinderContext context) {
  context.log('Compiling JS from DART');
  d2js(context,new File('./web/main.dart'), outDir : outfolder);
  // Deletes unneeded JS files for deployment
  context.log('Cleaning generated dart2js files');
  new File('./out/main.dart.js.deps').deleteSync();
  new File('./out/main.dart.js.map').deleteSync();
  new File('./out/main.dart.precompiled.js').deleteSync();
  new File('./out/main.dart.js').renameSync('./out/main.js');
}


compileCSS(grinder.GrinderContext context) {
  context.log('Merging all CSS files');
  
  List css = new List.from(gamecss.readAsLinesSync(), growable:true);
  List outcss = new List.from(css ,growable:true);
  for (String line in css) {
    if (line.contains('@import url("./')) {
      String url = line
      .replaceAll('@import url("./','')
      .replaceAll('");', '')
      .trim();
      context.log('Replacing @import url("' + url + '");');
      int index = outcss.indexOf(line);
      outcss.replaceRange(index, index,
          new File('./web/' + url).readAsLinesSync());
    }
  }
  // fix the relative paths of fonts and stuff
  new File('./out/base.css').writeAsStringSync(outcss.join().replaceAll('../','./'));
  context.log('Saving processed CSS');
}


build(grinder.GrinderContext context) {
  // copy over our game.html
  context.log('Creating copy of game.html');
  grinder.copyFile(gamehtml, outfolder);
  
  // copy over our assets
  context.log('Copying assets');
  grinder.copyDirectory(new Directory('./web/lib'), new Directory('./out/lib'));  
  
  // Embed CSS
  context.log('Embedding CSS into page');  
  File newhtml = new File('./out/game.html');
  newhtml.writeAsStringSync( 
     newhtml.readAsStringSync()
  .replaceAll('<link rel="stylesheet" href="./base.css">',
      '<style>'+ new File('./out/base.css').readAsStringSync() + '</style>')
  );
  // Embed JS
  context.log('Embedding JS into page');  
  newhtml.writeAsStringSync( 
     newhtml.readAsStringSync()
  .replaceAll('<script type="application/dart" src="./main.dart">',
      '<script>'+ new File('./out/main.js').readAsStringSync())
  .replaceAll('<script src="packages/browser/dart.js"></script>','')
  );
  
  // Shrink HTML a little
  newhtml.writeAsStringSync(newhtml.readAsStringSync());
  
  // clean up our unneeded files
  context.log('cleaning up');
  new File('./out/base.css').deleteSync();
  new File('./out/main.js').deleteSync();
  for (FileSystemEntity e in outfolder.listSync(recursive:true, followLinks:false)) {
    if (e.path.split('/')[e.path.split('/').length - 1].contains('packages'))
      e.deleteSync(recursive:true);
  }    
}

deploy(grinder.GrinderContext context) {
}

