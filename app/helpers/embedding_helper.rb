module EmbeddingHelper
    class Embedding
        def self.cosine_similarity(vecA, vecB)
            raise TypeError, "Vectors should be arrays" unless vecA.is_a?(Array) && vecB.is_a?(Array)
            raise VectorSizeMismatch, "Vector sizes mismatch" unless vecA.size == vecB.size
          
            dot_product = 0
            vecA.zip(vecB).each do |v1i, v2i|
                dot_product += v1i * v2i
            end
          
            a = vecA.map { |n| n**2 }.reduce(:+)
            b = vecB.map { |n| n**2 }.reduce(:+)
          
            dot_product / (Math.sqrt(a) * Math.sqrt(b))
        end

        def self.get_pages_most_similar_to_question(question, question_embedding)
            most_relevant_sections = []
            CSV.foreach(question.document.embedding_path, headers: true) do |row|
                row_vals = row.fields
                page_title = row_vals[0]
                document_embedding = row_vals[1..-1].map(&:to_f)
    
                most_relevant_sections << [self.cosine_similarity(question_embedding, document_embedding), page_title]
            end    

            most_relevant_sections = most_relevant_sections.sort_by { |similarity_score, title| similarity_score }.reverse
            
            most_relevant_sections
        end
    end
end