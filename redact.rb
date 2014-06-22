#!/usr/bin/env jruby -J-Djava.awt.headless=true
# encoding: utf-8
require 'trollop'
require_relative 'lib/pdfbox'
require_relative 'lib/ssn-redaction/ssn-redaction'

def parse_command_line
  opts = Trollop::options do
    version "pdfredaction #{PDFRedaction::VERSION} #OWS Hackaton 2014"
    banner <<-EOS
      PDF Redaction helps you redact SSN from PDFs

      Usage:
      redact [options] <pdf_file>
      where [options] are:
      EOS

    opt :pages, 'Comma separated list of ranges, or all. Examples: --pages 1-3,5-7, --pages 3 or --pages all. Default is --pages 1', :default => '1', :type => String
    opt :password, 'Password to decrypt document. Default is empty', :default => ''
    opt :guess, 'Guess the portion of the page to analyze per page.'
    opt :silent, 'Suppress all stderr output.'
    opt :test, 'Print amount of matches per page.'
  end

  Trollop::die "need one filename" if ARGV.empty?

  pdf_filename = ARGV.shift
  Trollop::die 'file does not exist' unless File.exists? pdf_filename

  return opts, pdf_filename
end

def main
  opts, filename = parse_command_line

  # Default pattern for SSN
  pattern = /(?!666|000|9\d{2})\d{3}(-|\s?)(?!00)\d{2}\1(?!0{4})\d{4}/

  if opts[:test]
    amount_matches = SSNRedaction::count_matches(filename, pattern)

    amount_matches[:pages].keys.each do |page_number|
      puts "Page #{page_number}: #{amount_matches[:pages][page_number]} matches."
    end
    print "Total: %s" % amount_matches[:total]
  end
end

main
