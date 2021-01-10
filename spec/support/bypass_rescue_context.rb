RSpec.shared_context 'bypass_rescue?がfalseでない限り、デフォルトでbypass_rescueする' do
  before { bypass_rescue if bypass_rescue? }
  let(:bypass_rescue?) { true }
end
