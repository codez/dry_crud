# Time columns will become time zone aware in Rails 5.1. This
# still causes `String`s to be parsed as if they were in `Time.zone`,
# and `Time`s to be converted to `Time.zone`.

# To keep the old behavior, you must add the following to your initializer:
# config.active_record.time_zone_aware_types = [:datetime]

# To silence this deprecation warning, add the following:
Rails.application.config.active_record.time_zone_aware_types = [:datetime, :time]
