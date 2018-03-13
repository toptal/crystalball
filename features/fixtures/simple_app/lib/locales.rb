# frozen_string_literal: true

I18n.load_path += Dir[File.expand_path(File.join('locales', '*.yml'))]
I18n.default_locale = :en
