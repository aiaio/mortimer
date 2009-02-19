module GroupsHelper

  def has_sub_groups?(group_set)
    group_set.is_a?(Array) && group_set.size > 1
  end

  def get_group_from_set(group_set)
    group_set.is_a?(Array) ? group_set.first : group_set
  end  

end

