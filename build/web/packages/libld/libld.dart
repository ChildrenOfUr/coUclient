library libld;
import 'dart:async';
import 'dart:html';
import 'dart:convert';

Map <String,Asset> ASSET = {};

// add extentions to this list to allow the loading of non-standard text files.
List <String> textExtensions = 
[
 'txt'
];

// add extentions to this list to allow the loading of non-standard json files.
List <String> jsonExtensions = 
[
 'json'
];

// image extentions cannot be changed, because they have to be embedded into an <img> tag.
// Browsers will not render custom file formats 
final List <String> imageExtensions = 
[
 'svg',
 'png',
 'jpg',
 'jpeg',
 'gif',
 'bmp'
];

// audio extentions cannot be changed, because they have to be embedded into an <audio> tag.
// Browsers will not play custom audio formats 
final List <String> audioExtensions = 
[
 'mp3',
 'ogg'
];

// a helper class for loading bars and such.
// the callback function will be provided with the percent of the batch that is loaded.
class Batch 
{
	List <Asset> _toLoad = [];
	num _percentDone = 0;
  
	Batch(this._toLoad);
	Future<List <Asset> > load([Function callback, Element statusElement])
	{
		num percentEach = 100/_toLoad.length;
		
		// creates a list of Futures
		List <Future> futures = [];
		for (Asset asset in _toLoad)
		{
			futures.add(asset.load(statusElement).whenComplete(()
			{
       			// Broadcast that we loaded a file.
				_percentDone += percentEach;
				if (callback != null)
				callback(_percentDone.floor());
			}));
		}
		if(futures.length == 0 && callback != null)
			callback(100);
		
		return Future.wait(futures);
	}
}

class Asset
{
	var _asset;
	bool loaded = false;
	String _uri;	
	String name;
	
	Asset(this._uri);
	Asset.fromMap(this._asset,this.name)
	{
		loaded = true;
		ASSET[name] = this;
	}
	
	Future <Asset> load([Element statusElement])
	{
		name = _uri.split('/')[_uri.split('/').length - 1].split('.')[0];
		//provide some on screen status messages
		if(statusElement != null)
			statusElement.text = "Loading $name from $_uri";
    
		Completer c = new Completer();    
		if (loaded == false)
		{
			bool loading = false, data = false;
      
			// loads ImageElements into memory
			for (String ext in imageExtensions)
			{
				if (_uri.endsWith('.' + ext))
				{
					this._asset = new ImageElement();
					loading = true;
					_asset.onLoad.listen((_) 
					{
						ASSET[name] = this;
						loaded = true;
						c.complete(this);
					});
					_asset.onError.listen((_)
					{
						_asset = null;
						c.complete("Could not load image: $_uri");
					});
					_asset.src = _uri;
					break;
				}
			}
			if (loading == true)
				return c.future;
      
			// loads AudioElements into memory
			for (String ext in audioExtensions)
			{
				if (_uri.endsWith('.' + ext))
				{
					new Timer(new Duration(seconds:2),()
					{
						//if sound hasn't started loading, complete anyway
						if(!data)
							c.completeError('could not load resource: $_uri');
					});
					AudioElement audio = new AudioElement();
					loading = true;
					audio.onLoadedData.first.then((_) => data = true);
					audio.onError.listen((Event err) 
					{
						print('Error in loading Audio : $_uri');
						if(!c.isCompleted)
							c.complete(err);
					});
					audio.onCanPlay.listen((_) 
					{
						ASSET[name] = this;
						this._asset= audio;
						loaded = true;
						if(!c.isCompleted)
							c.complete(this);
					});
					
					//add 2 audio sources (one mp3 and one ogg) to support multiple browsers
					String filename = _uri.substring(0, _uri.lastIndexOf('.'));
					if(ext == "ogg")
					{
						SourceElement source = new SourceElement();
						source.type = 'audio/ogg';
						source.src = _uri;
						audio.append(source);

						SourceElement sourceAlt = new SourceElement();
						sourceAlt.type = 'audio/mpeg';
						sourceAlt.src = filename + ".mp3";
						audio.append(sourceAlt);
					}
					else
					{
						SourceElement source = new SourceElement();
						source.type = 'audio/mpeg';
						source.src = _uri;
						audio.append(source);
						SourceElement sourceAlt = new SourceElement();
						sourceAlt.type = 'audio/ogg';
						sourceAlt.src = filename + ".ogg";
						audio.append(sourceAlt);
					}
					
					//this seems to be necessary (when compiled to js) to cause the browser to generate a GET for the src
					document.body.append(audio);
					break;
				}
			}
			if (loading == true)
				return c.future;
      
			// loads simple text files as a string.
			for (String ext in textExtensions)
			{
				if (_uri.endsWith('.' + ext))
				{
					loading = true;
					Future request = HttpRequest.getString(_uri).then
					((String string)  
					{
						_asset = string;
						loaded = true;
						ASSET[name] = this;
					});
					c.complete(request);
					break;
				}
			}
			if (loading == true)
			  return c.future;
      
			// Returns a decoded object from a json file
			for (String ext in jsonExtensions)
			{
				if (_uri.endsWith('.' + ext))
				{
					loading = true;
					HttpRequest.getString(_uri).then
					((String string)
					{
						ASSET[name] = this;
						_asset =  JSON.decode(string);
						loaded = true;
						c.complete(this);
					});
					break;
				}
			}
			if (loading == true)
				return c.future;
			else
				c.completeError('nothing is being loaded!');
		}
		return c.future;
	}  

	get()
	{
		if (loaded == false || _asset == null)
			throw('Asset not yet loaded!');
		else
			return _asset;
	}
}