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
							<img src="/resources/img/header/<cfoutput>#prc.site.logo#</cfoutput>" class="img-fluid" width="300" />
						</div>
						<cfoutput>
							<div class="text-center mt-4">
								<h1 class="h2">Enter New Password</h1>
								<p class="lead">Hello #auth().user().getFirstName()# #auth().user().getLastName()#,<br>Please enter a new password to continue</p>
							</div>
							<form method="POST"  autocomplete="off"  id="validation-form" action="/auth/updatePassword" class="needs-validation" novalidate>
								<div class="form-group">
									<label for="inputPasswordNew"
										>New password</label
									>
									<input
										type="password"
										class="form-control"
										name="password"
										placeholder="Password"
										autocomplete="new-password"
										required
									/>
								</div>
								<div class="form-group">
									<label for="inputPasswordNew2"
										>Verify password</label
									>
									<input
										type="password"
										class="form-control"
										name="passwordconfirmation"
										placeholder="Confirm password"
										autocomplete="new-password"
										required
									/>
								</div>

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
									<a href="/Auth/index" class="btn btn-lg btn-github">Cancel</a>
									<button  id="submitBtn" type="submit" class="btn btn-lg btn-primary">Update password & Sign in</button>
								</div>
							</form>
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
				"password": {
					required: true,
					minlength: 4,
					maxlength: 20,
				},
				"passwordconfirmation": {
					required: true,
					minlength: 4,
					equalTo: 'input[name="password"]',
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
