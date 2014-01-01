part of coUclient;

// this file is temporary.
// Once the systems are properly designed they will be placed in their correct locations in the engine folder.

class CameraSystem extends EntityProcessingSystem {
  ComponentMapper<CameraPosition> cameraPositionMapper;

  CameraSystem() : super(Aspect.getAspectForAllOf([CameraPosition]));
  
  void processEntity(Entity entity){
    CameraPosition position = cameraPositionMapper.get(entity);
    position.x = CurrentPlayer.posX-gameScreen.clientWidth~/2;
    position.y = CurrentPlayer.posY-gameScreen.clientHeight~/2;
    
    //Camera can't go outside the bounds of the lvl
    //if (position.x < 0)
    //  position.x = 0;
    //if (position.x > CurrentStreet.width - gameScreen.clientWidth)
    //  position.x = CurrentStreet.width - gameScreen.clientWidth;
    //if (position.y < 0)
    //  position.y = 0;
    //if (position.y > CurrentStreet.height-gameScreen.clientHeight)
    //  position.y = CurrentStreet.height-gameScreen.clientHeight;
  }
}