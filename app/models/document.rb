require 'open-uri'

class Document < ApplicationRecord
    BASE_DIR_DOCUMENTS = 'lib/assets'

    has_many :questions

    validates :name, presence: true
    
    after_find :initialize_file_paths

    attr_accessor :processed_pages_file, :processed_embeddings_file

    after_create :parse_pdf

    # TODO: move function to helper and use a private function to call the function.
        
    def parse_pdf
        initialize_file_paths
        # Parse the downloaded file
        File.open(original_file_path, 'rb') do |file|
            reader = PDF::Reader.new(file)
            # TODO: Handle path creation better.
            CSV.open(self.processed_pages_file, 'w') do |csv|
                csv << ['title', 'content', 'tokens']
                
                reader.pages.each_with_index do |page, i| 
                    page_details = DocumentHelper::Document.extract_page_tokens(page.text, i+1)
                    csv << page_details if page_details[2] < OpenaiService::MAX_INPUT_LEN
                end
            end
        end
        self.generate_and_save_embeddings
    end

    private

    def initialize_file_paths
        self.processed_pages_file = "lib/assets/#{name}.pages.csv"
        self.processed_embeddings_file = "lib/assets/#{name}.embeddings.csv"
    end

    def generate_and_save_embeddings
        document_embeddings = {}
        @open_ai_service = OpenaiService.new
        csv_lock = Mutex.new
        threads = []

        # TODO: Move to pinecone.
        CSV.open(self.processed_embeddings_file, 'w') do |csv|
            csv << ["title"] + (1..OpenaiService::MAX_OUTPUT_LEN).to_a 
            CSV.foreach(self.processed_pages_file, headers: true) do |row|
                threads << Thread.new do
                    embedding_list = @open_ai_service.generate_embeddings(row['content'])
                    csv_lock.synchronize do
                        csv << [row["title"]] + embedding_list
                    end
                end
            end
            threads.each(&:join)
        end
    end    
end
