# spec/base_class_spec.rb
require_relative "../../lib/site/base_class"

RSpec.describe Site::BaseClass do
  let(:base_class) { described_class.new }
  let(:url) { "http://example.com" }
  let(:params) { { days: 30, limit: 50, radius: 2, area: "test" } }
  let(:cache_dir) { described_class::CACHE_DIR }
  let(:cache_key) { Digest::SHA256.hexdigest(url + params.to_s) }
  let(:cache_file) { File.join(cache_dir, "#{cache_key}.json") }
  let(:response) { double("Net::HTTPResponse", code: "200", body: '{"prices": [100, 200]}') }

  before do
    FileUtils.rm_rf(cache_dir)
  end

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe "#with_cache" do
    context "when cache exists" do
      before do
        FileUtils.mkdir_p(cache_dir)
        File.write(cache_file, '{"prices": [100, 200]}')
      end

      it "reads from cache" do
        expect(base_class).not_to receive(:sleep)
        result = base_class.with_cache(url, params) { response }
        expect(result).to eq("prices" => [100, 200])
      end
    end

    context "when cache does not exist" do
      it "writes to cache and reads from cache" do
        expect(base_class).to receive(:sleep).with(5)
        allow(response).to receive(:code).and_return("200")

        result = base_class.with_cache(url, params) { response }
        expect(result).to eq("prices" => [100, 200])
        expect(File.exist?(cache_file)).to be_truthy
        expect(JSON.parse(File.read(cache_file))).to eq("prices" => [100, 200])
      end

      it "raises an error if response code is not 200" do
        allow(response).to receive(:code).and_return("500")

        expect {
          base_class.with_cache(url, params) { response }
        }.to raise_error(RuntimeError, /Fetch failed for url:/)
      end
    end
  end

  describe "#generate_cache_key" do
    it "generates a SHA256 hexdigest key based on URL and params" do
      expected_key = Digest::SHA256.hexdigest(url + params.to_s)
      expect(base_class.send(:generate_cache_key, url, params)).to eq(expected_key)
    end
  end

  describe "#cache_exists?" do
    context "when cache file exists" do
      before do
        FileUtils.mkdir_p(cache_dir)
        File.write(cache_file, "{}")
      end

      it "returns true" do
        expect(base_class.send(:cache_exists?, cache_file)).to be_truthy
      end
    end

    context "when cache file does not exist" do
      it "returns false" do
        expect(base_class.send(:cache_exists?, cache_file)).to be_falsey
      end
    end
  end

  describe "#read_from_cache" do
    before do
      FileUtils.mkdir_p(cache_dir)
      File.write(cache_file, '{"prices": [100, 200]}')
    end

    it "reads data from cache file" do
      result = base_class.send(:read_from_cache, cache_file)
      expect(result).to eq("prices" => [100, 200])
    end
  end

  describe "#write_to_cache" do
    let(:data) { '{"prices": [100, 200]}' }

    it "writes data to cache file" do
      base_class.send(:write_to_cache, cache_file, data)
      expect(File.exist?(cache_file)).to be_truthy
      expect(File.read(cache_file)).to eq(data)
    end
  end
end
