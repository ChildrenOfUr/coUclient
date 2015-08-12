part of couclient;

class SpriteSheet {
	int width;
	int height;
	xl.BitmapData source;
	List<xl.BitmapData> frames;

	SpriteSheet(this.source, this.width, this.height, {int frameCount:null}) {
		frames = source.sliceIntoFrames(width, height, frameCount:frameCount);
	}

	xl.BitmapData operator[](int index) {
		return frameAt(index);
	}

	xl.BitmapData frameAt(int index) {
		//try to be forgiving about the bounds
		if(index == -1) {
			index = 0;
		}
		if(index == frames.length) {
			index = frames.length - 1;
		}
		return frames[index];
	}
}