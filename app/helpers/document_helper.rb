require 'tiktoken_ruby'
require 'csv'

module DocumentHelper
    TOKENIZER = "cl100k_base"
    MAX_CHAT_TOKENS = 512

    class Document
        def self.extract_page_tokens(page_text, index)
            return [] if page_text.empty?

            content = page_text.split.join(' ')
            tokenizer = Tiktoken.get_encoding(TOKENIZER)
            token_count = tokenizer.encode(page_text).length + 4
            ["Page #{index}", content, token_count]
        end

        # TODO: Bug here. Fix.
        #{"error"=>
        #   {"message"=>"This model's maximum context length is 4097 tokens. However, your messages resulted in 9292 tokens. Please reduce the length of the messages.",
        #   "type"=>"invalid_request_error",
        #   "param"=>"messages",
        #   "code"=>"context_length_exceeded"}}
        def self.get_chosen_sections(most_relevant_sections, question)
            input_len = 0
            most_relevant_sections_text = []
            most_relevant_sections.each do |_, title|
                CSV.open(question.document.processed_pages_file, headers: true) do |csv|
                    csv.each do |row|
                        if row['title'] == title 
                            if input_len + row["tokens"].length > MAX_CHAT_TOKENS
                                remaining_tokens = MAX_CHAT_TOKENS - input_len
                                most_relevant_sections_text << row["tokens"][0..remaining_tokens]
                            else
                                most_relevant_sections_text << row["content"]
                                input_len += row["tokens"].length 
                            end
                        end
                    end
                end
            end
            most_relevant_sections_text.join('')
        end
    end
end