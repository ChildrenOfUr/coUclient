part of coUclient;

class InteractionWindow
{
	static Element create()
	{
		DivElement interactionWindow = new DivElement()..id="InteractionWindow"..className="interactionWindow";
		
		DivElement header = new DivElement()..className="PopWindowHeader handle";
		DivElement title = new DivElement()..id="InteractionTitle";
		SpanElement close = new SpanElement()..id="CloseInteraction"..className="fa fa-times fa-lg red PopCloseEmblem";
		header..append(title)..append(close);
		
		DivElement content = new DivElement()..id="InteractionContent";
		
		interactionWindow..append(header)..append(content);
		
		return interactionWindow;
	}
	
	static void destroy()
	{
		querySelector("#InteractionWindow").remove();
	}
}