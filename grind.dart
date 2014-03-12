import 'package:grinder/grinder.dart' as grinder;
import 'package:gloss/gloss.dart' as gloss;
import 'dart:io';

// Important Files
File gamehtml = new File('./web/game.html');
File gameglos = new File('./web/glos/base.glos');
File gamedart = new File('./web/main.dart');

// Important Directories
Directory outfolder = new Directory('./out');
Directory glosfolder = new Directory('./web/glos');
Directory toolsfolder = new Directory('./tools');

// Compilers
Function d2js = new grinder.Dart2jsTools().compile;
Function gl2css = gloss.Gloss.parse;

void main([List<String> args]) {
  grinder.defineTask('init', taskFunction: init);
  grinder.defineTask('compileJS', taskFunction: compileJS, depends : ['init']);
  grinder.defineTask('compileCSS', taskFunction: compileCSS, depends : ['init']);
  grinder.defineTask('build', taskFunction: build, depends : ['compileJS', 'compileCSS']);
  grinder.defineTask('deploy', taskFunction: deploy, depends : ['build', 'compileCSS']);
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
  String css = '';
  context.log('Compiling CSS from GLOSS');  
  Iterable glosfiles = glosfolder.listSync(recursive: true, followLinks: false)
      .where((FileSystemEntity entity) => entity is File && entity.path.endsWith('.glos'));
  for (File glosfile in glosfiles) {
    String gls = gl2css(glosfile.readAsStringSync());
     css = css + gls;
  }
  css = gl2css(css);
  new File('./out/base.css').writeAsStringSync(css);
}





build(grinder.GrinderContext context) {
  // copy over our game.html
  context.log('Creating copy of game.html');
  grinder.copyFile(gamehtml, outfolder);
  
  // copy over our assets
  context.log('Copying assets');
  grinder.copyDirectory(new Directory('./web/assets'), new Directory('./out/assets'));  
  
  // Embed CSS
  context.log('Embedding CSS into page');  
  File newhtml = new File('./out/game.html');
  newhtml.writeAsStringSync( 
     newhtml.readAsStringSync()
  .replaceAll('<link rel="stylesheet" href="./css/base.css">',
      '<style>'+ new File('./out/base.css').readAsStringSync() + '</style>')
  .replaceAll('<link id="MobileStyle" rel="stylesheet" href="./css/mobile.css">','')  
  );
  // Embed JS
  context.log('Embedding JS into page');  
  newhtml.writeAsStringSync( 
     newhtml.readAsStringSync()
  .replaceAll('<script type="application/dart" src="main.dart"></script>',
      '<script>'+ new File('./out/main.js').readAsStringSync() + '<script>')
  .replaceAll('<script src="packages/browser/dart.js"></script>','')
  ); 
  // clean up our unneeded files
  context.log('cleaning up');
  new File('./out/base.css').deleteSync();
  new File('./out/main.js').deleteSync();
}

deploy(grinder.GrinderContext context) {
}

