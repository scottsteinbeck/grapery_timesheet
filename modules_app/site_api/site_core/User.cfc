component accessors="true" {

	property name="wirebox" inject="wirebox";

	property name="id";
	property name="name";
	property name="firstName";
	property name="type";

	User function init(userData)
	{
		if(arguments.keyExists("userData")){
			variables.id = userData.id;
			variables.name = userData.name;
			variables.firstName = userData.first_name;
			variables.type = userData.user_type_id;
		}

		return this;
	}

	/** Getter/Setter Overrides */
	public User function setPassword( required string password ){
		QueryExecute("
			UPDATE users
			SET uPassword = :password
			WHERE 1 = 2
		",
		{
			password = { value: password, cfsqltype: "varchar"}

		});

		return;
		// return assignAttribute( "password", hash_password( arguments.password ) );
	}

	/**
	 * hasPermission
	*/
	function hasPermission( permission ){
		return listFindNoCase(variables.permissions, arguments.permission)
	}

	/**
	 * isLoggedIn
	*/
	function isLoggedIn(){
		return variables.LoggedIn;
	}


	public boolean function hasPermission( required string permission ){
		return true;
	}

	public boolean function isValidCredentials( required string username, required string password ){
		return 0 < QueryExecute("
			SELECT *
			FROM users
			WHERE name = :password AND first_name = :username
			LIMIT 1
		",
		{
			username = { value: username, cfsqltype: "varchar"},
			password = { value: password, cfsqltype: "varchar"}
			// password: { value: hash_password(password), cfsqltype: "varchar"}
		},{returnType: "array"}).len();
	}

	public User function retrieveUserByUsername( required string username ){
		userData = QueryExecute("
				SELECT *
				FROM users
				WHERE uFirstName = :username
				LIMIT 1
			",
			{ username = { value: username, cfsqltype: "varchar"}},
			{ returnType: "array"}
		);

		return wirebox.getInstance("User@site_core", {userData : userData[1]});
	}

	public User function retrieveUserById( required numeric id ){
		userData = QueryExecute("
				SELECT *
				FROM users
				WHERE id = :id
				LIMIT 1
			",
			{ id = { value: id, cfsqltype: "cf_sql_integer"}},
			{ returnType: "array"}
		);

		return wirebox.getInstance("User@site_core", {userData : userData[1]});
	}


	/*** RELATIONSHIPS ***/
/* 	function members() {
		return hasOne( "Member@site_core", "user_id" );
    }

	function roles() {
		return hasOne( "Role@site_core", "role", "id" );
    }
 */
	/* scopedFields */



	/* utility functions */
	public string function hash_password(password) {
		var salt = 'A+JirLQkPHeXRuhoD+8iWw94WGOaEaCv';
		var hashedPass = hash(salt & trim(password), "SHA-256", "UTF-8");
		hashedPass = rereplace(hashedPass,"'", "");
		return lcase(hashedPass);
	}


	function injectTemplateData( dataObj, template){
		for(var i in dataObj){
			template = replace(template, "@#i#@", dataObj[i],"All");
		}
		return template;
	}

	function generateForgotPasswordContent(member_number, password){
		var wordlistFile = fileRead(expandPath("views/emails/forgotPassword.tpl"));
		var dataList = {
			'coalition': 'krwca',
			'coalitionupper': ucase('krwca'),
			'memberid': member_number,
			'password': password
		};
		return injectTemplateData(dataList, wordlistFile);
	}

}

