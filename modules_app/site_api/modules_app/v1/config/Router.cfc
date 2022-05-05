component {

	function configure() {
		resources( resource = "timeEntrys", parameterName = "id-numeric" );

		resources( resource = "changeLog", parameterName = "id-numeric" );
		
		route( "export/:handler/:action" ).end();
	}

}
