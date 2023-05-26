require 'tiktoken_ruby'
require 'csv'

module DocumentHelper
    TOKENIZER = "cl100k_base"
    MAX_CONTEXT_LEN = 1000
    SEPARATOR = "\n* "

    class Document
        def self.extract_page_tokens(page_text, index)
            return [] if page_text.empty?

            content = page_text.split.join(' ')
            tokenizer = Tiktoken.get_encoding(TOKENIZER)
            token_count = tokenizer.encode(page_text).length + 4
            ["Page #{index}", content, token_count]
        end

        def self.get_text_from_relevant_pages(most_relevant_sections, question)
            input_len = 0
            most_relevant_sections_text = []
            most_relevant_sections.each do |_, title|
                CSV.open(question.document.processed_pages_file, headers: true) do |csv|
                    csv.each do |row|
                        if row['title'] == title 
                            if input_len + row["tokens"].to_i > MAX_CONTEXT_LEN
                                remaining_tokens = MAX_CONTEXT_LEN - input_len - SEPARATOR.length
                                most_relevant_sections_text << SEPARATOR + row["content"][0..remaining_tokens]
                            else
                                most_relevant_sections_text << SEPARATOR + row["content"]
                                input_len += row["tokens"].to_i
                            end
                        end
                    end
                end
            end
            most_relevant_sections_text.join('')
        end
    end
end