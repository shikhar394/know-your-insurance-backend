require "openai"
require 'dotenv/load'

class OpenaiService
    EMBEDDINGS_MODEL = 'text-embedding-ada-002'
    MAX_INPUT_LEN = 8191
    MAX_OUTPUT_LEN = 1536
    OUTPUT_LEN = 256
    TEXT_DAVINCI_MODEL = 'text-davinci-003'
    GPT_3_5_TURBO = 'gpt-3.5-turbo'

    def initialize
        @client = OpenAI::Client.new
    end

    def generate_embeddings(chunk)
        embeddings_object = @client.embeddings(
            parameters: {
                model: EMBEDDINGS_MODEL,
                input: chunk
            }
        )
        embedding_list = embeddings_object.dig('data', 0, 'embedding')
    end

    def generate_answer(question, model = TEXT_DAVINCI_MODEL)
        header = """You are an insurance expert and can answer any question from any insurance.
            Given some context text and a question please find answers.
            Please keep your answers to three sentences maximum, and speak in complete sentences.
            Stop speaking once your point is made.\n\nContext that may be useful\n
            """

        prompt = header + "\n\n\n" + question.context + "\n\n\n"
        question_text = "Q:" + question.question + "\n\nA: "

        answer = nil 

        if model == GPT_3_5_TURBO
            answer = @client.chat(
                parameters: {
                    model: model, 
                    messages: [
                        { role: "system", content: prompt}, 
                        { role: "user", content: question_text }
                    ],
                    temperature: 0.1,
                    max_tokens: OUTPUT_LEN
                }    
            )
            
            answer = answer.dig("choices", 0, "message", "content")
        elsif model == TEXT_DAVINCI_MODEL
            answer = @client.completions(
                parameters: {
                    model: model, 
                    prompt: prompt + question_text,
                    temperature: 0.1,
                    max_tokens: OUTPUT_LEN
                }    
            )
            answer = answer.dig("choices", 0, "text")
        end

        raise "Could not get answer" if answer.nil?
        answer
        # TODO: Handle when answer doesn't give good enough answer.
    end
end
