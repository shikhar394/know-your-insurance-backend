require "openai"
require 'dotenv/load'

class OpenaiService
    EMBEDDINGS_MODEL = 'text-embedding-ada-002'
    MAX_INPUT_LEN = 8191
    MAX_OUTPUT_LEN = 1536

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
        embedding_list = Array(embeddings_object.dig('data', 0, 'embedding'))
    end

    def generate_answer(question)
        header = """You are an insurance expert and can answer any question from any insurance. 
            Given some context text and a question please find answers. 
            Please keep your answers to three sentences maximum, and speak in complete sentences. 
            Stop speaking once your point is made.\n\nContext that may be useful\n
            """

        prompt = header + "\n\n\n" + question.context[0..4000] + "\n\n\nQ: " + question.question + "\n\nA: "

        answer = @client.chat(
            parameters: {
                model: "gpt-3.5-turbo", 
                messages: [{ role: "user", content: prompt}],
                temperature: 0.0,
                max_tokens: 150
            }    
        )

        answer = answer.dig("choices", 0, "message", "content")
        
        question.update!(answer: answer)
        # TODO: Handle when answer doesn't give good enough answer.
    end
end
