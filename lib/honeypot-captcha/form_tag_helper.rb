# Override the form_tag helper to add honeypot spam protection to forms.
module ActionView
  module Helpers
    module FormTagHelper
      def form_tag_html_with_honeypot(options)
        honeypot = options.delete(:honeypot) || options.delete('honeypot')
        html = form_tag_html_without_honeypot(options)
        if honeypot
          captcha = "".respond_to?(:html_safe) ? honey_pot_captcha.html_safe : honey_pot_captcha
          if block_given?
            html.insert(html.index('</form>'), captcha)
          else
            html += captcha
          end
        end
        html
      end
      alias_method :form_tag_html_without_honeypot, :form_tag_html
      alias_method :form_tag_html, :form_tag_html_with_honeypot

      private

      def honey_pot_captcha
        html_ids = []
        honeypot_fields.collect do |f, l|
          html_ids << (html_id = "#{f}_#{honeypot_string}_#{Time.now.to_i}")
          content_tag :div, :id => html_id do
            content_tag(:style, :type => 'text/css', :media => 'screen', :scoped => "scoped") do
              "#{html_ids.map { |i| "##{i}" }.join(', ')} { display:none; }"
            end +
            label_tag(f, l) +
            send([:text_field_tag, :text_area_tag][rand(2)], f)
          end
        end.join
      end
    end
  end
end
