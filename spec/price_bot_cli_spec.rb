require 'optparse'
require_relative '../lib/price_bot'
require_relative '../lib/price_bot_cli'

RSpec.describe PriceBotCLI do
  let(:default_options) do
    {
      days: 30,
      limit: 50,
      radius: 2,
      site: "booking.com",
      format: "csv"
    }
  end

  describe '#initialize' do
    it 'initializes with default options' do
      cli = PriceBotCLI.new
      expect(cli.days).to eq(30)
      expect(cli.limit).to eq(50)
      expect(cli.radius).to eq(2)
      expect(cli.site).to eq("booking.com")
      expect(cli.format).to eq("csv")
    end
  end

  describe '#parse_options' do
    it 'parses command line options' do
      cli = PriceBotCLI.new
      cli.parse_options

      # Override ARGV for testing
      ARGV.replace(['-d', '10', '-l', '20', '-r', '5', '-a', 'Test Area', '-s', 'booking.com', '-f', 'json', '-o', 'output.json'])
      cli.parse_options

      expect(cli.days).to eq(10)
      expect(cli.limit).to eq(20)
      expect(cli.radius).to eq(5)
      expect(cli.area).to eq('Test Area')
      expect(cli.site).to eq('booking.com')
      expect(cli.format).to eq('json')
      expect(cli.output).to eq('output.json')
    end
  end

  describe '#validate_options' do
    it 'raises error if area is not provided' do
      cli = PriceBotCLI.new
      expect { cli.validate_options }.to raise_error(SystemExit)
    end

    it 'raises error if output is not provided' do
      cli = PriceBotCLI.new
      ARGV.replace(['-a', 'Test Area'])
      expect { cli.validate_options }.to raise_error(SystemExit)
    end

    it 'raises error if unsupported format is provided' do
      cli = PriceBotCLI.new
      ARGV.replace(['-a', 'Test Area', '-o', 'output.json', '-f', 'xml'])
      expect { cli.validate_options }.to raise_error(SystemExit)
    end

    it 'raises error if unsupported site is provided' do
      cli = PriceBotCLI.new
      ARGV.replace(['-a', 'Test Area', '-o', 'output.json', '-s', 'unsupported.com'])
      expect { cli.validate_options }.to raise_error(SystemExit)
    end
  end

  describe '#run' do
    it 'calls PriceBot with correct parameters' do
      ARGV.replace(['-a', 'Test Area', '-o', 'output.json'])

      price_bot = instance_double("PriceBot", fetch: nil)
      expect(PriceBot).to receive(:new).with(
        days: 30,
        limit: 50,
        radius: 2,
        area: 'Test Area',
        site: 'booking.com',
        format: 'csv',
        output: 'output.json'
      ).and_return(price_bot)

      cli = PriceBotCLI.new
      cli.run
    end

    it 'aborts with error message on exception' do
      ARGV.replace(['-a', 'Test Area', '-o', 'output.json'])

      allow(PriceBot).to receive(:new).and_raise(StandardError, 'test error')

      cli = PriceBotCLI.new
      expect { cli.run }.to raise_error(SystemExit)
    end
  end
end
