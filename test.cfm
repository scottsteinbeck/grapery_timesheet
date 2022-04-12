<cfscript>
	token = 'gb_api_PGhZFqILGD31OSwQ7ICSuLVKSNlFqDARybZ3SusM';
	bookUrl = 'https://app.gitbook.com/o/-LA-UVKtPMvMR4t5JRTB/c/-LA-UVvm2myYkRfmcpa7';
	//bookUrl = 'https://app.gitbook.com/o/-LA-UVKtPMvMR4t5JRTB/s/-M0SpUhngiuHB_ph56ko/';

	function downloadBook(required mainURL, required folderPath){
		mainURL = replace(mainURL,'https://app.gitbook.com/','');
		var parts = ListToArray(mainURL,'/');
		var urlID = parts[4];
		var revisions = {'versions': {}};

		organization = parts[2];
		if(parts[3] == 'c'){
			var collectionQry = apiQuery("https://api.gitbook.com/v1/collections/#urlID#");
			var bookIdx = {
				'name': collectionQry.title,
				'logoURL': ""
			};
			var spaceQry = apiQuery("https://api.gitbook.com/v1/spaces/#collectionQry.primarySpace#");
			revisions.versions[spaceQry.path] = {
				'title': spaceQry.title,
				'path': spaceQry.path
			}
		} else {
			var spaceQry = apiQuery("https://api.gitbook.com/v1/spaces/#urlID#");
			var bookIdx = {
				'name': spaceQry.title,
				'logoURL': ""
			};
			revisions.versions[spaceQry.path] = {
				'title': spaceQry.title,
				'path': spaceQry.path
			}
		}
		folderPath &= '/' & urlID;
		getSpace(spaceQry.id, folderPath & "/versions/" & spaceQry.path)
		FileWrite("#folderPath#/revision.json",serializeJSON(revisions));
		FileWrite("#folderPath#/spaces.json",serializeJSON(bookIdx));
	}

	function getSpace(required spaceID, required folderPath, boolean isRoot = false){
		var qry = apiQuery("https://api.gitbook.com/v1/spaces/#spaceID#/content");
		if(!directoryExists(folderPath)) DirectoryCreate(folderPath);
		FileWrite("#folderPath#/toc.json",serializeJSON(qry));
		if(qry.keyExists('pages') && qry.pages.len()){
			qry.pages.each(function(pageMeta){
				getPage(spaceID, pageMeta.path, folderPath)
			});
		}
	}
	function getPage(required spaceID, required pagePath, required folderPath){
		var uri="https://api.gitbook.com/v1/spaces/#spaceID#/content/url/#pagePath#";
		var qry = apiQuery(uri);
		var filepath = "#folderPath#/#qry.path#.json";
		var dirPath = getDirectoryFromPath(filepath);
		if(!directoryExists(dirPath)) DirectoryCreate(dirPath);
		FileWrite(filepath,serializeJSON(qry));

		if(qry.keyExists('pages') && qry.pages.len()){
			qry.pages.each(function(pageMeta){
				if(pageMeta.kind == 'sheet'){
					getPage(spaceID, pagePath & '/' & pageMeta.path, folderPath)
				}
			});
		}
		return;
	}
	function apiQuery(uri="https://api.gitbook.com/v1/user/spaces"){

		var httpService = new modules.bolthttp.bolthttp();
		response = httpService.request(
			url = uri,
			method = "GET",
			params = [
				{type="header", name="Authorization", value="Bearer #token#"}
				]
			);
			return DeserializeJSON(response.filecontent);
	}
	downloadBook(bookUrl,expandPath('./export'));
	//getSpace(spaceID,expandPath('./export'));
</cfscript>