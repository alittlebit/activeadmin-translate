module ActiveAdmin
  module Translate

    # Form builder to build input fields that are arranged by locale in tabs.
    #
    module FormBuilder

      # Create the local field sets to enter the inputs per locale
      #
      # @param [Symbol] name the name of the translation association
      # @param [Proc] block the block for the additional inputs
      #
      def translate_inputs(name = :translations, &block)
        form_buffers.last << template.content_tag(:div, :class => "activeadmin-translate #{ translate_id }") do
          locale_tabs << locale_fields(name, block)
        end
      end

      protected

      # Create the local field sets to enter the inputs per locale.
      #
      # @param [Symbol] name the name of the translation association
      # @param [Proc] block the block for the additional inputs
      #
      def locale_fields(name, block)
        ::I18n.available_locales.map do |locale|
          translation = object.method(name).call.find_or_initialize_by_locale(locale)
          translation.instance_variable_set(:@errors, object.errors) if locale == I18n.default_locale

          fields = proc do |form|
            form.input(:locale, :as => :hidden)
            block.call(form)
          end

          inputs_for_nested_attributes(:for => [name, translation], :id => field_id(locale), :class => "inputs locale locale-#{ locale }", &fields)
        end.join.html_safe
      end


      # Create the locale tab to switch the translations.
      #
      # @return [String] the HTML for the locale tabs
      #
      def locale_tabs
        template.content_tag(:ul, :class => 'locales') do
          ::I18n.available_locales.map do |locale|
            template.content_tag(:li) do
              template.content_tag(:a, ::I18n.t("active_admin.translate.#{ locale }"), :href => "##{ field_id(locale) }")
            end
          end.join.html_safe
        end
      end

      # Get the unique id for the translation field
      #
      def field_id(locale)
        "locale-#{ locale }-#{ translate_id }"
      end

      # Get the unique id for the translation
      #
      # @return [String] the id
      #
      def translate_id
        "#{ self.object.class.to_s.underscore.dasherize }-#{ self.object.object_id }"
      end

    end
  end
end