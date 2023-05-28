class QuestionsController < ApplicationController
    def create
        document = Document.last
        question_text = params["question"]
        question = document.questions.find_by(question: question_text) || document.questions.create!(question: question_text)
        
        if question
            answer = question.get_answer
            render json: { answer: answer }
        else
            render json: { error: question&.errors&.full_messages }, status: :unprocessable_entity
        end
    end
end