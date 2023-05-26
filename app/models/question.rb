class Question < ApplicationRecord
    MAX_CHAT_TOKENS = 500
    SEPERATOR_LEN = 3

    validates :question, presence: true
    
    scope :with_answer, -> { where.not(answer: nil) }
    
    belongs_to :document

    after_create :get_answer

    after_find :initialize_open_ai_service

    def self.random
        with_answer.most_asked.sample
    end

    # TODO: Change field question -> question_text
    def get_answer
        update_context_with_relevant_sections if context.nil?
        answer = @open_ai_service.generate_answer(self)
        update!(answer: answer)
    end

    private

    def initialize_open_ai_service
        @open_ai_service = OpenaiService.new
    end

    def update_context_with_relevant_sections
        # Should we max out memory by holding the doc embedding in memory?
        # Or should we just be slow?
        # Let's be slow for now. 
        question_embedding = @open_ai_service.generate_embeddings([question])

        pages_most_similar_to_question = EmbeddingHelper::Embedding.get_pages_most_similar_to_question(self, question_embedding)

    # TODO: Optimize this to use sorted values in the CSV.

        text_from_relevant_pages = DocumentHelper::Document.get_text_from_relevant_pages(pages_most_similar_to_question, self)

        # Check if the most_relevant_sections_text is of class text
        raise "text_from_relevant_pages is not of class text" unless  text_from_relevant_pages.is_a?(String)
        
        update!(context: text_from_relevant_pages)
    end    
end
