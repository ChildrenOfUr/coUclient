# How to contribute

### Sign our Contributor License Agreement (CLA)

Even for small changes, we ask that you please sign the CLA electronically
[here](https://developers.google.com/open-source/cla/individual).
The CLA is necessary because you own the copyright to your changes, even
after your contribution becomes part of our codebase, so we need your permission
to use and distribute your code. You can find more details
[here](https://code.google.com/p/dart/wiki/Contributing).

### Find the right place to change the code

A lot of the code in this repo is either generated automatically, or developed
elsewhere. For example, all elements definitions under `lib/src/paper-*` and
`lib/src/core-*` are downloaded automatically from other repositories using
`bower`.

If you would like to update HTML or Javascript code on a specific element, you
probably need to send a pull request in a different repository. The code for a
specific element lives under a repo of the same name under the [Polymer
organization](https://github.com/Polymer/). For example,
`lib/src/paper-input/paper-input.html` is actually developed on the [paper-input
repo](https://github.com/Polymer/paper-input), if you send the fix there, we
will get it automatically next time we run our update scripts.

In addition, the Dart libraries for each element are generated automatically by
running `tools/update.dart`. Most of the sources of this tool live in our
[core-elements repo](https://github.com/dart-lang/core-elements).
