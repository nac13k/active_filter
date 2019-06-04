module ActiveRecordRelationFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(params)
      query = where('')
      params = parse_param_keys(params)
      query = make_joins(params, query)
      params.each do |key, value|
        query = filter_query_selector(query, key, value)
      end
      query
    end

    def search(params)
      query = where('')
      params = parse_param_keys(params)
      query = make_joins(params, query)
      params.each do |key, value|
        query = query.where("#{sanitize_key(key)} ILIKE ?", "%#{value}%")
      end
      query
    end

    def daterange_filter(params)
      query = where('')
      params = parse_param_keys(params)
      query = make_joins(params, query)
      params.each do |key, value|
        start_time, end_time = parse_daterange_to_time(value)
        query = query.where("#{sanitize_key(key)} between ? and ?", start_time, end_time)
      end
      query
    end

    private

    def sanitize_key(key)
      key = key.to_s.split('.')
      key = [self.name.downcase] + key if key.one?
      key = (key[0...-1].map(&:pluralize) + key[-1..-1]).join('.')
      ActiveRecord::Base.sanitize_sql(key)
    end

    def filter_query_selector(current_query, key, value)
      if value.is_a?(Array)
        current_query = current_query.where("#{sanitize_key(key)} IN (?)", value)
      else
        current_query = current_query.where("#{sanitize_key(key)} = ?", value)
      end
    end

    def make_joins(params, query)
      params.each do |key, value|
        models = key.to_s.split('.')[0...-1]
        break if models.empty?
        if models.one?
          query = query.joins(models.first.to_sym)
        elsif models.size > 2
          models.reverse
          join_objects = { models[1].to_sym => models[0].to_sym}
          models[2..-1].each { |model_key| join_objects = {model_key => join_objects} }
          query = query.joins(join_objects)
        else
          models.reverse
          join_objects = { models[1].to_sym => models[0].to_sym }
          query = query.joins(join_objects)
        end
      end
      query
    end

    def parse_daterange_to_time(value)
      is_an_array = value.is_a?(Array)
      is_a_time_class = %w[DateTime Time Date].include?(value.first.class.name) if is_an_array

      if is_a_time_class
        start_time = value.first
        end_time = value.last
      else
        start_time = Time.parse(value.split(' - ').first)
        end_time = Time.parse(value.split(' - ').last)
        start_time = start_time.beginning_of_day if start_time.hour.zero? and start_time.min.zero?
        end_time = end_time.end_of_day if end_time.hour.zero? and end_time.min.zero?
      end

      [start_time, end_time]
    end

    def param_key_to_field(key)
      filter_params[key.to_sym]
    end

    def parse_param_keys(params)
      param_hash = {}
      params.each do |k, v|
        key = param_key_to_field(k)
        param_hash[key] = v unless key.nil?
      end
      param_hash
    end

    def filter_params
      {}
    end
  end
end
