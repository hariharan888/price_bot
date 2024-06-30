#!/usr/bin/env ruby

require "optparse"
require_relative "./price_bot"

class PriceBotCLI
  attr_reader :days, :limit, :radius, :area, :site, :format, :output, :top_n

  def initialize
    @options = {}
    parse_options
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "PriceBot: A tool to fetch nightly prices for hotels from booking sites."

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-d", "--days=DAYS", Integer, "Number of days (default: 30)") do |days|
        @options[:days] = days
      end

      opts.on("-l", "--limit=LIMIT", Integer, "Number of listings (default: 50)") do |limit|
        @options[:limit] = limit
      end

      opts.on("-r", "--radius=RADIUS", Float, "Radius in km (default: 2)") do |radius|
        @options[:radius] = radius
      end

      opts.on("-a", "--area=AREA", String, "Area around which listings should be searched") do |area|
        @options[:area] = area
      end

      opts.on("-s", "--site=SITE", String, "Booking site. Options Available: ['booking.com']. Will add more soon!") do |site|
        @options[:site] = site
      end

      opts.on("-f", "--format=FORMAT", String, "Output Format. Options Available: ['csv', 'json']. (default: 'csv')") do |output_format|
        @options[:format] = output_format
      end

      opts.on("-o", "--output=OUTPUT_LOCATION", String, "Output file location.") do |output|
        @options[:output] = output
      end

      opts.on("-n", "--top-n=N", Integer, "Number of top prices per listing") do |top_n|
        @options[:top_n] = top_n
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.parse!(ARGV)

      # Set default values if not provided
      @days = @options[:days] || 30
      @limit = @options[:limit] || 50
      @radius = @options[:radius] || 2
      @area = @options[:area]
      @site = @options[:site]&.downcase || "booking.com"
      @format = @options[:format]&.downcase || "csv"
      @output = @options[:output]
      @top_n = @options[:top_n]

      @options
    end
  end

  def validate_options
    if @area.nil? || @output.nil?
      abort "Error: area and output are required options."
    end

    unless ["csv", "json"].include?(@format)
      abort "Error: Unsupported format - #{@format}. Options Available: ['csv', 'json']"
    end

    # TODO: Only one site is supported for now. Extend it later.
    unless @site == "booking.com"
      abort "Error: Unsupported site - #{@site}. Options Available: ['booking.com']"
    end
  end

  def run
    validate_options

    price_bot = PriceBot.new(
      days: @days,
      limit: @limit,
      radius: @radius,
      area: @area,
      site: @site,
      format: @format,
      output: @output,
      top_n: @top_n
    )
    price_bot.fetch
  rescue => e
    abort "Error: #{e.message}"
  end
end
