part of coUclient;

handleChat()
{
//TODO: refactor into a method to add a chat panel (so that the user can add any chat they like)
//TODO: get/post chat text from a server (IRC?)

	addChatTab("Global Chat", true);
	addChatTab("Other Chat", false);
	querySelector("#ChatPane").children.add(makeTabContent("Local Chat",true));
	
}

void addChatTab(String channelName, bool checked)
{
	DivElement content = makeTabContent(channelName,false)
		..className = "content";
	DivElement tab = new DivElement()
		..className = "tab";
	RadioButtonInputElement radioButton = new RadioButtonInputElement()
		..id = "tab-"+channelName
		..name = "tabgroup" //only allow one to be selected at a time
		..checked = checked;
	LabelElement label = new LabelElement()
		..attributes['for'] = "tab-"+channelName
		..text = channelName;
	tab.children
		..add(radioButton)
		..add(label)
		..add(content);
	querySelector("#ChatTabs").children.add(tab);
}

DivElement makeTabContent(String channelName, bool useSpanForTitle)
{
	DivElement chatDiv = new DivElement()
		..className = "ChatWindow";
	SpanElement span = new SpanElement()
		..text = channelName;
	DivElement chatHistory = new DivElement()
		..className = "ChatHistory";
	TextInputElement input = new TextInputElement()
		..className = "ChatInput";

	if(useSpanForTitle)
		chatDiv.children.add(span);
	chatDiv.children
		..add(chatHistory)
		..add(input);
	
	input.onChange.listen((_)
	{
		DivElement chatString = new DivElement()
			..text = input.value;
		chatHistory.children.add(chatString);
		chatHistory.scrollTop = chatHistory.scrollHeight;
		input.value = '';
	});
	
	return chatDiv;
}