# PriceBot

PriceBot is a command-line tool to fetch nightly prices for the given amount of days of the closest hotels within a given radius from a location. The data is fetched from various booking site APIs.


## Usage

You can run PriceBot from the command line as follows:

```sh
bundle exec bin/price_bot.rb -d DAYS -l LIMIT -r RADIUS -a AREA -s SITE -f FORMAT -o OUTPUT
```

### Options

- `-d, --days=DAYS`: Number of days (default: 30)
- `-l, --limit=LIMIT`: Number of listings (default: 50)
- `-r, --radius=RADIUS`: Radius in kilometers (default: 2)
- `-a, --area=AREA`: Area around which listings should be searched
- `-s, --site=SITE`: Booking site. Options Available: `['booking.com']`
- `-f, --format=FORMAT`: Output format. Options Available: `['csv', 'json']` (default: 'csv')
- `-o, --output=OUTPUT_LOCATION`: Output file location
- `-n, --top-n=TOP_N`: If provided, will output only the top n dates with highest pricing for each listing 

### Example

Fetch prices for 365 days, limiting to 50 listings within a 2 km radius of New York, using booking.com, and save the output as CSV to `prices.csv`:

```sh
bundle exec bin/price_bot.rb -d 365 -l 50 -r 2 -a "New York" -s "booking.com" -f "csv" -o "prices.csv"
```

In the above request, to get only top n daily prices for each listing:

```sh
bundle exec bin/price_bot.rb -d 365 -l 50 -r 2 -a "New York" -s "booking.com" -f "csv" -o "top_prices.csv" -n 3
```


Fetch prices for 30 days, limiting to 50 listings within a 5 km radius of New York, using booking.com, and save the output as JSON to `prices.json`:

```sh
bundle exec bin/price_bot.rb -d 30 -l 50 -r 5 -a "New York" -s "booking.com" -f "json" -o "prices.json"
```

## Running Tests

RSpec is used for testing. To run the tests, use:

```sh
bundle exec rspec
```