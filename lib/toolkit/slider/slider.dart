library slider;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_slider.dart';

@CustomTag('ur-slider')
class UrSlider extends PolymerElement
{
	@published num value = 50, min = 0, max = 100;
	UrSlider.created() : super.created();
}