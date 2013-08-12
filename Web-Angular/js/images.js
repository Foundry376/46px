var replaceInto = function() {
	var canvas = document.getElementById(this.canvas);
	var ctx = canvas.getContext("2d");
	canvas.width = this.width * zoom;
	canvas.height = this.height * zoom;

	ctx.drawImage(this,0,0);
	var imgData = ctx.getImageData(0,0,this.width,this.height);
	ctx.clearRect(0,0,this.width, this.height);
	
	// Draw the zoomed-up pixels to a different canvas context
	for (var x=0;x<this.width;++x){
	  for (var y=0;y<this.height;++y){
		// Find the starting index in the one-dimensional image data
		var i = (y*this.width + x)*4;
		var r = imgData.data[i];
		var g = imgData.data[i+1];
		var b = imgData.data[i+2];
		var a = imgData.data[i+3];
		ctx.fillStyle = "rgba("+r+","+g+","+b+","+(a/255)+")";
		ctx.fillRect(x*zoom,y*zoom,zoom,zoom);
	  }
	}
};