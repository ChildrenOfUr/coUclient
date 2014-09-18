part of couclient;

WorldMap worldMap;

class WorldMap
{
  Map<String,String> hubInfo;
  Map<String,Map> hubMaps;
  Map<String,String> moteInfo;

  DataMaps map = new DataMaps();

  WorldMap(String hub_id){
    hubInfo = map.data_maps_hubs[hub_id]();
    hubMaps = map.data_maps_maps[hub_id]();
    moteInfo = map.data_maps_streets['9']();
    ui.mapTitle.text = hubInfo['name'];
    ui.mapImg.style.backgroundImage = 'url(' +hubInfo['bg']+ ')';
    //mapImg.setInnerHtml('<img src="' + hubInfo['fg']+ '"/>');
    ui.mapCanvas.context2D.clearRect(0, 0, ui.mapCanvas.width, ui.mapCanvas.height);

    CanvasElement lineCanvas = new CanvasElement();
    CanvasElement textCanvas = new CanvasElement();

    lineCanvas.context2D.lineCap="round";
    lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

    textCanvas.width = ui.mapCanvas.width;
    textCanvas.height = ui.mapCanvas.height;
    textCanvas.context2D.fillStyle = "#000000";

    ui.mapCanvas.context2D.miterLimit=2;

    // TODO: Low priority, performance improvement

    for (Map object in hubMaps['objs'].values) {

      // Street Objects
      if (object['type'] == 'S') {
        String streetName = moteInfo[hub_id][object['tsid']];
        int streetMiddleX = ((object['x1']+object['x2'])/2).round();
        int streetMiddleY = ((object['y1']+object['y2'])/2).round();


             lineCanvas.width = ui.mapCanvas.width;
             lineCanvas.height = ui.mapCanvas.height;
             lineCanvas.context2D.lineCap="round";
             lineCanvas.context2D.miterLimit=2;
             lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

             // If this is the street we are on, style is slightly different
             if (object['tsid'].substring(1) == currentStreet._data['tsid'].substring(1)) {
               lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 1)";
             }

             lineCanvas.context2D.lineWidth = 5;
             lineCanvas.context2D.moveTo(object['x1'],object['y1']);
             lineCanvas.context2D.lineTo(object['x2'],object['y2']);
             lineCanvas.context2D.stroke();
             ui.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);

             //ui.mapCanvas.context2D.beginPath();

             // Rotates the canvas to the slope of the street's line. Translate to center of text, rotate around that point

             //streetHitBox.style.transform = "rotate("+ (atan((object['y2']-object['y1'])/(object['x2']-object['x1']))).toString() +"deg)";
             //TODO: draw shrine and vendor icons here

             // For name of each street
             textCanvas.context2D.save();
             textCanvas.context2D.miterLimit=2;
             textCanvas.context2D.font = "13px Arial bold";

             textCanvas.context2D.moveTo(0,0);
             textCanvas.context2D.translate(streetMiddleX, streetMiddleY);
             textCanvas.context2D.rotate(atan((object['y2']-object['y1'])/(object['x2']-object['x1'])));
             textCanvas.context2D.translate(-streetMiddleX, -streetMiddleY);

             // If this is the street we are on, style is slightly different
             if (object['tsid'].substring(1) == currentStreet._data['tsid'].substring(1)) {
               textCanvas.context2D.fillStyle = "#C50101";
               textCanvas.context2D.font = "15px Arial bold";
               drawStar(textCanvas.context2D,streetMiddleX,streetMiddleY-14,10,fillColor:textCanvas.context2D.fillStyle,strokeColor:textCanvas.context2D.strokeStyle);
             }

             textCanvas.context2D.lineWidth = 3;
             textCanvas.context2D.strokeStyle = "#FFFFFF";
             textCanvas.context2D.strokeText(streetName,(streetMiddleX - (ui.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));
             textCanvas.context2D.fillText(streetName,(streetMiddleX - (ui.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));

             textCanvas.context2D.restore();

        /* TODO: WIP, working towards onClick events like with street signs, not far along
        //String tsid = exit['tsid'].replaceFirst("L", "G");
          SpanElement streetHitBox = new SpanElement()
          * //width is length of street line
              ..style.width = sqrt(pow(object['x2']-object['x1'],2) + pow(object['y2']-object['y1'],2)).round().toString() + "px"
              ..style.height = "10px"
              ..style.position = "absolute"
              ..style.top = object['y1'].toString() + "px"
              ..style.left = object['x1'].toString() + "px"
              ..style.backgroundColor = "black"
              //..text = streetName
              ..className = "ExitLabel";
              //              ..attributes['url'] = 'http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/' + moteInfo[hub_id][object['tsid']] +'.callback.json'
              //              ..attributes['tsid'] = moteInfo[hub_id][object['tsid']];
        */
        //mapCanvas.append(streetHitBox);
      }

      // Exit Objects
      else if (object['type'] == 'X') {

        // Drawing the "GO" Circle. Needs small arrow addition, math similar to text below
        ui.mapCanvas.context2D.beginPath();
        ui.mapCanvas.context2D.arc(object['x'], object['y'], 18, 0, 2 * PI, false);
        ui.mapCanvas.context2D.fillStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        ui.mapCanvas.context2D.fill();
        ui.mapCanvas.context2D.lineWidth = 2;
        ui.mapCanvas.context2D.font = "18px Arial";
        ui.mapCanvas.context2D.fillStyle = '#FFFFFF';
        ui.mapCanvas.context2D.fillText('GO',object['x']-14, object['y']+7);

        // Drawing the name of the region, angle specified in 'label', trig to ajdust pos based on angle
        ui.mapCanvas.context2D.font = "14px Arial";
        ui.mapCanvas.context2D.strokeStyle = '#FFFFFF';
        ui.mapCanvas.context2D.stroke();
        ui.mapCanvas.context2D.lineWidth = 4;
        ui.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
            object['x'] + (sin(PI/180*object['label']) * 70) - ui.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
        ui.mapCanvas.context2D.lineWidth = .9;
        ui.mapCanvas.context2D.strokeStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        ui.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
            object['x'] + (sin(PI/180*object['label']) * 70) - ui.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
      }
    }
    ui.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);
    ui.mapCanvas.context2D.drawImage(textCanvas, 0, 0);

    //scale canvas to match map window size
    num scaleX = ui.mapCanvas.parent.clientWidth/ui.mapCanvas.clientWidth;
    num scaleY = ui.mapCanvas.parent.clientHeight/ui.mapCanvas.clientHeight;
    ui.mapCanvas.style.transform = 'scaleX($scaleX) scaleY($scaleY)';
    ui.mapCanvas.style.transformOrigin = '-21px -21px';
  }

  /**
   * Taken from http://programmingthomas.wordpress.com/2012/05/16/drawing-stars-with-html5-canvas/
   *
   * You call the function by using star(context, x of center, y of center, radius)
   *
   **/
  void drawStar(CanvasRenderingContext2D ctx, num xOfCenter, num yOfCenter, num radius,
      {num numPoints : 5, num insetFraction : .5, String fillColor : "#ffff00",
    	String strokeColor: "#000000", num strokeWidth : 2})
  {
      ctx.save();
      ctx.fillStyle = fillColor;
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = strokeWidth;
      ctx.beginPath();
      ctx.translate(xOfCenter, yOfCenter);
      ctx.moveTo(0,0-radius);
      for (var i = 0; i < numPoints; i++)
      {
          ctx.rotate(PI / numPoints);
          ctx.lineTo(0, 0 - (radius*insetFraction));
          ctx.rotate(PI / numPoints);
          ctx.lineTo(0, 0 - radius);
      }
      ctx.fill();
      ctx.stroke();
      ctx.restore();
  }
}