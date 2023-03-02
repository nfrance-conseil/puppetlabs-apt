# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'apt::backports' do
  context 'update_had_no_effect script' do
    let(:pp) do
      <<-MANIFEST
        exec { 'Test the script':
          command   => epp('apt/update_had_no_effect.sh.epp'),
          logoutput => true,
          returns   => [-1],
        }
      MANIFEST
    end

    it 'produces output' do
      idempotent_apply(pp)
    end
  end
  context 'when using defaults' do
    let(:pp) do
      <<-MANIFEST
        include apt::backports
      MANIFEST
    end

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    it 'provides backports apt sources' do
      run_shell('apt policy | grep --quiet backports')
    end
  end
end
