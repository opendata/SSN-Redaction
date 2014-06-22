require 'tabula'
require_relative './redaction_engine.rb'

module SSNRedaction

  def self.open_pdf(filename, password='')
    raise Errno::ENOENT unless File.exists?(filename)
    document = PDDocument.load(filename)
    if document.isEncrypted
      sdm = StandardDecryptionMaterial.new(password)
      document.openProtection(sdm)
    end
    document
  end

  # THIS IS THE MATCHING FUNCTION (right now is tied to SSN pattern)
  def self.match_pattern(text_to_match)
    # Default pattern for SSN
    pattern = /(?<!\d)(?!666|000|9\d{2})([OoIli0-9]{3})([\s-]?)(?!00)([OoIli0-9]{2})\2(?!0{4})([OoIli0-9]{4})(?!\d)/
    # rest_of_the_chunk = text_to_match.split(pattern.match(text_to_match).to_s)
    # first_character = rest_of_the_chunk[0][0]
    # last_character = rest_of_the_chunk[0][rest_of_the_chunk[0].size-1]

    text_to_match =~ pattern
  end

  # matching
  def self.get_matching_chunks(filename, page)
    extractor = Tabula::Extraction::ObjectExtractor.new(filename, [page])
    filtered = []

    extractor.extract.inject([]) do |memo, pdf_page|
      memo += Tabula::TextElement.merge_words(pdf_page.get_text).select do |chunk|
        match_pattern(chunk.text)
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
  def self.rebuild_pdf(extractor, pdf_filename, redacted_filename)
    pdf_file_path = File.expand_path(pdf_filename, File.dirname(__FILE__))
    document = org.apache.pdfbox.pdmodel.PDDocument.load(pdf_file_path)
    rse = RedactionStreamEngine.new([], redacted_filename)

    all_pages = document.getDocumentCatalog.getAllPages
    all_pages.each_with_index do |page, page_number|
      STDERR.puts "processing page: #{page}"
      rse.processStream(page, page.findResources, page.getContents.getStream)
      # parser = org.apache.pdfbox.pdfpa rser.PDFStreamParser.new(page.getContents)
      # parser.parse
      # tokens = parser.getTokens
      # arguments = []
      # tokens.each do |token|
      #   if token.java_kind_of?(org.apache.pdfbox.cos.COSObject)
      #     arguments << token.getObject
      #   elsif token.java_kind_of?(org.apache.pdfbox.util.PDFOperator) and
      #        (token.getOperation == 'TJ' or token.getOperation == 'Tj')
      #     puts arguments.inspect
      #     arguments = []
      #   else
      #     arguments << token
      #   end
      # end
    end
  end

  def self.count_matches(pdf_filename)

    amount_matches_per_page = {}
    total = 0

    document = SSNRedaction.open_pdf(pdf_filename)

    pages = document.getDocumentCatalog.getAllPages().to_a

    pages.each_with_index do |page, page_number|
      chunks_per_page = SSNRedaction.get_matching_chunks(pdf_filename, page_number+1)
      amount_matches_per_page[page_number+1] = chunks_per_page
      total += chunks_per_page.length
    end

    {:pages => amount_matches_per_page, :total => total}
  end
end
