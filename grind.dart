import 'package:grinder/grinder.dart' as grinder;
import 'dart:io';

// Important Files
File gamehtml = new File('./web/game.html');
File gamecss = new File('./web/base.css');
File mobilecss = new File('./web/mobile.css');
File gamedart = new File('./web/main.dart');

// Important Directories
Directory outfolder = new Directory('./out');
Directory toolsfolder = new Directory('./tools');

// Compilers
Function d2js = new grinder.Dart2jsTools().compile;

void main([List<String> args])
{
	grinder.defineTask('init', taskFunction: init);
	grinder.defineTask('compileJS', taskFunction: compileJS, depends : ['init']);
	grinder.defineTask('build', taskFunction: build, depends : ['compileJS']);
	grinder.defineTask('deploy', taskFunction: deploy, depends : ['build']);
	
	// Running from DartEditor? I'll assume you want to build.
	if (args.length == 0)
	{
		print('Assuming you want to "build"..');
		grinder.startGrinder(['build']);
	}
	else
		grinder.startGrinder(args);
}

init(grinder.GrinderContext context) 
{
	context.log('Initializing Grinder..');

	// make our output folder
	context.log('Creating "out" folder');
	if (outfolder.existsSync() == true)
		outfolder.deleteSync(recursive: true);
	outfolder.createSync(recursive: true); 
}

compileJS(grinder.GrinderContext context)
{
	context.log('Compiling JS from DART');
	d2js(context,new File('./web/main.dart'), outDir : outfolder);
	// Deletes unneeded JS files for deployment
	context.log('Cleaning generated dart2js files');
	new File('./out/main.dart.js.deps').deleteSync();
	new File('./out/main.dart.js.map').deleteSync();
	new File('./out/main.dart.precompiled.js').deleteSync();
	new File('./out/main.dart.js').renameSync('./out/main.js');
}

build(grinder.GrinderContext context) 
{
	// copy over our game.html
	context.log('Creating copy of game.html');
	grinder.copyFile(gamehtml, outfolder);
  
	// copy over our base.css
	context.log('Creating copy of base.css');
	grinder.copyFile(gamecss, outfolder);
	grinder.copyFile(mobilecss, outfolder);
  
	// copy over our assets
	context.log('Copying assets');
	grinder.copyDirectory(new Directory('./web/assets'), new Directory('./out/assets'));  
  
	// Embed CSS
	context.log('Embedding CSS into page');  
	File newhtml = new File('./out/game.html');
	newhtml.writeAsStringSync( 
	newhtml.readAsStringSync()
		.replaceAll('<link rel="stylesheet" href="./base.css">',
		'<style>'+ new File('./out/base.css').readAsStringSync() + '</style>'));
	
	// Embed JS
	context.log('Embedding JS into page');  
	newhtml.writeAsStringSync(
		newhtml.readAsStringSync()
			.replaceAll('<script type="application/dart" src="main.dart"></script>',
			'<script type="text/javascript">'+ new File('./out/main.js').readAsStringSync() + '</script>')
				.replaceAll('<script src="packages/browser/dart.js"></script>',''));
	
	// clean up our unneeded files
	context.log('cleaning up');
	new File('./out/base.css').deleteSync();
	new File('./out/main.js').deleteSync();
	
	//the packages seem to like to copy themselves everywhere
	deleteDirectory('./out/assets/packages');
	deleteDirectory('./out/assets/emoticons/packages');
	deleteDirectory('./out/assets/font/packages');
	deleteDirectory('./out/assets/locations/packages');
	deleteDirectory('./out/assets/sprites/packages');
	deleteDirectory('./out/assets/system/packages');
}

deleteDirectory(String path)
{
	try
	{
		new Directory(path).deleteSync(recursive:true);
	}
	catch(e){}
}

deploy(grinder.GrinderContext context) 
{
}

