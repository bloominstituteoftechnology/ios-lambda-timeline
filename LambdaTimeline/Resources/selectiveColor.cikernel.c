vec3 hsv (float red, float green, float blue) {
	float theMax = max(max(red, green), blue);
	float theMin = min(min(red, green), blue);


	// value
	float value = theMax;
	float hue = 0.0;
	float sat = 0.0;
	float delta = theMax - theMin;
	if (delta < 0.00001) {
		// hue and sat are 0 too - return
		return vec3(hue, sat, value);
	}

	//saturation
	if (theMax > 0.0) {
		sat = delta / theMax;
	} else {
		return vec3(hue, sat, value);
	}

	//hue
	if (red >= theMax) {
		hue = (green - blue) / delta + (green < blue ? 6.0 : 0.0);
	} else if (green >= theMax) {
		hue = 2.0 + (blue - red) / delta;
	} else {
		hue = 4.0 + (red - green) / delta;
	}

	// hue *= 1.0 / 6.0;

	return vec3(hue, sat, value);
}


kernel vec4 selectiveColor(__sample image_pixel, float rVal, float gVal, float bVal, float threshold) {

	float outValue = (image_pixel.r);

	outValue = min(outValue, clipHigh);
	outValue = max(outValue, clipLow);

	vec4 outPixel = vec4(outValue, outValue, outValue, opacity);


	return outPixel;

}
