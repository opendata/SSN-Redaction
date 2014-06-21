require 'tabula'
module SSNRedaction

  def self.extract_text(filename, pages)
    extractor = Tabula::Extraction::ObjectExtractor.new(filename, pages)



  end

end
