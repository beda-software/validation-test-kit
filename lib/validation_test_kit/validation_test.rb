# frozen_string_literal: true

module ValidationTestKit
  class ValidationTest < Inferno::Test
    id :validation_test
    title 'Custom validation of the resource'
    optional

    description %(
      This test automatically identifies and validates any provided FHIR resource.
      Users are required to input the FHIR resource in JSON format, referred to as 'resource_json'.
      The test extracts the applicable profile for validation from the first element in the 'meta.profile' array, located at the path: resource.meta.profile.0.
      This profile serves as the benchmark for the validation process.

      Given the optional nature of this test, its results do not influence the final outcome of the test report.
    )

    class << self
      def ig
        @ig ||= config.options[:ig]
      end

      def ig_version
        @ig_version ||= config.options[:ig_version]
      end

      def validator_url
        @validator_url ||= config.options[:validator_url]
      end

      def tx_server_url
        @tx_server_url ||= config.options[:tx_server_url]
      end
    end

    input :resource_json,
          title: 'FHIR resource in JSON format (custom validation)',
          optional: true,
          type: 'textarea'

    def resource_type
      ''
    end

    def perform_validation_test(resources,
                                profile_url,
                                profile_version,
                                skip_if_empty: true)

      skip_if skip_if_empty && resources.blank?,
              "No #{resource_type} resources conforming to the #{profile_url} profile were returned"

      omit_if resources.blank?,
              "No #{resource_type} resources provided so the #{profile_url} profile does not apply"

      profile_with_version = "#{profile_url}|#{profile_version}"
      resources.each do |resource|
        resource_is_valid?(resource:, profile_url: profile_with_version)
      end

      errors_found = messages.any? { |message| message[:type] == 'error' }

      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    fhir_resource_validator do
      igs "hl7.fhir.au.core#0.4.0-preview"
      url 'https://validator.fhir.org'

      cli_context do
        txServer 'https://tx.dev.hl7.org.au/fhir'
        disableDefaultResourceFetcher false
      end
    end

    run do
      skip_if resource_json.blank?

      fhir_resource_hash = JSON.parse(resource_json)
      resource_type = fhir_resource_hash['resourceType']
      fhir_resource_profile = fhir_resource_hash['meta']['profile'].first
      fhir_class = FHIR.const_get(resource_type)
      fhir_resource = fhir_class.new(fhir_resource_hash)

      info "Resource type to validate is #{resource_type}"
      info "Resource profile to validate is #{fhir_resource_profile}"
      info "IG version to validate is #{self.class.ig_version}"

      perform_validation_test([fhir_resource],
                              fhir_resource_profile,
                              self.class.ig_version,
                              skip_if_empty: true)
    end
  end
end
