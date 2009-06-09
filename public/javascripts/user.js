document.observe('dom:loaded', function(){
	if($('edit_user')) {
		new Tabs('edit_user', 0);
  }

  var focuser = new Focuser;
});
