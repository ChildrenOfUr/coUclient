part of coUclient;

// this file is temporary.
// Once the systems are properly designed they will be placed in their correct locations in the engine folder.

class CameraSystem extends EntityProcessingSystem {
  ComponentMapper<CameraPosition> cameraPositionMapper;
  CameraSystem() : super(Aspect.getAspectForAllOf([CameraPosition]));
  void processEntity(Entity entity){
    
    
  }
}