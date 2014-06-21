require 'tabula'
module SSNRedaction

  def self.get_matching_chunks(filename, page, pattern)
    extractor = Tabula::Extraction::ObjectExtractor.new(filename, [page])
    filtered = []
    extractor.extract.inject([]) do |memo, pdf_page|
      memo += Tabula::TextElement.merge_words(pdf_page.get_text).select do |chunk|
        chunk.text =~ pattern
      end
    end
  end
end
