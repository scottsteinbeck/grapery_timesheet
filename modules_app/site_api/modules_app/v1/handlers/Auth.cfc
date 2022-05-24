
component extends="BaseHandler" {
	property name="flash" inject="coldbox:flash";
	property name="qb"    inject="QueryBuilder@qb";

	/**
	 * index
	*/
	function index( event, rc, prc ){
		event.setLayout("Minimal").setView("Auth/index");
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
		event.setLayout("Minimal").setView("Auth/resetPassword");
	}

	/**
	 * forgot password
	*/
	function forgotPassword( event, rc, prc ){
		event.setLayout("Minimal").setView("Auth/forgotPassword");
	}

	/**
	 * lookup member and send password reset
	*/
	function sendPasswordReset( event, rc, prc ){
		var user = qb.select("oid")
						.from('users')
						.where("username",rc.username)
						.ORwhere("email",rc.username)
						.first();
		if(!user.len()){
			flash.put( "login_form_errors", { "login" : "Unrecognized User ID" } );
			relocate("Auth.forgotPassword")
		}

		runEvent(
			event         = 'v1:user.update',
			eventArguments= {
				rc = {
					'oid':  user.oid,
					'passwordReset': true
				}
			}
		)

		flash.put( "login_form_success", { "resetPassword" : "Password Reset Sent" } );
		relocate("Auth.forgotPassword")
	}

	/**
	 * login
	*/
	function login( event, rc, prc ){
		try{
			auth().authenticate(rc.username,rc.password);
			// if(auth().user().getRequireReset()) relocate("Auth.resetPassword"); // if we have temporarly reset their password, make them reset it
			relocate("Dashboard.index");
		} catch ( InvalidCredentials e ) {
			flash.put( "login_form_errors", { "login" : "Invalid Credentials" } );
			relocate("Auth.index")
		}
	}

	/**
	 * logout
	*/
	function logout( event, rc, prc ){
		auth().logout();
		relocate("Auth.index")
	}
}
