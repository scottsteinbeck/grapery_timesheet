
component {
	property name="flash" inject="coldbox:flash";
	property name="qb"    inject="QueryBuilder@qb";

	/**
	 * index
	*/
	function index( event, rc, prc ){
		event.setView("Auth/index");
	}

	/**
	 * update password
	*/
	function updatePassword( event, rc, prc ){
		if(!auth().check()) relocate("Auth.index"); //Just in case of a logout take back to homepage
		if(rc.password.len() >= 4 && rc.password == rc.passwordconfirmation){
			auth().user().setRequireReset(false);
			auth().user().setPassword(rc.password);
			auth().user().save();
			relocate("Dashboard.member")
		} else {
			flash.put( "login_form_errors", { "login" : "Password does not meet requirements" } );
			relocate("Auth.resetPassword") ;
		}
	}

	/**
	 * reset password
	*/
	function resetPassword( event, rc, prc ){
		if(!auth().check()) relocate("Auth.index"); //Just in case of a logout take back to homepage
		event.setView("Auth/resetPassword");
	}

	/**
	 * forgot password
	*/
	function forgotPassword( event, rc, prc ){
		event.setView("Auth/forgotPassword");
	}

	
	/**
	 * login
	*/
	function login( event, rc, prc ){
		sessionInvalidate();
		try{
			if(rc.username == '' || rc.password == '' ) throw(type="InvalidCredentials", message="missing credentials");
			auth().authenticate(rc.username,rc.password);
			auth().user().setLastLogin(now());
			auth().user().save();
			relocate("Main.index");
		} catch ( InvalidCredentials e ) {
			flash.put( "login_form_errors", { "login" : "Invalid Credentials" } );
			sessionInvalidate();
			relocate("Auth.index")
		}
	}

	/**
	 * logout
	*/
	function logout( event, rc, prc ){
		auth().logout();
		sessionInvalidate();
		relocate("Auth.index")
	}
}
