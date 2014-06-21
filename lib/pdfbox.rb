module PDFRedaction
  PDFBOX = 'pdfbox-app-2.0.0-SNAPSHOT.jar'
  ONLY_SPACES_RE = Regexp.new('^\s+$')
  SAME_CHAR_RE = Regexp.new('^(.)\1+$')
  VERSION = "0.0.1"
end

require File.join(File.dirname(__FILE__), '../target/', PDFRedaction::PDFBOX)

java_import 'java.util.logging.LogManager'
java_import 'java.util.logging.Level'



lm = LogManager.log_manager
lm.logger_names.each do |name|
  if name == "" #rootlogger is apparently the logger PDFBox is talking to.
    l = lm.get_logger(name)
    l.level = Level::OFF
    l.handlers.each do |h|
      h.level = Level::OFF
    end
  end
end
