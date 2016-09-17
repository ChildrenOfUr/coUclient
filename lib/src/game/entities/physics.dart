part of couclient;

class Physics {
	String id;

	bool canJump;
	bool canTripleJump;
	bool infiniteJump;

	num speed;
	num zSpeed;
	num jumpMultiplier;

	num yVel;
	num yVelJump;
	num yVelTripleJump;

	Physics(this.id, {
		this.canJump: true,
		this.canTripleJump: true,
		this.infiniteJump: false,
		this.speed: 300,
		this.zSpeed: 30,
		this.jumpMultiplier: 1,
		this.yVel: 1000,
		this.yVelJump: 1000,
		this.yVelTripleJump: 1560
	});

	static final String DEFAULTID = 'normal';

	static final Map<String, Physics> _PHYSICS = {
		DEFAULTID: new Physics(DEFAULTID),
		'water': new Physics('water',
			canJump: false,
			canTripleJump: false,
			infiniteJump: true,
			jumpMultiplier: 0.5,
			yVel: 500),
		'plexus': new Physics('plexus',
			canJump: false,
			canTripleJump: false,
			infiniteJump: true,
			jumpMultiplier: 1.5,
			speed: 250),
	};

	static Physics get(String id) =>
		_PHYSICS[id] ?? _PHYSICS[DEFAULTID];

	static Physics getStreet(String label) =>
		get(mapData.getStreetPhysics(label));
}