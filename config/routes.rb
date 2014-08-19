HelloWorld::Application.routes.draw do

  resources :other_subjects


  resources :scoring_scales do
    collection do
      post 'delete_selected'
    end
  end


  resources :minimum_requirements do
    collection do
      post 'delete_selected'
    end
  end

  match "replace_title_table" => "titles#datatable_titles"
  match "replace_scoring_scale_table" => "scoring_scales#datatable_scoring_scales"
  match "replace_minimum_requirement_table" => "minimum_requirements#datatable_minimum_requirements"
  match "get_all_competencies" => "competencies#get_all_competencies"
  match "get_competencies_in_cds" => "competencies#get_competencies_in_cds"
  match "select_manager" => "departments#select_manager"

  resources :slots do
    collection do
      get 'get_slots_belong_to_level'
    end
  end


  resources :levels do
    collection do
      get 'check_level_contain_slots'
    end
  end


  resources :competencies do
    collection do
      get 'show_list_levels'
      get 'add_remove_competency_to_cds'
    end
  end


  resources :cds_structures


  resources :titles do
    collection do
      post 'delete_selected'
    end
  end

  devise_for :users, :path => "auth", :controllers =>{ passwords: "passwords", registrations: 'registrations', sessions: 'sessions'} do
    match "/thank_you_sign_up" => "registrations#thank_you_sign_up"
  end
  
  #unless Rails.application.config.consider_all_requests_local
  #match '*not_found', to: 'errors#error_404'
  #end
  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :organizations do
    resources :users do
      post 'import_users', on: :collection
      post 'upload_avatar', on: :member
      post 'upload_photo', on: :member
      get 'new_list_users', on: :collection
      #match "reset_password" => "users#reset_password", via: "post"
      get 'reset_password'
      get 'resend_email'
      post 'actions', on: :member
      get 'user_relationship', on: :collection
      post 'actions_relationship', on: :collection
      post 'change_status', on: :member
      get 'user_pa', on: :member
      get 'timeline', on: :member
      get 'home', on: :member
      get 'team_member', on: :member
      get 'recently_not_added_slot', on: :member
      get 'recently_added', on: :member
      get 'about', on: :member
      get 'current_status', on: :member
      get 'all_slot', on: :member
      get 'all_other_subject', on: :member
      get 'short_term_objective', on: :member
      get 'slot_detail', on: :member
      get 'other_subject_detail', on: :member
      get 'recently_added_slider', on: :member
      get 'comments', on: :member
      post 'remove_evidence', on: :member
      post 'action_instances_tem', on: :member

      get 'notification_cmt', on: :member
      get 'notification_approve', on: :member
      get 'notification_reject', on: :member

      get 'view_statistic', on: :member
    end

    resources :user_groups do
      get "get_available_user"
      get "add_user_to_group"
      get "update_permissions"
      get "get_all_permission", on: :collection
      post "change_status", on: :member
    end

    resources :activities

    resources :projects

    resources :departments do 
      get "get_all_members", :on => :member
      get "get_user_to_teamlead", :on => :member
      get "get_all_user_not_in_department", :on => :member
      post "add_user_to_department", :on => :member
      post "remove_user_from_department", :on => :member
    end

    resources :cds_templates do
      post 'delete_selected', :on => :collection
    end

    resources :terms

    resources :performance_appraisals
    
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end