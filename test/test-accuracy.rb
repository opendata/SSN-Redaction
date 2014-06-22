#!/usr/bin/env jruby -J-Djava.awt.headless=true
# encoding: utf-8

# A test harness for redact.rb
# Takes input PDF files plus CSV indicating which pages contain SSNs
# Outputs number of SSNs detected on each page, plus overall precision/recall

# Input CSV must have two cols: url and pages

require 'csv'

# We turn URL to filename by stripping everything after the last /
def get_filename(url)
  url.split('/').last
end

# Pages are in format "x;x;x" where x is a single page number or "a-b" for a range
def get_pages(pagestr)
    pages = []
    pagestr.split(';').each do |range|
      pagenums = range.split('-').map{|x| x.to_i} 
      if pagenums.length == 1
        pages << pagenums[0]
      elseif pagenums.length == 2
        pages << Array(pagenums[0]..pagenums[1])
      else
        puts("Warning: unknown page range " + range)
      end
    end
    pages
end

if ARGV.length < 1
  puts("USAGE: test-accuracy csvfile")
  Process.exit
end

infile_name = ARGV[0]

CSV.foreach(infile_name, :headers=>true) do |row|
  filename = get_filename(row['url'])
  pages = get_pages(row['pages'])
  numpages = pages.length

  result = `../redact.rb -test #{filename}`

  puts("#{filename}: contains #{numpages} pages with SSN, redaction found #{result} pages")
end
