# `coUclient`

> Children of Ur's Dart-based browser client

This repository contains the source code for Children of Ur's Dart-based browser client.

[![Codeship Status for ChildrenOfUr/coUclient](https://codeship.com/projects/7e85d760-15e5-0132-d849-622a88ccaa2e/status?branch=master)](https://codeship.com/projects/33763)

## License

Children of Ur is based on Tiny Speck's browser-based game, Glitch&trade;. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

License information for other assets used in Children of Ur can be found in `ATTRIBUTION.md`.

## Usage

The code is live at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

If you want to run it locally or on your own server, you'll need to have an environment with [Dart](https://www.dartlang.org/) installed. Note that this repository does not currently contain any prebuilt files, so you'll also need a development environment. See [Contributing](#contributing) below.

## Contributing

`coUclient` is based on [Dart](https://www.dartlang.org/), so the first thing you'll need to do (if you haven't already) is to install it.

### Setting up a development environment

#### Mac OS X / macOS via `homebrew`

1. `brew update`
2. `brew tap dart-lang/dart`
3. `brew install dart --with-content-shell --with-dartium`

#### Windows

1. Download the <a href="https://www.dartlang.org/">Dart Editor</a>.

### Building

#### In Dart Editor

1. Go to File -> "Open Existing Folder" and open this project folder.
2. Make sure you have the required dependencies specified in pubspec.yaml. If you're missing
   any of these, try selecting a file in the project, and then running Tools -> Pub Get.

#### Command line

1. `pub get`
2. `pub build`

### Running local

1. `pub serve`

For best results, we recommend running the client in [Dartium](https://webdev.dartlang.org/tools/dartium).

> Note that if you installed dart via `homebrew` with the `--with-dartium` flag, Dartium is installed but possibly in a folder where you can't
> easily find it. Assuming that your `homebrew` prefix is `/usr/local` and the version of Dart you have installed is 1.23.0, try looking in
> `/usr/local/Cellar/dart/1.23.0` for a bundle named `Chromium.app`.

## General Roadmap ##

The project is built in <a href="https://www.dartlang.org" target="_blank">Dart</a>,
which is then compiled and minified into javascript and can run in most browsers. See our team collaboration
site on Trello for the current roadmap.

## Project Layout ##

`main.dart` serves as the main game loop. This class controls all functions within the game.
Dart classes and functions are in the `lib/src` folder.
Images, CSS and other web resources are in `web/assets`.
More development documentation is in the `doc` folder.
