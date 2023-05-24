class Question < ApplicationRecord
    validates :question, presence: true
    
    scope :with_answer, -> { where.not(answer: nil) }
    
    belongs_to :document

    def self.random
        with_answer.most_asked.sample
    end

    def already_asked?
    end
end
