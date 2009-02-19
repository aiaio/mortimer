module Sentry
  class AsymmetricSentryCallback
    def initialize(attr_name)
      @attr_name = attr_name
    end
  
    # Performs encryption on before_validation Active Record callback
    def before_validation(model)
      return if model.send(@attr_name).blank?
      model.send("crypted_#{@attr_name}=", AsymmetricSentry.encrypt_to_base64(model.send(@attr_name)))
    end
    
    def after_save(model)
      model.send("#{@attr_name}=", nil)
    end
  end
end