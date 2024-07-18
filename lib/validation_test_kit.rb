# frozen_string_literal: true

require_relative './validation_test_kit/validation_test'

module ValidationTestKit
  class ValidationTestSuite < Inferno::TestSuite
    id :validations
    title 'Validation Test Suite'
    description 'Validation Test Suite'

    group do
      title 'Validation of any FHIR resource'
      test from: :validation_test,
           config: {
             options: {
               validator_url: 'https://validator.fhir.org',
               ig: 'hl7.fhir.au.core',
               ig_version: '0.4.0-preview',
               tx_server_url: 'https://tx.dev.hl7.org.au/fhir'
             }
           }
    end
  end
end
