/**
 * Manage member
 */
component extends="BaseHandler" {

	// DI

	property name="qb"         inject="QueryBuilder@qb";

	// HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		// delete: "DELETE"
	};

	/**
	 * Display a list of member
	 */
	function index( event, rc, prc ) {
		// Get resources here

		var data = qb
			.select( "users.oid, first_name, last_name, email, username, role, can_login, name" )
			.from( "users" )
			.joinRaw(
				"roles",
				"users.role",
				"roles.id"
			)
			.where("role",3)
			.ORwhere("role",4)
			.when( rc.filter != "", (q) => {
				q.where("users.username","Like","%#rc.filter#%");
				q.ORwhere("users.last_name","Like","%#rc.filter#%");
				q.ORwhere("users.first_name","Like","%#rc.filter#%");
				q.ORwhere("users.email","Like","%#rc.filter#%");
			})
			.orderByRaw( "first_name asc" )
			.paginate(rc.currentPage, rc.perPage);

		return data;
	}

	/**
	 * Create/Update a member
	 */
	function create( event, rc, prc ) {
		rc.requireReset = true;
		var result = validateOrFail(
			target = rc,
			constraints = {
				"username" : {
					"required" : true,
					"unique" : { "table" : "users", "column" : "username" }
				},
				"role" : { "required" : true },
				"email" : { "required" : true },
				"first_name" : { "required" : true },
				"last_name" : { "required" : true },
				"can_login" : { "required" : true },
				"require_reset" : { },
				"password" : { },
				"passwordConfirm" : { "sameAs" : "password" }
			}
		);

		var user = getInstance( "User@site_core" ).create( result, true);
		return event.getResponse().setData(user.getMemento());
	}


	/**
	 * Create/Update a member
	 */
	function update( event, rc, prc ) {
		var result = validateOrFail(
			target = rc,
			constraints = {
				"oid" : {
					"required": true,
				},
				"username" : {
					"required" : true
				},
				"role" : { "required" : true },
				"email" : { "required" : true },
				"first_name" : { "required" : true },
				"last_name" : { "required" : true },
				"can_login" : { "required" : true },
				"password" : { },
				"passwordConfirm" : { "sameAs" : "password" }
			}
		);

		var user = getInstance( "User@site_core" ).findOrFail( rc.oid );
		user.update(
            event.getOnly( [
                "username",
                "role",
                "email",
                "last_name",
                "first_name",
                "can_login"
            ] )
        );

        if ( event.valueExists( "password" ) ) {
            user.update( { "password": rc.password } );
        }

		event.getResponse().setData(user.getId()).addMessage("User Account Updated");
	}

	/**
	 * Delete a member
	 * at this time the feature is disabled because users can only be activated/deactivated
	 */
	/* function delete( event, rc, prc ) {
		event.paramValue( "id", 0 );
	} */

}
