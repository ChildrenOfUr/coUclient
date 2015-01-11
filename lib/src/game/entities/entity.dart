part of couclient;

abstract class Entity
{
	bool glow = false, dirty = true;
	ChatBubble chatBubble = null;
	CanvasElement canvas;

	void update(double dt);
	void render();

	void updateGlow(bool newGlow)
	{
		glow = newGlow;
		dirty = true;
	}
}