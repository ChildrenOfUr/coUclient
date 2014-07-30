part of coUclient;

abstract class Entity
{
	bool glow = false, dirty = true;
	
	void update(double dt);
	void render();
	
	void updateGlow(bool newGlow)
	{
		glow = newGlow;
		dirty = true;
	}
}