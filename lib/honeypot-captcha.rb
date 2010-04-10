require 'honeypot-captcha/form_tag_helper'

module HoneypotCaptcha
  module SpamProtection
    def honeypot_fields
      [:a_comment_body]
    end

    def protect_from_spam
      head :ok if honeypot_fields.any? { |f| !params[f].blank? }
    end

    def self.included(base) # :nodoc:
      base.send :helper_method, :honeypot_fields

      if base.respond_to? :before_filter
        base.send :prepend_before_filter, :protect_from_spam, :only => [:create, :update]
      end
    end
  end
end

ActionController::Base.send(:include, HoneypotCaptcha::SpamProtection) if defined?(ActionController::Base)
