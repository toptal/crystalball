# frozen_string_literal: true

shared_context 'base strategy' do
  it { is_expected.to respond_to :after_register, :after_start, :before_finalize, :call }
end
