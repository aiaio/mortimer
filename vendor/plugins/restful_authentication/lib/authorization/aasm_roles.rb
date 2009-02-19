module Authorization
  module AasmRoles
    unless Object.constants.include? "STATEFUL_ROLES_CONSTANTS_DEFINED"
      STATEFUL_ROLES_CONSTANTS_DEFINED = true # sorry for the C idiom
    end
    
    def self.included( recipient )
      recipient.extend( StatefulRolesClassMethods )
      recipient.class_eval do
        include StatefulRolesInstanceMethods
        include AASM
        aasm_column :state
        aasm_initial_state :active
        aasm_state :active
        aasm_state :suspended
        aasm_state :deleted, :enter => :do_delete
                
        aasm_event :suspend do
          transitions :from => [:pending, :active], :to => :suspended
        end
        
        aasm_event :delete do
          transitions :from => [:active, :suspended], :to => :deleted
        end

        aasm_event :unsuspend do
          transitions :from => :suspended, :to => :active
        end
      end
    end

    module StatefulRolesClassMethods
    end # class methods

    module StatefulRolesInstanceMethods
      
      def do_delete
        self.deleted_at = Time.now.utc
      end
      
    end # instance methods
  end
end
