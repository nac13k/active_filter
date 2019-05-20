module ActiveRecordRelationFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(params)
      query, params = [self.where(""), parse_param_keys(params)]
      params.each do |key, value|
        if value.is_a?(Array)
          query = self.where("#{ActiveRecord::Base::sanitize_sql(key)} IN (?)", value)
        else
          query = self.where("#{ActiveRecord::Base::sanitize_sql(key)} = ?", value)
        end
      end
      query
    end

    def search(params)
      query, params = [self.where(""), parse_param_keys(params)]
      params.each do |key, value|
        query = self.where("#{ActiveRecord::Base::sanitize_sql(key)} ILIKE ?", "%#{value}%")
      end
      query
    end
  
    def daterange_filter(params)
      query, params = [self.where(""), parse_param_keys(params)]
      params.each do |key, value|
        start_time, end_time = parse_daterange_to_time(value)
        query = self.where("#{ActiveRecord::Base::sanitize_sql(key)} between ? and ?", start_time, end_time)
      end
      query
    end
    
    private

    def parse_daterange_to_time(value)
      is_an_array = value.is_a?(Array)
      is_a_time_class = ['DateTime', 'Time', 'Date'].include?(value.first.class.name) if is_an_array

      if is_a_time_class
        start_time = value.first
        end_time = value.last
      else
        start_time = Time.parse(value.split(' - ').first)
        end_time = Time.parse(value.split(' - ').last)
      end

      [start_time, end_time]
    end

    def param_key_to_field(key)
      filter_params[key.to_sym]
    end

    def parse_param_keys(params)
      param_hash = Hash.new
      params.each do |k, v|
        key = param_key_to_field(k)
        param_hash[key] = v unless key.nil?
      end
      param_hash
    end

    def filter_params; {}; end
  end
end