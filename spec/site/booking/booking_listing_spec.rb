# spec/booking_listing_spec.rb
require_relative "../../../lib/site/booking/booking_listing"

RSpec.describe Site::BookingListing do
  let(:data) do
    {
      "basicPropertyData" => {
        "id" => 123,
        "pageName" => "test_page",
        "location" => {
          "address" => "123 Test St",
          "city" => "Test City",
          "countryCode" => "in",
        },
        "reviewScore" => {
          "score" => 8.5,
          "reviewCount" => 150,
        },
        "starRating" => {
          "value" => 4,
        },
      },
      "displayName" => {
        "text" => "Test Hotel",
      },
      "location" => {
        "mainDistance" => '150 m from centre',
      },
      "priceDisplayInfoIrene" => {
        "displayPrice" => {
          "amountPerStay" => {
            "amountUnformatted" => 100,
            "currency" => "INR",
          },
        },
      },
      "mealPlanIncluded" => {
        "text" => "Breakfast included",
      },
      "matchingUnitConfigurations" => {
        "unitConfigurations" => [
          { "unitId" => 456 },
        ],
      },
      "blocks" => [
        {
          "blockId" => {
            "roomId" => 456,
            "policyGroupId" => "policy_1",
            "occupancy" => 2,
            "mealPlanId" => "meal_1",
            "packageId" => "package_1",
          },
        },
      ],
    }
  end

  subject { described_class.new(data) }

  describe "#inspect" do
    it "returns a custom inspect string" do
      expect(subject.inspect).to eq("#<Site::BookingListing @id=123 @name=Test Hotel>")
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the listing" do
      expected_hash = {
        id: 123,
        name: "Test Hotel",
        address: "123 Test St",
        city: "Test City",
        country_code: "in",
        distance_from_centre: '150 m from centre',
        display_price: 100,
        currency: "INR",
        review_score: 8.5,
        review_count: 150,
        meal_plan: "Breakfast included",
        stars: 4,
      }
      expect(subject.to_h).to eq(expected_hash)
    end
  end

  describe "#id" do
    it "returns the id" do
      expect(subject.id).to eq(123)
    end
  end

  describe "#page_name" do
    it "returns the page name" do
      expect(subject.page_name).to eq("test_page")
    end
  end

  describe "#name" do
    it "returns the name" do
      expect(subject.name).to eq("Test Hotel")
    end
  end

  describe "#address" do
    it "returns the address" do
      expect(subject.address).to eq("123 Test St")
    end
  end

  describe "#city" do
    it "returns the city" do
      expect(subject.city).to eq("Test City")
    end
  end

  describe "#country_code" do
    it "returns the country code" do
      expect(subject.country_code).to eq("in")
    end
  end

  describe "#distance_from_centre" do
    it "returns the distance from the centre" do
      expect(subject.distance_from_centre).to eq('150 m from centre')
    end
  end

  describe "#display_price" do
    it "returns the display price" do
      expect(subject.display_price).to eq(100)
    end
  end

  describe "#currency" do
    it "returns the currency" do
      expect(subject.currency).to eq("INR")
    end
  end

  describe "#review_score" do
    it "returns the review score" do
      expect(subject.review_score).to eq(8.5)
    end
  end

  describe "#review_count" do
    it "returns the review count" do
      expect(subject.review_count).to eq(150)
    end
  end

  describe "#meal_plan" do
    it "returns the meal plan" do
      expect(subject.meal_plan).to eq("Breakfast included")
    end
  end

  describe "#stars" do
    it "returns the stars" do
      expect(subject.stars).to eq(4)
    end
  end

  describe "#best_unit_id" do
    context "when unit id exists" do
      it "returns the best unit id" do
        expect(subject.best_unit_id).to eq(456)
      end
    end

    context "when unit id does not exist" do
      let(:data) { { "matchingUnitConfigurations" => {} } }

      it "raises an error" do
        expect { subject.best_unit_id }.to raise_error(RuntimeError, /Best unit id not found for listing:/)
      end
    end
  end

  describe "#blocks" do
    it "returns the blocks" do
      expect(subject.blocks).to eq(data["blocks"])
    end
  end

  describe "#best_block_id" do
    context "when block exists" do
      it "returns the best block id" do
        expect(subject.best_block_id).to eq("456_policy_1_2_meal_1_package_1")
      end
    end

    context "when block does not exist" do
      let(:data) { {} }

      it "raises an error" do
        expect { subject.best_block_id }.to raise_error(RuntimeError, /Best block id not found for listing:/)
      end
    end
  end
end
