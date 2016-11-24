part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  static String messagesLogged = "";
  String metaHeader = '';
  Service debugService;
  bool sending = false;
  Element component = querySelector("user-feedback");

  BugWindow() {
		debugService = new Service(['debug'], logMessage);

		prepare();

		metaHeader = '/////////////' + ' USER AGENT ' + '/////////////' + '\n'
			+ window.navigator.userAgent + ' | (ping time untested)' + '\n'
			+ '/////////////' + ' CLIENT LOG ' + '/////////////' + '\n';

		setupUiButton(view.bugButton, openCallback: _prepareReport);
  }

  @override
  void open({bool ignoreKeys: false}) {
	  super.open(ignoreKeys: ignoreKeys);
	  view.bugReportMeta.text = metaHeader + messagesLogged;
	  //screenshot();
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
					  ..append("useragent", window.navigator.userAgent + ' | Server ping: ${await checkLag(true)} ms')
					  ..append("username", game.username)
					  ..append("category", view.bugReportType.value);
				  await HttpRequest.request("http://${Configs.utilServerAddress}/report/add", method: "POST", sendData: data);
				  // Complete
				  close();
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
  }
}
