<style>
	.alert-icon {
    padding: 1.2rem;
    background: hsla(0,0%,100%,.1);
}
</style>
<div class="row h-100">
	<div class="col-sm-10 col-md-8 col-lg-6 mx-auto d-table h-100">
		<div class="d-table-cell align-middle">
			<div class="card">
				<div class="card-body">
					<div class="m-sm-4">
						<div class="text-center">

						</div>
						 <cfoutput>
							<div class="text-center mt-4">
								<h1 class="h2">Forgot Password</h1>
								<p class="lead">Please enter your Member ID <br/> to request a password reset for your account</p>
							</div>
							<form method="POST"  autocomplete="off"  id="validation-form" action="/auth/sendPasswordReset" class="needs-validation" novalidate>
								<div class="form-group">
									<label for="inputPasswordNew"
										>User ID</label
									>
									<input
										type="text"
										class="form-control"
										name="username"
										placeholder="User ID"
										required
									/>
								</div>

								<cfif flash.exists("login_form_success")>
									<div class=" m-3 alert alert-success alert-outline-coloured alert-dismissible" role="alert">
										<div class="alert-icon">
											<i class="fas fa-fw fa-check"></i>
										</div>
										<div class="alert-message">
											#flash.get('login_form_success').resetPassword#
										</div>
										<button type="button" class="close" data-dismiss="alert" aria-label="Close">
											<span aria-hidden="true">×</span>
										</button>
									</div>
								</cfif>

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
								<div class="text-center mt-4">
									<a href="/Auth/index" class="btn btn-lg btn-github">Go Back</a>
									<button  id="submitBtn" type="submit" class="btn btn-lg btn-primary">Request Password Reset</button>
								</div>
							</form>
							<!--- <h3 class="text-center m-3">To request a new password please send an email to
								<a href="mailto:nbell@krwca.org?subject=Password Reset&body=I would like to request a password reset for Member ID: ">nbell@krwca.org</a>
								and include your Member ID.</h3>
								<div class="text-center">
									<a class="btn btn-lg btn-primary text-center" href="mailto:nbell@krwca.org?subject=Password Reset&body=I would like to request a password reset for Member ID: ">Create Email</a>

								</div> --->
						</cfoutput>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
	$(function () {

		// Initialize validation
		$("#validation-form").validate({
			ignore: ".ignore, .select2-input",
			focusInvalid: false,
			rules: {
				"username": {
					required: true
				}
			},
			// Errors
			errorPlacement: function errorPlacement(error, element) {
				var $parent = $(element).parents(".form-group");
				// Do not duplicate errors
				if ($parent.find(".jquery-validation-error").length) {
					return;
				}
				$parent.append(
					error.addClass(
					"jquery-validation-error small form-text invalid-feedback"
					)
				);
			},
			highlight: function (element) {
				var $el = $(element);
				var $parent = $el.parents(".form-group");
				$el.addClass("is-invalid");
				// Select2 and Tagsinput
				if (
					$el.hasClass("select2-hidden-accessible") ||
					$el.attr("data-role") === "tagsinput"
				) {
					$el.parent().addClass("is-invalid");
				}
			},
			unhighlight: function (element) {
				$(element)
					.parents(".form-group")
					.find(".is-invalid")
					.removeClass("is-invalid");
			}
		});
	});
</script>
