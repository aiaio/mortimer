module GroupsHelper

  def has_sub_groups?(group_set)
    group_set.is_a?(Array) && group_set.size > 1
  end

  def get_group_from_set(group_set)
    group_set.is_a?(Array) ? group_set.first : group_set
  end  

  def hide_if_group_closed(group)
    "style='display:none;'" unless group_open?(group)
  end

  def group_open?(group)
    return nil unless session[:open_groups]
    session[:open_groups][group.id]
  end

end

