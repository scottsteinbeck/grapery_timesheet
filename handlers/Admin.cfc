component {

	any function index( event, rc, prc ) {
		relocate( "Admin.StaffList" );
	}

	/**
	 * Manage Staff List
	 */
	any function StaffList( event, rc, prc ) {
		prc.title = "Manage Staff List";
	}

}
