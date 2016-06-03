part of couclient;

final int TEXT_ANIM_MS = 2000;
// Also set in web/files/css/desktop/overlays/text-anim.css

Future animateText(Element parent, String text, String cssClass) async {
	DivElement animation = new DivElement()
		..classes = ["text-anim", cssClass]
		..text = text;

	parent.append(animation);

	await new Future.delayed(new Duration(milliseconds: TEXT_ANIM_MS));

	animation.remove();
}
