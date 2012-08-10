require 'httparty'
require File.dirname(__FILE__) + '/google_weather/data'

class GoogleWeather
  include HTTParty
  base_uri "www.google.com"
  Path = "/ig/api"

  attr_reader :param

  def initialize(value, options={})
    @param   = prep_param(value)
    @options = options
  end

  def locale
    @options[:locale] || :en
  end

  def weather
    # @weather ||= self.class.get(Path, weather_options)['xml_api_reply']['weather']
    if @weather
      @weather
    else
      resp = self.class.get(Path, weather_options)
      resp.body.force_encoding 'utf-8'
      pp resp.body
      @weather = resp['xml_api_reply']['weather']
    end
  end

  def forecast_information
    @forecast_information ||= ForecastInformation.new(weather['forecast_information'])
  end

  def current_conditions
    @current_conditions ||= CurrentConditions.new(weather['current_conditions'])
  end

  def forecast_conditions
    @forecast_conditions ||= weather['forecast_conditions'].map { |cond| ForecastCondition.new(cond) }
  end

  private

  def weather_options
    opts = {
      :query => {
        :weather => param,
        :hl => locale,
        :oe => 'utf-8'
      },
      :format => :xml,
      :headers => {"User-Agent" => "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"}
    }
  end

  def prep_param(value)
    if value.kind_of?(Array)
      value = value.inject([]) do |result, element|
        result << (element * 1e6).to_i
        result
      end
      value = ",,,#{value[0]},#{value[1]}"
    else
      value
    end
  end
end
