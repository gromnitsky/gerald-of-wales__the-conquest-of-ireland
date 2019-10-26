#!/usr/bin/env ruby
# coding: utf-8

def norm line
  return line.gsub(/[ÕÒÓÑ]/, {
                     'Õ' => "'",
                     'Ò' => '"',
                     'Ó' => '"',
                     'Ñ' => '--'
                   })
end

class Footnotes
  def initialize page_idx
    @ft_ref = /([^[:space:][0-9]\[(-])([0-9]+)/
    @page_idx = page_idx
    @current = nil
    @all = {}
  end

  attr_reader :current

  def scan_for_ref line
    return if @current  # no scanning while reading the footnote value
    line.match(@ft_ref) do |m|
      m = m[2]
      @all[m] = []
#      puts "-"*10 + " #{m}"
    end
  end

  def scan_for_val line
    line.match(/^[0-9]+$/) do |m|
      m = m[0]
      raise "page #{@page_idx}: no footnote #{m} in the text" if !@all[m]
      @current = m
    end
  end

  def add line; @all[@current].push line; end
  def size; @all.size; end
  def transform_ids line; line.gsub(@ft_ref, '\\1[^\\2]'); end

  def render
    @all.each do |ref, val|
      print "\n[^#{ref}]: "
      puts val[1..-1].join(' ')
    end
  end
end

ft = []

($stdin.read.split '').each_with_index do |page, page_idx|
  lines = page.split "\n"
  footnotes = Footnotes.new page_idx
  ft.push footnotes

  print "<!-- #{page_idx} --> "

  prev_line = ''
  lines.each_with_index do |line, idx|
    next if idx == 0
    line = (norm line).sub(/^(Book I)/, "\n# \\1").sub(/^(Chapter )/, "\n## \\1")

    footnotes.scan_for_ref line
    footnotes.scan_for_val line

    if footnotes.current
      footnotes.add(line)
      prev_line = ''
    else
      # a new paragraph?
      puts "" if /[[:upper:]]/.match(line[0]) && prev_line =~ /.[?.]$/
      prev_line = line

      puts footnotes.transform_ids(line)
    end

  end

#  footnotes.render
end

puts ""
ft.each do |footnotes|
  footnotes.render if footnotes.size > 0
end
