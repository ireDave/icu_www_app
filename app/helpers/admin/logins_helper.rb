module Admin::LoginsHelper
  def result_search_menu(selected)
    options_for_select(["Success", "Failure", "Bad email", "Bad password", "Expired", "Disabled", "Unverified", "Any"], selected)
  end
end
