module SSNRedaction

  class ShowText < org.apache.pdfbox.util.operator.ShowText
    def process(operator, arguments)
      super(operator, arguments)
      context.text_operator = [self, arguments]
    end
  end

  class ShowTextGlyph < org.apache.pdfbox.util.operator.ShowTextGlyph
    def process(operator, arguments)
      super(operator, arguments)
      puts arguments.first.toList.to_a.inspect
      context.text_operator = [self, arguments]
    end
  end

  class RedactionStreamEngine < org.apache.pdfbox.util.PDFTextStripper

    field_accessor :operators, :page, :streamResourcesStack
    attr_accessor :text_operator

    def initialize(redaction_boxes, output_doc)
      super()

      @redaction_boxes = redaction_boxes
      @newTokens = []

      #@newContents = org.apache.pdfbox.pdmodel.common.PDStream.new
      #@writer = org.apache.pdfbox.pdfwriter.ContentStreamWriter.new(newContents.createOutputStream)
      self.registerOperatorProcessor("Tj", ShowText.new)
      self.registerOperatorProcessor("TJ", ShowTextGlyph.new)
    end

    def processOperator(operation, arguments)
      super(operation, arguments)
    end

    def processTextPosition(textPosition)

    end

    def processSubStream(page, resources, cosStream)
      self.page = page
      if !resources.nil?
        streamResourcesStack.push(resources)
        begin
          pss(cosStream)
        ensure
          streamResourcesStack.pop().clear()
        end
      else
        pss(cosStream)
      end
    end

    # redefines private method processSubStream(cosStream)
    def pss(cosStream)
      arguments = []
      parser = org.apache.pdfbox.pdfparser.PDFStreamParser.new(cosStream, self.forceParsing)
      begin
        iter = parser.getTokenIterator
        while iter.hasNext
          n = iter.next
          if n.java_kind_of?(org.apache.pdfbox.cos.COSObject)
            arguments << n.getObject
          elsif n.java_kind_of?(org.apache.pdfbox.util.PDFOperator)
            processOperator(n, arguments)

            # here is where we decide whether to skip a text token.
            # if the processed operator was TJ or Tj, and it was inside a box
            # that we should redact, let's remove it's arguments from the list
            # of tokens.

            arguments = []
          else
            arguments << n
          end
          @newTokens << n
        end
      ensure
        parser.close
      end
    end
  end
end
