function selectText()
{
  el = $('hidden_password');
  if (el.createTextRange) 
  {
    var oRange = el.createTextRange();
    oRange.moveStart("character", 0);
    oRange.moveEnd("character", el.value.length);
    oRange.select();
  }
    else if (el.setSelectionRange) 
    {
            el.setSelectionRange(0, el.value.length);
    }
    el.focus();
 }

function observeClick() {
 Event.observe($("password_container"), "click", function(){
    $("password_container").innerHTML = $("hidden_password").value
  });
}

function setupLittleBox() {
  setTimeout("selectText()", 500);
  setTimeout("observeClick();", 500);
}

// Sets focus on first element of first form.
var Focuser = Class.create();

Focuser.prototype = {

  initialize: function() {
    var input = this.getFirstInput();
    if(input) {
      input.focus();
    }
  },

   getFirstInput: function() {
     if($$('form')) {
       var form  = $$('form')[0].identify();
       var input = $$('#' + form + ' input').detect(function(el) { 
         return el.type != "hidden";
       });

       return input;
      }
    else
      return null;
  }
};

function externalLinks() {
 if (!document.getElementsByTagName) return;
 var anchors = document.getElementsByTagName("a");
 for (var i=0; i<anchors.length; i++) {
   var anchor = anchors[i];
   if (anchor.getAttribute("href") &&
       anchor.getAttribute("rel") == "external")
     anchor.target = "_blank";
 }
}
window.onload = externalLinks;

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
}

document.observe('dom:loaded', function(){
	try {
	  document.execCommand('BackgroundImageCache', false, true);
	} catch(e) {}

  var focuser = new Focuser;
});

