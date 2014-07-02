import 'dart:convert';

String token, team;

// A message passed between your app and slack.
class Message {
  // Basic message vars
  String text;
  String username;
  String icon_url;
  String icon_emoji;
  
  /* 
   * Any number of attachments
   * can be added to the message
  */
  List <Attachment> attachments;
  
  String toString() {
    Map message = new Map();
    
    if (text != null)
      message['text'] = text;
    
    if (username != null)
      message['username'] = username;
    
    if (icon_url != null)
      message['icon_url'] = icon_url;
    
    if (icon_emoji != null)
      message['icon_emoji'] = icon_emoji;

    if (attachments != null) {
      List attached_maps = [];
      for (Attachment a in attachments)
        attached_maps.add(a.toMap());
        message['attachments'] = attached_maps;
     }
    return JSON.encoder.convert(message);
  }
}

class Attachment {
  String fallback; // Required
  String pretext;
  String text;
  String color; // 'good', 'warning', 'danger' or hex.
  
  Map<String,String> fields;
  
  String toString() {
    return JSON.encoder.convert(this.toMap());
  }
  
  Map toMap() {
    Map attachment = new Map()
      ..['fallback'] = fallback;
      
    if (pretext != null)  
      attachment['pretext'] = pretext;
    if (text != null) 
      attachment['text'] = text;
    if (color != null) 
      attachment['color'] = color;
    
    if (fields != null)
      attachment['fields'] = fields;
    
    return attachment;    
  }
  
}