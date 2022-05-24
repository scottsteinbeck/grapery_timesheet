<style>
	.alert-icon {
    padding: 1.2rem;
    background: hsla(0,0%,100%,.1);
}
</style>
<div class="row h-100">
	<div class="col-sm-10 col-md-8 col-lg-6 mx-auto d-table h-100">
		<div class="d-table-cell align-middle">
			<div class="text-center mt-4">
				<h1 class="h2">Welcome</h1>
				<p class="lead">Sign in to your account to continue</p>
			</div>
			<div class="card">
				<div class="card-body">
					<div class="m-sm-4">
						<div class="text-center">
							<!--- <img src="/resources/img/header/<cfoutput>#prc.site.logo#</cfoutput>" class="img-fluid" width="300" /> --->
						</div>
						<cfoutput>
							<form action = "/auth/login", method="POST" >
								<div class="form-group">
									<label>User ID </label>
									<input class="form-control form-control-lg" value="" type="text" name="username" placeholder="Enter your User ID" />
								</div>
								<div class="form-group">
									<label>Password</label>
									<input class="form-control form-control-lg" value="" type="password" name="password" placeholder="Enter your password" />
									<div class="row justify-content-end">
										<a class="align-right btn" href="/Auth/forgotPassword">Forgot password?</a>
									</div>
								</div>

								<!--- <h2 class="text-danger text-center">Member Login will be available Tommorow Oct 15, 2020</h2>
								<h5 class="text-center">Thank you for your patience </h5> --->

								<cfif flash.exists("login_form_errors")>
									<div class=" m-3 alert alert-warning alert-outline-coloured alert-dismissible" role="alert">
										<div class="alert-icon">
											<i class="far fa-fw fa-bell"></i>
										</div>
										<div class="alert-message">
											#flash.get('login_form_errors').login#
										</div>
										<button type="button" class="close" data-dismiss="alert" aria-label="Close">
											<span aria-hidden="true">×</span>
										</button>
									</div>
								</cfif>
								<div class="text-center mt-3">
									<button type="submit" class="btn btn-lg btn-primary">Sign in</button>
								</div>
							</form>
						</cfoutput>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
