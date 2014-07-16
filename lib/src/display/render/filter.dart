part of streetlib;

applyFilters(Element layerElement, Map source) {
      for (String filterName in source.keys) {
     //blur is super expensive (seemed to cut my framerate in half)
       //if(filterName == "blur")
        // {
        //   layerElement.style.filter += ('blur('+ source[filterName].toString() +'px) ');
        // }
       if(filterName == "brightness")
         {
           if(source[filterName] < 0) 
             layerElement.style.filter +=('brightness(' + (1-(source[filterName]/-100)).toString() +') ');
           if (source[filterName] > 0)
             layerElement.style.filter +=('brightness(' + (1+(source[filterName]/100)).toString() +') ');
         }
       if(filterName == "contrast")
         {
           if (source[filterName] < 0) 
             layerElement.style.filter += ('contrast(' + (1-(source[filterName]/-100)).toString() +') ');
           if (source[filterName] > 0)
             layerElement.style.filter += ('contrast(' + (1+(source[filterName]/100)).toString() +') ');
         }
       if(filterName == "saturation")
         {
           if (source[filterName] < 0) 
             layerElement.style.filter += ('saturation(' + (1-(source[filterName]/-100)).toString() +') ');
           if (source[filterName] > 0)
             layerElement.style.filter += ('saturation(' + (1+(source[filterName]/100)).toString() +') ');
         }
     };
}