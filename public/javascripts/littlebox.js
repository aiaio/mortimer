// Littlebox.  A simple overlay library.

var Littlebox = Class.create();
Littlebox.prototype = {
  initialize: function(link, callbacks) {
    this.url = link.href;
    link.writeAttribute({"href":"javascript:void(0);"});
    this.setup(link);
    this.callbacks = new Array;
    this.callbacks.push(callbacks);
  },

  // Add the click handler to the given link.            
  setup: function(link) {
    Event.observe(link, "click", this.handler.bindAsEventListener(this));
  },
         
  // Get the contents of the littleBox and
  // show on success.           
  handler: function(boxId) {
    new Ajax.Request(this.url, {
      method: "get",
      onSuccess: function(transport) {
        this.createBox(transport.responseText);
        this.createOverlay();
        this.showBox();
      }.bind(this),
      onFailure: function(transport) {
        window.location = transport.responseText;
      }
    });
  },
  
  // Create a new littleBox, add it to the DOM,
  // and request its contents.
  createBox: function(html) {
    var box   = new Element("div", {"id": "littleBox"});
    var closeButton = new Element("a", {"id": "close", "class": "close", "href": "javascript:void(0);"});
    document.body.appendChild(box);
    box.innerHTML = html;
  },

  // Show the littleBox and add a callback to resize.         
  showBox: function() {
    box = $("littleBox");
    this.adjust(box);
    Event.observe(window, "resize", this.adjust.bindAsEventListener(box));
    box.show();
    this.callbacks[0]();
  },
  
  // Add the big, gray overlay to the DOM.
  createOverlay: function(){
    var overlay = new Element("div", {"id": "overlay"});
    overlay.setStyle({
      height:  "100%",
      width:   "100%"});

    // When the gray background is clicked, the overlay will dissappear.
    Event.observe(overlay, "click", this.hideElements.bindAsEventListener(this));
    document.body.appendChild(overlay);
  },

  // Center the box in the window.         
  adjust: function(box) {
    // Get the dimensions of the littleBox.
    var box = $("littleBox");
    if (box == null) return; 
    var boxDimensions = box.getDimensions(); 

    // Get the dimensions of the window and scroll.
    var winDimensions = document.viewport.getDimensions();
    var scrolls       = document.viewport.getScrollOffsets();
    
    // Calculate a new top coordinate for the littleBox.
    var newTop     = scrolls.top + (winDimensions.height / 2) - (boxDimensions.height / 2); 
    if (newTop < 0) newTop = 0;

    // Calculate the new left coordinate for the littleBox.
    var newLeft     = scrolls.left + (winDimensions.width / 2) - (boxDimensions.width / 2); 
    if (newLeft < 0) newLeft = 0;

    box.setStyle({
      left: newLeft + "px",
      top:  newTop  + "px"});
    
  },
  
  hideElements: function() {
    $("littleBox").hide();
    $("overlay").hide();
    this.removeElements();
    Event.stopObserving(window, "resize", this.adjust.bindAsEventListener($("littleBox")));
  },

  removeElements: function() {
    $("littleBox").remove();
    $("overlay").remove();
  }

}

Event.observe(window, "load", function() {
  $$(".littlebox").each(function(link) {
    new Littlebox(link, setupLittleBox);
  });
});

