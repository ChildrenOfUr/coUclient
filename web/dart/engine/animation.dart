part of coUclient;

class Animation
{
	String backgroundImage, animationName, animationStyleString;
	int width, height;
	
	Animation(this.backgroundImage,this.animationName);
	
	Future<Animation> load()
	{
		Completer c = new Completer();
		
		//need to get the avatar background image size dynamically
		//because we cannot guarentee that every glitchen has the same dimensions
		//additionally each animation sprite has different dimensions even for the same glitchen
		ImageElement temp = new ImageElement(src: backgroundImage);
		temp.onLoad.listen((_)
		{
			int width = temp.width;
			int height = temp.height;
			
			//if unknown what animation to play, use the 15th frame of the walk cycle
			if(animationName == 'stillframe')
			{
				this.width = width~/15;
				this.height = height;
				
				//there are 12 frames in the walk cycle, the last 3 in the base.png image are not part of it
				int endPos = width - (width~/15);
				CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
				String stillframe = '@-webkit-keyframes stillframe { from { background-position: '+endPos.toString()+'px;} to { background-position: -'+endPos.toString()+'px;}}';
				
				try
				{
					styleSheet.insertRule(stillframe,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				stillframe = '@keyframes stillframe { from { background-position: '+endPos.toString()+'px;} to { background-position: -'+endPos.toString()+'px;}}';
				try
				{
					styleSheet.insertRule(stillframe,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				animationStyleString = 'stillframe .8s steps(1)';
			}
			
			//if walk-cycle
			if(animationName == 'base')
			{
				this.width = width~/15;
				this.height = height;
				
				//there are 12 frames in the walk cycle, the last 3 in the base.png image are not part of it
				int endPos = width - (width~/15)*3;
				CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
				String base = '@-webkit-keyframes base { from { background-position: 0px;} to { background-position: -'+endPos.toString()+'px;}}';								 
				try
				{
					styleSheet.insertRule(base,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				base = '@keyframes base { from { background-position: 0px;} to { background-position: -'+endPos.toString()+'px;}}';
				try
				{
					styleSheet.insertRule(base,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				animationStyleString = 'base .8s steps(12) infinite';
			}
			
			//if idle animation
			if(animationName == 'idle')
			{
				this.width = width~/29;
				this.height = height~/2;
				
				//there are 57 total frames split over 2 rows (29 and 28)
				//moving to the second row causes flicker so we will use the top row only
				//and run it repeatedly
			
				CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
				String idle = '@-webkit-keyframes idle {0%{background-position: 0px 0px;} 90%{background-position: 0px 0px;} 100%{background-position: -'+width.toString()+'px 0px;}}';
				try
				{
					styleSheet.insertRule(idle,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				idle = '@keyframes idle {0%{background-position: 0px 0px;} 90%{background-position: 0px 0px;} 100%{background-position: -'+width.toString()+'px 0px;}}';
				try
				{
					styleSheet.insertRule(idle,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				animationStyleString = 'idle 10s steps(29) infinite';
			}
			
			//if jump animation
			if(animationName == 'jump')
			{
				this.width = width~/33;
				this.height = height;
				
				int frame32 = width - this.width;
				
				CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
				String jump = '@-webkit-keyframes jump { from { background-position: 0px;} to { background-position: -'+frame32.toString()+'px;}}';
				try
				{
					styleSheet.insertRule(jump,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				jump =' @keyframes jump { from { background-position: 0px;} to { background-position: -'+frame32.toString()+'px;}}';
				try
				{
					styleSheet.insertRule(jump,1); //inserting at 0 throws an error, 1 seems fine
				}
				catch(error){}
				
				animationStyleString = 'jump 1.1s steps(32) forwards';
			}
			
			c.complete(this);
		});
		
		return c.future;
	}
}