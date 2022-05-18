component extends="BaseHandler"{
    // HTTP Method Security
	this.allowedMethods = {
		index : "GET",
		create: "POST,PUT",
		update: "POST,PUT,PATCH",
		delete: "DELETE"
	};

	function index( event, rc, prc ) {
	}

	function create( event, rc, prc ) {
    }

	function update( event, rc, prc ) {
        dump(rc); abort;
    }

	function delete( event, rc, prc ) {
    }
}