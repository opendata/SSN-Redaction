# A test harness for redact.rb
# Takes input PDF files plus CSV indicating which pages contain SSNs
# Outputs number of SSNs detected on each page, plus overall precision/recall

# Input CSV must have two cols: url and pages

require 'csv'

# number of files to test (don't read entire CSV)
max_files = 9999


# Turn URL to filename
# https://bulk.resource.org/irs.gov/eo/2014_02_EO/26-2809844_990EZ_201312.pdf -> 
# 990s/2014_02_EO/26-2809844_990EZ_201312_ocr.pdf
def get_filename(url)
  parts = url.split('/')
  dirname = parts[-2]
  filename = parts[-1].split('.')[0] + "_ocr.pdf"
  '990s/' + dirname + '/' + filename
end

# Pages are in format "x;x;x" where x is a single page number or "a-b" for a range
def get_pages(pagestr)
    pages = []
    pagestr.split(';').each do |range|
      pagenums = range.split('-').map{|x| x.to_i} 
      if pagenums.length == 1
        pages << pagenums[0]
      elsif pagenums.length == 2
        pages += Array(pagenums[0]..pagenums[1])
      else
        puts("Warning: unknown page range " + range)
      end
    end
    pages
end

# Take redact.rb output and produce list of pages where a match was found
def parse_result(result)
  # Looking for lines like this: Page 14: 1 matches.
  pattern = /Page (\d+): (\d+) matches/

  pages = []
  lines = result.split('.')  # for some reasons splitting on \n doesn't seem to work

  lines.each do |line|
    groups = line.scan(pattern)[0]
    #puts("groups: #{groups}")
    if (groups != nil) and (groups.length == 2) and (groups[1].to_i > 0)
     #puts("found page #{groups[0]}")
     pages << groups[0].to_i
    end
  end

  pages
end

false_positives = 0
false_negatives = 0
true_positives = 0
true_pages = 0
files = 0

CSV.foreach("gold.csv", :headers=>true) do |row|
  filename = get_filename(row['URL'])
  pages = get_pages(row['Page No.'])

  if File.file?(filename)
    result = `../redact.rb --test #{filename}`
    puts(result)
    foundpages = parse_result(result)


    if pages == foundpages
      puts("#{filename}: correctly detected pages #{pages}")
    else
      puts("#{filename}: ERROR found #{foundpages}, correct pages are #{pages}")
      false_negatives += (pages-foundpages).length
      false_positives += (foundpages-pages).length
      true_positives += (pages&foundpages).length
    end

    true_pages += pages.length
    files += 1

    puts("------------")
    puts("Tested #{files} files")
    puts("Pages with SSNs to detect: #{true_pages}")
    puts("Pages with false negatives: #{false_negatives}")
    puts("Pages with false_positives: #{false_positives}")
    puts("Precision: #{true_positives.to_f/(true_positives + false_positives)}")
    puts("Recall: #{true_positives.to_f/(true_positives + false_negatives)}")
    puts("------------")
  else
    puts("Missing test file #{filename}")
  end

  if (files >= max_files)
    break
  end

end




