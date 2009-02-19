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
