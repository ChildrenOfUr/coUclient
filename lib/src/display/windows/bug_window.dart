part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  String messagesLogged = "";
  Service debugService;
  bool sending = false;
  Element component = querySelector("user-feedback");

  BugWindow() {
	  debugService = new Service(['debug'], logMessage);

	  prepare();
	  String headerDeco = "/////////////"; // prime number of forward slashes
	  view.bugReportMeta.text = headerDeco + ' USER AGENT ' + headerDeco + '\n' + window.navigator.userAgent + '\n' + headerDeco + ' CLIENT LOG ' + headerDeco;

	  setupUiButton(view.bugButton, openCallback: _prepareReport);
  }

  @override
  void open({bool ignoreKeys: false}) {
	  super.open(ignoreKeys: ignoreKeys);
	  screenshot();
  }

  void _prepareReport() {
	  Element w = this.displayElement;
	  TextAreaElement input = w.querySelector("textarea");
	  input.value = "";

	  // Submits the bug
	  w.querySelector("ur-button").onClick.listen((_) async {
		  if (!sending) {
			  sending = true;
			  if (view.bugReportTitle.value.trim() != "") {
				  // Send to server
				  FormData data = new FormData()
					  ..append("token", rsToken)
					  ..append("title", view.bugReportTitle.value)
					  ..append("description", input.value)
					  ..append("log", messagesLogged)
					  ..append("useragent", window.navigator.userAgent)
					  ..append("username", game.username)
					  ..append("category", view.bugReportType.value);
				  await HttpRequest.request("http://${Configs.utilServerAddress}/report/add", method: "POST", sendData: data);
				  // Complete
				  w.hidden = true;
				  view.bugReportTitle.value = "";
				  input.value = "";
			  }
			  sending = false;
		  }
	  });
  }

	Future<String> screenshot() async {
		Completer<CanvasElement> render = new Completer();

		// Get this window out of the way
		displayElement.hidden = true;

		// Call html2canvas
		CanvasElement canvas;
		try {
			JsObject args = new JsObject.jsify({
				'allowTaint': false, // Whether to allow cross-origin images to taint the canvas
				'taintTest': true, // Whether to test each image if it taints the canvas before drawing them
				'useCORS': true, // Whether to attempt to load cross-origin images as CORS served, before reverting back to proxy
				'logging': true, // Whether to log events in the console.
				'onrendered': (CanvasElement canvas) {
					render.complete(canvas);
				}
			});
			context.callMethod('html2canvas', [document.body, args]);

			// Convert to base64
			canvas = await render.future;
			window.open(canvas.toDataUrl(), '_blank');

			view.bugScreenshot.disabled = false;
		} catch (e) {
			logMessage('Could not take bug report screenshot');
			view.bugScreenshot.disabled = true;
		} finally {
			// Re-show the bug window
			displayElement.hidden = false;

			return canvas?.toDataUrl();
		}
  }

  void logMessage(var message) {
	  messagesLogged += message + "\n";
	  view.bugReportMeta.text += message + "\n";
  }
}
