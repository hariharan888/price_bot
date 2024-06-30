require "json"
require "csv"
require "net/http"
require "uri"
require_relative './site/booking/booking'

class PriceBot
  def initialize(days:, limit:, radius:, area:, site:, format:, output:)
    @days = days
    @limit = limit
    @radius = radius
    @area = area
    @site = get_site(site)
    @format = format
    @output = output
  end

  def fetch
    prices = fetch_prices
    save_prices(prices)
  end

  private

  def get_site(site)
    case site.downcase
    when "booking.com"
      Site::Booking.new
    else
      raise NotImplementedError, "Unsupported site: #{@site}"
    end
  end

  def fetch_prices
    params = {
      days: @days,
      limit: @limit,
      radius: @radius,
      area: @area,
    }
    @site.fetch_nightly_prices(params)
  end

  def save_prices(prices)
    case @format.downcase
    when "json"
      save_as_json(prices)
    when "csv"
      save_as_csv(prices)
    else
      raise "Unsupported format: #{@format}"
    end
  end

  def save_as_json(prices)
    File.open("#{@output}", "w") do |f|
      f.write(JSON.pretty_generate(prices))
    end
    true
  end

  def save_as_csv(prices)
    CSV.open("#{@output}", "w") do |csv|
      csv << prices.first.keys # add headers
      prices.each do |price|
        csv << price.values
      end
    end
    true
  end
end
