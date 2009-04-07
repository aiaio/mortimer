// Littlebox.  A simple overlay library.

var Blinder = Class.create();
Blinder.prototype = {
  
  initialize: function(handle) {
		this.handle = handle;									
    Event.observe(handle, "click", this.slider.bindAsEventListener(this));  
  },

  slider: function(el) {
	this.handle.toggleClassName("active");
    this.handle.siblings().each(function(sibling){
			if(sibling.hasClassName('slideable'))	sibling.toggle();  									
		});
		/*
		if (this.handle.innerHTML.include("+"))
		  this.handle.innerHTML = " &#8210; ";
		else
		  this.handle.innerHTML = " + ";
		*/
	}
}

Event.observe(window, "load", function() {
  $$(".slideHandle").each(function(handle){
			new Blinder(handle);
	});
});
	
