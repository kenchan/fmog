# frozen_string_literal: true

require "rexml/document"

module Fmog
  module Opml
    class Importer
      Result = Struct.new(:added, :skipped, :errors, keyword_init: true)

      def self.import(path)
        new(path).import
      end

      def initialize(path)
        @path = path
      end

      def import
        xml = File.read(@path)
        doc = REXML::Document.new(xml)

        added = 0
        skipped = 0
        errors = []

        collect_urls(doc.root).each do |url|
          Feed.add(url)
          added += 1
        rescue SQLite3::ConstraintException
          skipped += 1
        rescue => e
          errors << { url: url, message: e.message }
        end

        Result.new(added: added, skipped: skipped, errors: errors)
      rescue Errno::ENOENT
        raise "File not found: #{@path}"
      rescue REXML::ParseException => e
        raise "Invalid OPML: #{e.message}"
      end

      private

      def collect_urls(element)
        return [] if element.nil?

        urls = []
        element.each_element("//outline") do |outline|
          url = outline.attributes["xmlUrl"]
          urls << url if url && !url.empty?
        end
        urls
      end
    end
  end
end
