# frozen_string_literal: true

shared_context 'action view' do
  subject { action_view.render(template: super()) }
  let(:action_view) { ActionView::Base.new(context, assigns) }
  let(:context) { ActionView::LookupContext.new(File.join(Dir.pwd, 'views')) }
end
