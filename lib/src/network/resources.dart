part of couclient;
// temporary shim for libld.

xl.ResourceManager resources = new xl.ResourceManager();


Map<String, Asset> ASSET = {};

// add extentions to this list to allow the loading of non-standard text files.
List<String> textExtensions = ['txt'];

// add extentions to this list to allow the loading of non-standard json files.
List<String> jsonExtensions = ['json'];

// image extentions cannot be changed, because they have to be embedded into an <img> tag.
// Browsers will not render custom file formats
final List<String> imageExtensions = [
  'svg',
  'png',
  'jpg',
  'jpeg',
  'gif',
  'bmp'
];

// audio extentions cannot be changed, because they have to be embedded into an <audio> tag.
// Browsers will not play custom audio formats
final List<String> audioExtensions = ['mp3', 'ogg'];

// a helper class for loading bars and such.
// the callback function will be provided with the percent of the batch that is loaded.
class Batch {
  List<Asset> _toLoad = [];
  num _percentDone = 0;

  Batch(this._toLoad);
  Future<List<Asset>> load(Function callback,
      {Element statusElement: null, bool enableCrossOrigin: false}) {
    num percentEach = 100 / _toLoad.length;

    // creates a list of Futures
    List<Future> futures = [];
    for (Asset asset in _toLoad) {
      futures.add(asset
          .load(
              statusElement: statusElement,
              enableCrossOrigin: enableCrossOrigin)
          .whenComplete(() {
        // Broadcast that we loaded a file.
        _percentDone += percentEach;
        if (callback != null) callback(_percentDone.floor());
      }));
    }
    if (futures.length == 0 && callback != null) callback(100);

    return Future.wait(futures);
  }
}

class Asset {
  var _asset;
  bool loaded = false;
  String _uri;
  String name;

  Asset(this._uri);
  Asset.fromMap(this._asset, this.name) {
    loaded = true;
    ASSET[name] = this;
  }

  load({Element statusElement: null, bool enableCrossOrigin: false}) async {
    name = _uri.split('/')[_uri.split('/').length - 1].split('.')[0];

    //provide some on screen status messages
    if (statusElement != null) statusElement.text = "Loading $name from $_uri";

    if (loaded == false) {
      // loads ImageElements into memory
      for (String ext in imageExtensions) {
        if (_uri.endsWith('.' + ext)) {
          // add file to the resourcemanager
          resources.addBitmapData(name, _uri);
          await resources.load();
          xl.BitmapData data = resources.getBitmapData(name);
          _asset = new ImageElement(src: data.toDataUrl());
          await _asset.onLoad.first;
          ASSET[name] = this;
          loaded = true;
          return this;
        }
      }

      // loads AudioElements into memory
      for (String ext in audioExtensions) {
        if (_uri.endsWith('.' + ext)) {
          // add file to the resourcemanager
          resources.addSound(name, _uri);
          await resources.load();
          _asset = resources.getSound(name);
          ASSET[name] = this;
          loaded = true;
          return this;
        }
      }

      // loads simple text files as a string.
      for (String ext in textExtensions) {
        if (_uri.endsWith('.' + ext)) {
          resources.addTextFile(name, _uri);
          await resources.load();
          String string = resources.getTextFile(name);
          _asset = string;
          ASSET[name] = _asset;
          loaded = true;
          return this;
        }
      }

      // Returns a decoded object from a json file
      for (String ext in jsonExtensions) {
        if (_uri.endsWith('.' + ext)) {
          resources.addTextFile(name, _uri);
          await resources.load();
          String string = resources.getTextFile(name);
          _asset = JSON.decode(string);
          ASSET[name] = _asset;
          loaded = true;
          return this;
        }
      }
    }
  }

  get() {
    if (loaded == false || _asset == null)
      throw ('Asset not yet loaded!');
    else
      return _asset;
  }
}
