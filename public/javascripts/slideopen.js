var Blinder = Class.create();
Blinder.prototype = {
  
  initialize: function(handle) {
		this.handle = handle;									
    Event.observe(handle, "click", this.slider.bindAsEventListener(this));  
  },

  slider: function(el) {
    this.handle.toggleClassName("active");
    this.handle.siblings().each(function(sibling){
			if(sibling.hasClassName('slideable'))	{
        sibling.toggle();
      }
		});
    this.storeSliderSetting(); 
	},

  storeSliderSetting: function() {
    var groupId   = this.handle.id.split("_")[1];
    var groupOpen = this.handle.hasClassName("active");
    var request = new Ajax.Request("/settings", {
      method: "post",
      parameters: {id: groupId, open: groupOpen}
    });
  }
};

Event.observe(window, "load", function() {
  $$(".slideHandle").each(function(handle){
			var blinder = new Blinder(handle);
	});
});
	
