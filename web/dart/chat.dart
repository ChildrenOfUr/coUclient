part of coUclient;

handleChat()
{
//TODO: refactor into a method to add a chat panel (so that the user can add any chat they like)
//TODO: get/post chat text from a server (IRC?)

	SpanElement globalSpan = new SpanElement()
		..text = "Global Chat";
	SpanElement localSpan = new SpanElement()
		..text = "Local Chat";
	DivElement globalDiv = new DivElement()
		..className = "ChatWindow";
	DivElement localDiv = new DivElement()
		..className = "ChatWindow";
	DivElement globalChatHistory = new DivElement()
		..className = "ChatHistory";
	DivElement localChatHistory = new DivElement()
		..className = "ChatHistory";
	TextInputElement globalInput = new TextInputElement()
		..className = "ChatInput";
	TextInputElement localInput = new TextInputElement()
		..className = "ChatInput";
	
	globalDiv.children
		..add(globalSpan)
		..add(globalChatHistory)
		..add(globalInput);
	localDiv.children
		..add(localSpan)
		..add(localChatHistory)
		..add(localInput);
	Element chatPane = querySelector("#ChatPane");
	chatPane.children
		..add(globalDiv)
		..add(localDiv);
	
	globalInput.onChange.listen((_) //press enter
	{
		DivElement chatString = new DivElement()
			..text = globalInput.value;
		globalChatHistory.children.add(chatString);
		globalChatHistory.scrollTop = globalChatHistory.scrollHeight; //autoscroll to bottom when you add a message
		globalInput.value = '';
	});
	localInput.onChange.listen((_)
	{
		DivElement chatString = new DivElement()
			..text = localInput.value;
		localChatHistory.children.add(chatString);
		localChatHistory.scrollTop = localChatHistory.scrollHeight;
		localInput.value = '';
	});
}