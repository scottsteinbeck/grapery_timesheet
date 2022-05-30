<cfoutput>
	<div class="container-fluid" id="innercontainer">
		<div class="header">
			<h1 class="header-title">#event.getPrivateValue('title','Staff List')#</h1>
			<h3 class="header-subtitle">#event.getPrivateValue('desc','List of Admin Users')#</h3>
		</div>
		<div class="row">
			<div class="col-12">
				<div class="card">
					<div class="card-header">
						<h5 class="card-title mb-0">Staff/Admin List</h5>
					</div>
					<div class="card-body">
						<b-row>
							<b-col>
								<b-form-group>
									<b-input-group>
										<b-form-input v-model="filter" type="search" id="filterInput" placeholder="Type to Search"></b-form-input>
										<b-input-group-append>
											<b-button :disabled="!filter" @click="filter = ''">Clear</b-button>
										</b-input-group-append>
									</b-input-group>
								</b-form-group>
							</b-col>
							<b-col>
								<b-button @click="editUser({})" variant="primary"> <i class="fas fa-user-plus"></i> Add User</b-button>
							</b-col>
							<b-col cols="6">
								<b-pagination
									align="right"
									size="md"
									:total-rows="totalRows"
									v-model="currentPage"
									:per-page="perPage"
								></b-pagination>
							</b-col>
						</b-row>

						<b-table
							:items="myProvider"
							:filter="filter"
							:busy="isBusy"
							responsive="sm"
							:fields="fields"
							:current-page="currentPage"
							:per-page="perPage"
							ref="table"
							striped
							small
						>
							<template v-slot:cell(actions)="data">
								<button size="sm" class="btn btn-primary" @click="editUser(data.item)">
									<i class="fas fa-user-edit"></i>
								</button>
								<!-- <button size="sm" class="btn btn-danger" @click="deleteConfirm(data.item)">
									<i class="fas fa-trash-alt"></i>
								</button> -->
							</template>
							<template v-slot:cell(name)="data">
								<b-badge v-if="data.item.can_login == 1 " variant="success"><i class="fas fa-user-check"></i></b-badge>
								<b-badge v-if="data.item.can_login == 0 " variant="danger"><i class="fas fa-user-times"></i></b-badge>
								{{ data.item.first_name }}
								{{ data.item.last_name }}
							</template>
							<template v-slot:cell(role)="data">
								{{ data.item.name }}
							</template>
						</b-table>
					</div>
				</div>
			</div>
		</div>
		<!-- Edit Form -->
		<b-modal id="editUserDialog" ref="modal" title="Add/Update User Information" @hidden="resetModal" @ok="handleOk">
			<form ref="form" @submit.stop.prevent="handleSubmit">
				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Type" label-for="first-name-input" invalid-feedback="First Name is required">
					<b-form-select v-model="$v.form.role.$model" :state="validateState('role')" :options="roles"></b-form-select>
				</b-form-group>

				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Username" label-for="username-input" invalid-feedback="Username is required">
					<b-form-input id="name-input" v-model="$v.form.username.$model" :state="validateState('username')"></b-form-input>
				</b-form-group>

				<b-form-group
					label-cols-sm="4"
					label-cols-lg="3"
					label="First Name"
					label-for="first-name-input"
					invalid-feedback="First Name is required"
				>
					<b-form-input id="first-name-input" v-model="$v.form.first_name.$model" :state="validateState('first_name')"></b-form-input>
				</b-form-group>
				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Last Name" label-for="name-input" invalid-feedback="Last Name is required">
					<b-form-input id="name-input" v-model="$v.form.last_name.$model" :state="validateState('last_name')"></b-form-input>
				</b-form-group>
				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Email" label-for="email-input" invalid-feedback="Email is required">
					<b-form-input id="email-input" v-model="$v.form.email.$model" :state="validateState('email')"></b-form-input>
				</b-form-group>

				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Can Login" label-for="can-login-input">
					<b-form-checkbox value="1" unchecked-value="0" v-model="$v.form.can_login.$model" id="can-login-input" switch>
						{{ $v.form.can_login.$model == 1 ? 'YES' : 'NO' }}
					</b-form-checkbox>
				</b-form-group>

				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Password" label-for="password-input">
					<b-form-input id="password-input" v-model="$v.form.password.$model" :state="validateState('password')"></b-form-input>
				</b-form-group>
				<b-form-group label-cols-sm="4" label-cols-lg="3" label="Confirm Password" label-for="confirm-password-input">
					<b-form-input
						id="confirm-password-input"
						v-model="$v.form.passwordConfirm.$model"
						:state="validateState('passwordConfirm')"
					></b-form-input>
				</b-form-group>
			</form>
		</b-modal>
	</div>
</cfoutput>

<script>
	Vue.use(BootstrapVue)
	Vue.use(window.vuelidate.default)
	var vvd = window.validators
	var app = new Vue({
		el: '#innercontainer',
		data: function () {
			return {
				filter: null,
				perPage: 50,
				isBusy: false,
				currentPage: 1,
				totalRows: 0,
				fields: ['actions', 'name', 'role', 'username', 'email'],
				roles: [
					{ value: '3', text: 'Coalition' },
					{ value: '4', text: 'Admin' },
				],
				form: {},
			}
		},
		validations: {
			form: {
				username: {
					required: vvd.required,
					minLength: vvd.minLength(4),
				},
				first_name: { required: vvd.required },
				last_name: { required: vvd.required },
				email: { required: vvd.required },
				password: {
					minLength: vvd.minLength(6),
				},
				passwordConfirm: { sameAsPassword: vvd.sameAs('password') },
				role: {},
				can_login: {},
			},
		},
		methods: {
			myProvider: function (ctx, callback) {
				var _self = this
				$.ajax({
					url: '/api/v1/staff/index.json',
					data: ctx,
				}).done(function (data) {
					_self.currentPage = data.pagination.page
					_self.totalRows = data.pagination.totalRecords
					callback(data.results)
				})
			},
			validateState: function (name) {
				const { $dirty, $error } = this.$v.form[name]
				return $dirty ? !$error : null
			},
			deleteConfirm: function (userInfo) {
				console.log(userInfo)
				this.$bvModal
					.msgBoxConfirm(
						'Please confirm that you want to delete the user account for ' + userInfo.first_name + ' ' + userInfo.last_name + '.',
						{
							title: 'Please Confirm',
							size: 'sm',
							buttonSize: 'md',
							okVariant: 'danger',
							okTitle: 'YES',
							cancelVariant: 'light',
							cancelTitle: 'NO',
							footerClass: 'p-2',
							hideHeaderClose: false,
							centered: true,
						}
					)
					.then((value) => {
						if (value) console.log('Delete User')
					})
					.catch((err) => {
						// An error occurred
					})
			},
			populateModel: function (data) {
				this.form = {
					oid: null,
					username: null,
					password: null,
					passwordConfirm: null,
					email: null,
					phone: null,
					first_name: null,
					last_name: null,
					can_login: 1,
					role: 4,
				}
				for (var i in this.form) {
					if (data.hasOwnProperty(i)) {
						this.form[i] = data[i]
					}
				}
			},
			editUser: function (userInfo) {
				console.log(userInfo)
				this.populateModel(userInfo)
				this.$bvModal.show('editUserDialog')
			},
			resetModal: function () {
				this.populateModel({})
			},
			handleOk: function (bvModalEvt) {
				// Prevent modal from closing
				bvModalEvt.preventDefault()
				// Trigger submit handler
				this.handleSubmit()
			},
			handleSubmit: function () {
				// Exit when the form isn't valid
				var _self = this
				this.$v.form.$touch()
				if (this.$v.form.$anyError) {
					return
				}
				var postURL = '/api/v1/staff/create'
				var method = 'POST'
				if (this.form.oid > 0) {
					var postURL = '/api/v1/staff/' + this.form.oid
					var method = 'PUT'
				}

				$.ajax({
					url: postURL + '.json',
					method: method,
					data: this.form,
				})
					.fail(function (jqXHR, textStatus, errorThrown) {
						if (jqXHR.responseJSON.hasOwnProperty('data')) {
							_self.$bvToast.toast(jqXHR.responseJSON.data, {
								title: `Error Saving User`,
								toaster: 'b-toaster-top-center',
								variant: 'danger',
								solid: true,
								appendToast: false,
							})
						}
					})
					.done(function (data) {
						// Hide the modal manually
						_self.$refs.table.refresh()
						_self.$nextTick(() => {
							_self.$bvModal.hide('editUserDialog')
						})
					})
			},
		},
	})
</script>
