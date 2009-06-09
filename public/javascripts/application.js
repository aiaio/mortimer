// Sets focus on first element of first form.
var Focuser = Class.create();
Focuser.prototype = {

  initialize: function() {
    var input = this.getFirstInput();
    if(input) {
      input.focus();
    }
  },

  // Finds the first non-hidden input from the first
  // form in the page.
  getFirstInput: function() {
    var forms = $$('form');
    if(forms.length > 0) {
      var form  = forms[0].identify();
      var input = $$('#' + form + ' input').detect(function(el) { 
        return el.type != "hidden";
      });

      return input;
    }
    else
     return null;
  }
};

function prepareExternalLinks() {
 if (!document.getElementsByTagName) return;
 var anchors = document.getElementsByTagName("a");
 for (var i=0; i<anchors.length; i++) {
   var anchor = anchors[i];
   if (anchor.getAttribute("href") &&
       anchor.getAttribute("rel") == "external")
     anchor.target = "_blank";
 }
}

var Tabs = Class.create();
Tabs.prototype = {
	initialize: function(container, active) {
		this.container = $(container);
		this.togglers  = this.container.select('.toggle li');
		this.tabs      = this.container.select('.tab_content');
		this.active    = active || 0;
		this.setup();
	},
	setup: function() {
		this.tabs[this.active].addClassName('active');
		this.togglers[this.active].addClassName('active');
		this.togglers.each(function(el, i) {
			el.onclick = function() {
				if (i != this.active) {
					el.addClassName('active');
					this.togglers[this.active].removeClassName('active');
					
					if(this.tabs.length == this.togglers.length){
						this.tabs[this.active].removeClassName('active');
						this.tabs[i].addClassName('active');
					}
				}
				this.active = i;
				return false;
			}.bind(this);
		}.bind(this));
	}
};

document.observe('dom:loaded', function(){
	try {
	  document.execCommand('BackgroundImageCache', false, true);
	} catch(e) {}

  prepareExternalLinks();
  var focuser = new Focuser;
});

