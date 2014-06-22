require 'tabula'
require_relative './redaction_engine.rb'

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
end
