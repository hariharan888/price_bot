require "json"
require "csv"
require "net/http"
require "uri"
require_relative "../lib/price_bot"
require_relative "../lib/site/booking/booking"

RSpec.describe PriceBot do
  let(:days) { 30 }
  let(:limit) { 50 }
  let(:radius) { 2 }
  let(:area) { "Test Area" }
  let(:site) { "booking.com" }
  let(:format) { "json" }
  let(:output) { "output.json" }

  subject { described_class.new(days: days, limit: limit, radius: radius, area: area, site: site, format: format, output: output) }

  describe "#initialize" do
    it "initializes with correct attributes" do
      expect(subject.instance_variable_get(:@days)).to eq(days)
      expect(subject.instance_variable_get(:@limit)).to eq(limit)
      expect(subject.instance_variable_get(:@radius)).to eq(radius)
      expect(subject.instance_variable_get(:@area)).to eq(area)
      expect(subject.instance_variable_get(:@format)).to eq(format)
      expect(subject.instance_variable_get(:@output)).to eq(output)
    end
  end

  describe "#fetch" do
    it "fetches and saves prices" do
      allow(subject).to receive(:fetch_prices).and_return([{ "hotel" => "Test Hotel", "price" => 100 }])
      expect(subject).to receive(:save_prices).with([{ "hotel" => "Test Hotel", "price" => 100 }])
      subject.fetch
    end
  end

  describe "#get_site" do
    it "returns a Site::Booking instance for booking.com" do
      site_instance = subject.send(:get_site, "booking.com")
      expect(site_instance).to be_a(Site::Booking)
    end

    it "raises an error for unsupported site" do
      expect { subject.send(:get_site, "unsupported.com") }.to raise_error(NotImplementedError)
    end
  end

  describe "#save_prices" do
    let(:prices) { [{ "hotel" => "Test Hotel", "price" => 100 }] }

    context "when format is json" do
      it "saves prices as json" do
        expect(subject).to receive(:save_as_json).with(prices)
        subject.send(:save_prices, prices)
      end
    end

    context "when format is csv" do
      let(:format) { "csv" }

      it "saves prices as csv" do
        expect(subject).to receive(:save_as_csv).with(prices)
        subject.send(:save_prices, prices)
      end
    end

    context "when format is unsupported" do
      let(:format) { "xml" }

      it "raises an error" do
        expect { subject.send(:save_prices, prices) }.to raise_error("Unsupported format: xml")
      end
    end
  end

  describe "#save_as_json" do
    let(:prices) { [{ "hotel" => "Test Hotel", "price" => 100 }] }

    it "writes prices to a json file" do
      expect(File).to receive(:open).with(output, "w")
      subject.send(:save_as_json, prices)
    end
  end

  describe "#save_as_csv" do
    let(:prices) { [{ "hotel" => "Test Hotel", "price" => 100 }] }
    let(:csv_file) { instance_double("CSV") }

    it "writes prices to a csv file" do
      expect(CSV).to receive(:open).with(output, "w").and_yield(csv_file)
      expect(csv_file).to receive(:<<).with(prices.first.keys)
      expect(prices).to receive(:each).and_yield(prices.first)
      expect(csv_file).to receive(:<<).with(prices.first.values)

      subject.send(:save_as_csv, prices)
    end
  end
end
