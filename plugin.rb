# name: discourse-sso-extra-params
# version: 1.1
# author: richard@communiteq.com
# about: Pass extra parameters in the SSO process
# url: https://www.github.com/communiteq/discourse-sso-extra-params

enabled_site_setting :sso_extra_params_enabled

after_initialize do
  ApplicationController.class_eval do
    alias_method :old_redirect_to_login, :redirect_to_login
    
    def redirect_to_login
      if SiteSetting.sso_extra_params_enabled
        retain_keys = SiteSetting.sso_extra_params.split('|')
        session[:sso_retain] = params.to_unsafe_h.slice(*retain_keys)
      end
      old_redirect_to_login
    end
  end

  SessionController.class_eval do
    alias_method :old_sso_url, :sso_url
    
    def sso_url(sso)
      url = old_sso_url(sso)
      if SiteSetting.sso_extra_params_enabled
        params = session[:sso_retain] || {}
        params.each do |k,v|
          url = url + "&#{k}=#{v}"
        end
      end
      url
    end
  end


end
