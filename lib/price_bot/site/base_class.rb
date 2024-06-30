require "digest"
require "json"
require "fileutils"

module PriceBot
  module Site
    class BaseClass
      CACHE_DIR = "tmp"

      def fetch_nightly_prices(params)
        raise NotImplementedError, "Subclasses must implement the fetch_nightly_prices method"
      end

      def with_cache(url, params)
        cache_key = generate_cache_key(url, params)
        cache_file = File.join(CACHE_DIR, "#{cache_key}.json")

        return read_from_cache(cache_file) if cache_exists?(cache_file)

        response = yield

        raise "Fetch failed for url: #{url}" unless response.code == "200"

        write_to_cache(cache_file, response.body)
        read_from_cache(cache_file)
      end

      private

      def generate_cache_key(url, params)
        Digest::SHA256.hexdigest(url + params.to_s)
      end

      def cache_exists?(cache_file)
        File.exist?(cache_file)
      end

      def read_from_cache(cache_file)
        JSON.parse(File.read(cache_file))
      end

      def write_to_cache(cache_file, data)
        FileUtils.mkdir_p(File.dirname(cache_file))
        File.open(cache_file, "w") do |file|
          file.write(data)
        end
      end
    end
  end
end
