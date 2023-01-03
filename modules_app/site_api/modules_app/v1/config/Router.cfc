component {

	function configure() {
		resources( resource = "timeEntrys", parameterName = "id-numeric" );
		resources( resource = "preharvestTimeEntrys", parameterName = "id-numeric" );

		resources( resource = "changeLog", parameterName = "id-numeric" );

		resources( resource = "payrates", parameterName = "id-numeric" );

		resources( resource = "Auth", parameterName = "id-numeric" );
		
		resources( resource = "staff", parameterName = "userID-numeric" );

		route( "export/:handler/:action" ).end();
	}

}
