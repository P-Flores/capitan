class Users::SessionsController < Devise::SessionsController

def after_sign_in_path_for(resource)
  resource.applicant? ? selection_url : resource.employer? ? employer_dashboard_coders_url : show_track_url(1)
end

end
