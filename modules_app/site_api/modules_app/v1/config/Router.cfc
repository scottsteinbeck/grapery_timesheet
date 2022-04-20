component {

	function configure() {
		resources( resource = "timeEntrys", parameterName = "id-numeric" );
		
		route( "export/:handler/:action" ).end();
	}

}
