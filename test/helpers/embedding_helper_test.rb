require 'minitest/autorun'
require 'csv'
require 'test_helper'
require 'byebug'

class EmbeddingHelperTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers

    test "test get pages most similar to question" do
        @document = Document.create(
            name: 'test',
            original_file_path: 'aeroplan-visa-infinite-privilege-insurance-en.pdf'
        )

        # @document.questions.create(
        #     question: "say if i bought my phone for 1400 dollars, and lost it 180 days after i bought it, what would the policy cover?",
        # )
    end
end
    