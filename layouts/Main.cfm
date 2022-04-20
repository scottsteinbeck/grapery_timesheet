<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<!--- Metatags --->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="ColdBox Application Template">
    <meta name="author" content="Ortus Solutions, Corp">

	<!---Base URL --->
	<base href="#event.getHTMLBaseURL()#" />

	<!---css --->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
	<style>
		.text-blue { color:##379BC1; }
	</style>

	<!--- Title --->
	<title>Grapery Timesheet Manager</title>

	<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.js"></script>

	<script src="https://unpkg.com/jquery@3.4.0/dist/jquery.js"></script>

    <link
      href="https://unpkg.com/jquery-ui-pack@1.12.2/jquery-ui.css"
      rel="stylesheet"
    />
    <link
      href="https://unpkg.com/jquery-ui-pack@1.12.2/jquery-ui.structure.css"
      rel="stylesheet"
    />
    <link
      href="https://unpkg.com/jquery-ui-pack@1.12.2/jquery-ui.theme.css"
      rel="stylesheet"
    />
    <script src="https://unpkg.com/jquery-ui-pack@1.12.2/jquery-ui.js"></script>

    <link
      href="https://unpkg.com/pqgridf@3.5.0/pqgrid.min.css"
      rel="stylesheet"
    />
    <link
      href="https://unpkg.com/pqgridf@3.5.0/pqgrid.ui.min.css"
      rel="stylesheet"
    />
    <link
      href="https://unpkg.com/pqgridf@3.5.0/themes/steelblue/pqgrid.css"
      rel="stylesheet"
    />

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/2.5.0/jszip.min.js"></script>

    <script src="https://unpkg.com/pqgridf@3.5.0/pqgrid.min.js"></script>
    <script src="https://unpkg.com/pqgridf@3.5.0/localize/pq-localize-en.js"></script>

    <script src="https://unpkg.com/file-saver@2.0.1/dist/FileSaver.min.js"></script>

    <style>
      .pq-grid {
        font-size: 12px;
      }
    </style>
	
</head>
<body
	data-spy="scroll"
	data-target=".navbar"
	data-offset="50"
	style="padding-top: 60px"
	class="d-flex flex-column h-100"
>
	<!---Top NavBar --->
	<header>
		<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
			<div class="container-fluid">
				<!---Brand --->
				<a class="navbar-brand" href="#event.buildLink( 'main' )#">
					<strong><i class="bi bi-bounding-box-circles"></i> Grapery Timesheet Editor</strong>
				</a>

				<!--- Mobile Toggler --->
				<button
					class="navbar-toggler"
					type="button"
					data-bs-toggle="collapse"
					data-bs-target="##navbarSupportedContent"
					aria-controls="navbarSupportedContent"
					aria-expanded="false"
					aria-label="Toggle navigation"
				>
					<span class="navbar-toggler-icon"></span>
				</button>

				<div class="collapse navbar-collapse" id="navbarSupportedContent">

				</div>
			</div>
		</nav>
	</header>

	<!---Container And Views --->
	<main class="flex-shrink-0">
		#renderView()#
	</main>

	<!--- Footer --->
	<footer class="w-100 bottom-0 position-fixed border-top py-3 mt-5 bg-light">
		<div class="container">
				<a href="https://www.ortussolutions.com">United Tracking System, LLC</a>
		</div>
	</footer>

	<!---js --->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
</body>
</html>
</cfoutput>
