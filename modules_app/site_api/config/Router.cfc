component {

	function configure() {
		route( "/" ).toRedirect( "api/v1" );
	}

}
