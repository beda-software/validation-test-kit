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
               ig_version: '0.4.1-preview'
             }
           }
    end
  end
end
