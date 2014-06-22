require 'tabula'
module SSNRedaction

  def self.openPDF(filename, password='')
    raise Errno::ENOENT unless File.exists?(pdf_filename)
    document = PDDocument.load(filename)
    if document.isEncrypted
      sdm = StandardDecryptionMaterial.new(password)
      document.openProtection(sdm)
    end
    document
  end

  # matching
  def self.get_matching_chunks(filename, page, pattern)
    extractor = Tabula::Extraction::ObjectExtractor.new(filename, [page])
    filtered = []

    extractor.extract.inject([]) do |memo, pdf_page|
      memo += Tabula::TextElement.merge_words(pdf_page.get_text).select do |chunk|
        chunk.text =~ pattern
      end
    end
  end

  def self.redact_page(document, pattern)
    # match chunks in the page
    # redact them

  end

  def self.redact_chunk(chunk, pattern)
    # Search the specific pattern INSIDE the chunk
    phrase = chunk.text

    initial_character = phrase =~ pattern
    initial_text_element = chunk.text_elements[initial_character]

    last_character = initial_character + pattern.match(chunk.text).to_s.length - 1
    last_text_element = chunk.text_elements[last_character]

    # return chunk without text AND first and last text element with its coordinates
    [initial_text_element, last_text_element]
  end

  # TODO
  def self.rebuild_pdf(extractor, pdf_filename)
    try {
      pdf_file_path = File.expand_path(pdf_filename, File.dirname(__FILE__))
      document = PDDocument.new(pdf_file_path)

      extractor.extract.each do |page|
        new_page = PDPage.new()
        document.addPage(new_page)

        contentStream  = PDPageContentStream.new(document, new_page)

        # write the text

        contentStream.close()
      end

      self.document.save(filename);
      self.document.close();
    }
  end
end
