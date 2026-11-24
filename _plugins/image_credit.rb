# frozen_string_literal: true

# _plugins/image_credit.rb
#
# Liquid filters for looking up image credits from _data/image_credits.yaml.
#
# Filters:
#   image_credit_key  — "/img/bnf-ar-12-x1000.jpg" → "bnf-ar-12-x1000"
#   image_credit      — "/img/bnf-ar-12.jpg"        → { "credit" => "...", ... }
#   credit_date       — "2012-12-31T15:20:00"       → "31 Dec 2012"
#                       "2012"                      → "2012"
#                       "" / nil / junk             → ""
#
# The credit-date formatter is shared with _plugins/image_credit_popover_hook.rb
# via Jekyll::ImageCreditFormat.date, so popovers and hand-written sentences
# always agree. Dates are optional: sidecars may carry a full timestamp, a
# bare year, a year-month, or free text ("c. 1900"); anything unrecognisable
# renders nothing rather than a wrong date.

require 'date'

module Jekyll
  module ImageCreditFormat
    # Formats a credit date for display. Never raises, never invents a date:
    # unrecognisable input returns '' (callers then omit the fragment).
    def self.date(value)
      return '' if value.nil?

      # YAML may hand us a Date/Time (unquoted scalars) rather than a String.
      return value.strftime('%d %b %Y') if value.respond_to?(:strftime)

      s = value.to_s.strip
      return '' if s.empty?

      # Full date: 2012-12-31, 2012:12:31, optionally with a time.
      if s =~ /\A(\d{4})[:\-](\d{2})[:\-](\d{2})(?:[T ].*)?\z/
        begin
          return Date.new(Regexp.last_match(1).to_i,
                          Regexp.last_match(2).to_i,
                          Regexp.last_match(3).to_i).strftime('%d %b %Y')
        rescue ArgumentError
          # e.g. 2012-13-45 — fall through to the other branches.
        end
      end

      # Year only: 2012
      return s if s =~ /\A\d{4}\z/

      # Year + month: 2012-12
      if s =~ /\A(\d{4})[:\-](\d{2})\z/
        begin
          return Date.new(Regexp.last_match(1).to_i,
                          Regexp.last_match(2).to_i,
                          1).strftime('%b %Y')
        rescue ArgumentError
          return ''
        end
      end

      # Free text that carries a year, e.g. "c. 1900" or "1880s" — show as-is.
      return s if s =~ /\d{3,4}/

      ''
    end
  end

  module ImageCreditFilter
    # Returns the lookup key for a given image URL: strips path and extension.
    def image_credit_key(url)
      File.basename(url.to_s, '.*')
    end

    # Returns the credit hash for a given image URL, or {} if not found.
    def image_credit(url)
      key = image_credit_key(url)
      site = @context.registers[:site]
      site.data.dig('image_credits', key) || {}
    end

    # Kills the "Date: ." / dangling-space problem when a credit has no date.
    def credit_date(value)
      Jekyll::ImageCreditFormat.date(value)
    end
  end
end

Liquid::Template.register_filter(Jekyll::ImageCreditFilter)
