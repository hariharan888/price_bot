require "json"

module Site
  class BookingListing
    def initialize(data)
      @data = data
    end

    def inspect
      "#<#{self.class.name} @id=#{id} @name=#{name}>"
    end

    def to_h
      {
        id:,
        name:,
        address:,
        city:,
        country_code:,
        distance_from_centre:,
        display_price:,
        currency:,
        review_score:,
        review_count:,
        meal_plan:,
        stars:,
      }
    end

    def id
      @data.dig("basicPropertyData", "id")
    end

    def page_name
      @data.dig("basicPropertyData", "pageName")
    end

    def name
      @data.dig("displayName", "text")
    end

    def address
      @data.dig("basicPropertyData", "location", "address")
    end

    def city
      @data.dig("basicPropertyData", "location", "city")
    end

    def country_code
      @data.dig("basicPropertyData", "location", "countryCode")
    end

    def distance_from_centre
      @data.dig("location", "mainDistance")
    end

    def display_price
      @data.dig("priceDisplayInfoIrene", "displayPrice", "amountPerStay", "amountUnformatted")
    end

    def currency
      @data.dig("priceDisplayInfoIrene", "displayPrice", "amountPerStay", "currency")
    end

    def review_score
      @data.dig("basicPropertyData", "reviewScore", "score")
    end

    def review_count
      @data.dig("basicPropertyData", "reviewScore", "reviewCount")
    end

    def meal_plan
      @data.dig("mealPlanIncluded", "text")
    end

    def stars
      @data.dig("basicPropertyData", "starRating", "value")
    end

    def best_unit_id
      unit_id = @data.dig("matchingUnitConfigurations", "unitConfigurations", 0, "unitId")

      raise "Best unit id not found for listing: #{@data}" if unit_id.nil?

      unit_id
    end

    def blocks
      @data.dig("blocks") || []
    end

    def best_block_id
      block = blocks.find { |block|
        block.dig("blockId", "roomId").to_s === best_unit_id.to_s
      }
      policy_id = block&.dig("blockId", "policyGroupId")
      occupancy = block&.dig("blockId", "occupancy")
      meal_plan_id = block&.dig("blockId", "mealPlanId")
      package_id = block&.dig("blockId", "packageId")

      if [block, policy_id, occupancy, meal_plan_id, package_id].any?(&:nil?)
        raise "Best block id not found for listing: #{@data}"
      end

      "#{best_unit_id}_#{policy_id}_#{occupancy}_#{meal_plan_id}_#{package_id}"
    end
  end
end
