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

    opt :password, 'Password to decrypt document. Default is empty', :default => ''
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

  if opts[:test]
    amount_matches = SSNRedaction::count_matches(filename)

    amount_matches[:pages].keys.each do |page_number|
      puts "Page #{page_number}: #{amount_matches[:pages][page_number].length} matches."
      amount_matches[:pages][page_number].each do |chunk|
        puts chunk.text
      end
    end
    print "Total: %s" % amount_matches[:total]
  end
end

main
