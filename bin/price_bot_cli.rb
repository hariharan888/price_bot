#!/usr/bin/env ruby

require "optparse"

class PriceBotCLI
  attr_reader :days, :limit, :radius, :area, :site, :format, :output

  def initialize
    @options = {}
    parse_options
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: price_bot.rb [options]"

      opts.on("-dDAYS", "--days=DAYS", Integer, "Number of days (default: 30)") do |days|
        @options[:days] = days
      end

      opts.on("-lLIMIT", "--limit=LIMIT", Integer, "Number of listings (default: 50)") do |limit|
        @options[:limit] = limit
      end

      opts.on("-rRADIUS", "--radius=RADIUS", Float, "Radius in km (default: 2)") do |radius|
        @options[:radius] = radius
      end

      opts.on("-aAREA", "--area=AREA", String, "Area around which listings should be searched") do |area|
        @options[:area] = area
      end

      opts.on("-sSITE", "--site=SITE", String, "Booking site. Options Available: ['booking.com']. Will add more soon!") do |site|
        @options[:site] = site
      end

      opts.on("-fFORMAT", "--format=FORMAT", String, "Output Format. Options Available: ['csv', 'json']. (default: 'csv')") do |site|
        @options[:site] = site
      end

      opts.on("-oOUTPUT_LOCATION", "--output=OUTPUT_LOCATION", String, "Output file location.") do |site|
        @options[:site] = site
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
      @site = @options[:site].downcase || "booking.com"
      @format = @options[:format].downcase || "csv"
      @output = @options[:output]

      validate_options
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

    unless File.file?(@output) && File.writable?(@output)
      abort "Error: Output file location is not writable."
    end
  end

  def run
    price_bot = PriceBot.new(
      days: @days,
      limit: @limit,
      radius: @radius,
      area: @area,
      site: @site,
      format: @format,
      output: @output,
    )
    price_bot.fetch
  rescue => e
    abort "Error: #{e.message}"
  end
end

# Execute the script
cli = PriceBotCLI.new
cli.run
