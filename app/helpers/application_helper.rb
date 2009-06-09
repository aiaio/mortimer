module ApplicationHelper

  # Returns an html 'disabled' attribute unless supplied user is an admin or the action is new or create.
  def disabled_unless_admin_access(group, user)
    unless group.allows_admin_access_for?(user) || ["new", "create"].include?(controller.action_name)
      return "disabled='disabled'" 
    end
  end

  # Returns an active class if the uri matches argument
  def active_if_match(*args)
    return "class='active'" if args.any? {|arg| request.request_uri =~ arg}
  end

end
