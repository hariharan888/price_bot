require_relative "../base_class"
require_relative "booking_listing"
require "net/http"
require "uri"
require "json"

module PriceBot
  module Site
    class Booking < BaseClass
      BASE_URL = "https://www.booking.com/dml/graphql"

      def fetch_nightly_prices(params)
        listings = get_listings(params)
        listings.reduce([]) do |acc, listing|
          prices = get_nightly_prices(listing, params)
          listings_with_prices = prices.map { |price| transform_daily_price_record(listing, price) }
          acc += listings_with_prices
          acc
        end
      end

      private

      def checkin_date
        Date.today.to_s
      end

      def checkout_date
        # To get daily prices, assigning difference b/w check-in and check-out is 1 day
        (Date.today + 1).to_s
      end

      def transform_daily_price_record(listing, price)
        {
          'ID': listing.id,
          'Site': "booking.com",
          'Name': listing.name,
          'Distance from centre': listing.distance_from_centre,
          'Date': price["checkin"],
          'Average Price': price["avgPrice"],
          'Review Score': listing.review_score,
          'Review Count': listing.review_count,
          'Stars': listing.stars,
          'Meal Plan': listing.meal_plan,
          'Address': listing.address,
          'City': listing.city,
          'Country Code': listing.country_code,
          'Currency': listing.currency,
        }
      end

      def get_nightly_prices(listing, params)
        params => { limit: }
        prices = []
        start_date = checkin_date

        while prices.count < limit
          page_data = get_price_request(listing, start_date)
          prices += page_data

          break if page_data.empty?
          sleep 1 # avoid high frequent hits

          last_date = Date.parse(page_data.last["checkin"])
          start_date = (last_date + 1).to_s
        end
        prices
      end

      def get_price_request(listing, start_date)
        url = get_price_url(listing)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"

        request = Net::HTTP::Post.new(uri.request_uri)
        set_headers!(request)
        request.body = get_pricing_request_body(listing, start_date)

        response = with_cache(url, params) { http.request(request) }

        prices_data = response.dig("data", "availabilityCalendar", "days") || []
        prices_data.sort_by { |row| row["checkin"] }
      end

      def get_price_url(listing)
        best_block_id = listing.best_block_id
        query = {
          checkin: checkin_date,
          checkout: checkout_date,
          dest_type: "city",
          group_adults: "1",
          req_adults: "1",
          no_rooms: "1",
          group_children: "0",
          req_children: "0",
          from: "searchresults",
          lang: "en-gb",
          all_sr_blocks: best_block_id,
          highlighted_blocks: best_block_id,
          matching_block_id: best_block_id,
        }
        # sr_pri_blocks: "568525001_366079264_2_41_0__300000",
        # sid=4789ac7454679edc3a1d911b7704f6a8
        # aid=304142
        # ucfs=1
        # arphpl=1
        # hpos=2
        # hapos=2
        # srpvid=b34846a2c6df0160
        # srepoch=1719741792
        query_string = URI.encode_www_form(query_params)

        "#{BASE_URL}?#{query_string}"
      end

      def get_listings(params)
        url = get_listing_url(params)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"

        request = Net::HTTP::Post.new(uri.request_uri)
        set_headers!(request)
        request.body = get_listing_request_body(params)

        response = with_cache(url, params) { http.request(request) }
        listings_data = response.dig("data", "searchQueries", "search", "results") || []
        listings = listings_data.map { |listing| PriceBot::Site::BookingListing.new(listing) }

        listings
      end

      def get_listing_url(params)
        params => { limit:, radius:, area: }
        query_params = {
          ss: area,
          ssne: area,
          ssne_untouched: area,
          lang: "en-gb",
          sb: 1,
          src_elem: "sb",
          src: "searchresults",
          dest_type: "city",
          checkin: checkin_date,
          checkout: checkout_date,
          group_adults: 1,
          no_rooms: 1,
          group_children: 0,
        }
        query_string = URI.encode_www_form(query_params)

        "#{BASE_URL}?#{query_string}"
      end

      def get_pricing_request_body(listing, start_date)
        search_params_file = File.join(File.dirname(__FILE__), "listing_price_params.json.json")
        data_raw = File.read(search_params_file)
        data_raw.gsub!("PRICEBOT_COUNTRY_CODE", listing.country_code)
          .gsub!("PRICEBOT_PAGE_NAME", listing.page_name)
          .gsub!("PRICEBOT_START_DATE", start_date)

        JSON.parse(data_raw).to_json # remove spaces and new lines
      end

      def get_listing_request_body(params)
        params => { limit:, radius:, area: }

        search_params_file = File.join(File.dirname(__FILE__), "listings_search_params.json")
        data_raw = File.read(search_params_file)
        data_raw.gsub!("PRICEBOT_FROM_DATE", checkin_date)
          .gsub!("PRICEBOT_TO_DATE", checkout_date)
          .gsub!("PRICEBOT_AREA", area)
          .gsub!("PRICEBOT_DISTANCE", (radius * 1000).to_s) # in meter
          .gsub!('"PRICEBOT_LIMIT"', limit.to_s)
        JSON.parse(data_raw).to_json # remove spaces and new lines
      end

      def set_headers!(request)
        request["accept"] = "*/*"
        request["accept-language"] = "en-GB,en-US;q=0.9,en;q=0.8"
        request["content-type"] = "application/json"
        request["origin"] = "https://www.booking.com"
        request["priority"] = "u=1, i"
        request["referer"] = "https://www.booking.com/searchresults.en-gb.html"
        request["sec-ch-ua"] = '"Not/A)Brand";v="8", "Chromium";v="126", "Google Chrome";v="126"'
        request["sec-ch-ua-platform"] = '"Linux"'
        request["sec-fetch-dest"] = "empty"
        request["sec-fetch-mode"] = "cors"
        request["sec-fetch-site"] = "same-origin"
        request["user-agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
        request["x-booking-context-action-name"] = "searchresults_irene"
        request["x-booking-site-type-id"] = "1"
        request["x-booking-topic"] = "capla_browser_b-search-web-searchresults"

        request
      end
    end
  end
end
