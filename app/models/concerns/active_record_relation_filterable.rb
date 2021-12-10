module ActiveRecordRelationFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_af(params)
      query = where('')
      range_params, params, search_params = extract_params(params)
      params, query = make_joins(parse_param_keys(params), query)
      params.each do |key, value|
        query = filter_query_selector(query, key, value)
      end
      query = daterange_af(query, range_params) if range_params.any?
      query = search_af(query, search_params) if search_params.any?
      query
    end

    private

    def extract_params(params)
      range_params = {}
      new_params = {}
      search_params = {}
      params.each do |k, v|
        if k.to_s.include?('range')
           range_params[k] = v
        elsif k.to_s.match(/(text)/)
          search_params[k] = v
        else
          new_params[k] = v
        end
      end
      [range_params, new_params, search_params]
    end

    def search_af(query, params)
      text = params[:text]
      ilike_query = ""
      params, query = make_search_joins(parse_search_param_keys(params), query)
      params.each_with_index do |key, i|
        ilike_query += "#{key} ILIKE :text"
        ilike_query += " OR " if params.length > 1 and (i+1) != params.length
      end
      query = query.where(ilike_query, text: "%#{text}%")
      query
    end

    def daterange_af(query, params)
      params, query = make_joins(parse_param_keys(params), query)
      params.each do |key, value|
        start_time, end_time = parse_daterange_to_time(value)
        query = query.where(field_query_to_rails_query(key, [start_time..end_time]))
      end
      query
    end

    def sanitize_key(key)
      key = key.to_s.split('.')
      key = [self.name.underscore] + key if key.one?
      key = (key[0...-1].map(&:pluralize) + key[-1..-1]).join('.')
      ActiveRecord::Base.sanitize_sql(key)
    end

    def field_query_to_rails_query(path, value)
      path = path.to_s if path.is_a? Symbol
      tables = path.split('.')
      tables.reverse.inject(value) { |assigned_value, key| { key => assigned_value } }
    end
    
    def filter_query_selector(current_query, key, value)
      current_query = current_query.where(field_query_to_rails_query(key, value))
      current_query
    end

    # def filter_query_selector(current_query, key, value)
    #   if value.is_a?(Array)
    #     current_query = current_query.where("#{sanitize_key(key)} IN (?)", value)
    #   else
    #     current_query = current_query.where("#{sanitize_key(key)} = ?", value)
    #   end
    # end

    def key_to_joins_params(models)
      params = { models[1].to_sym => models[0].to_sym}
      models[2..-1].each { |model_key| params = {model_key => params} } if models.size > 2
      params
    end

    def add_join(query, key)
      if query.joins_values.any? { |x| x&.left&.name == key&.to_s rescue false }
        query
      else
        key = key.to_sym if key.is_a? String
        query.joins(key)
      end
    end

    def make_search_joins(params, query)
      new_params = []
      params.each do |key, value|
        models = key.to_s.split('.')[0...-1]
        if models[0] == first.class.table_name
          models.slice(1)
          new_params << key
          next
        end

        transform_association = ""
        reflect_on_all_associations.each do |a|
          transform_association = a.name if a.plural_name == models[0]
        end

        if models.empty?
          new_params << key
          next
        end

        if models.one?
          query = add_join(query, transform_association)
          new_params << key
        else
          query = add_join(query, key_to_joins_params(models))
          new_params << key.split('.')[-2..-1].join('.')
        end
      end
      [new_params, query]
    end

    def make_joins(params, query)
      new_params = {}
      params.each do |key, value|
        models = key.to_s.split('.')[0...-1]

        if models.empty?
          new_params[key] = value
          next
        end

        if models.one?
          query = add_join(query, models.first)
          new_params[key] = value
        else
          query = add_join(query, key_to_joins_params(models))
          new_params[key.split('.')[-2..-1].join('.')] = value
        end
      end
      [new_params, query]
    end

    def parse_daterange_to_time(value)
      return if value.empty?
      is_an_array = value.is_a?(Array)
      is_a_time_class = %w[DateTime Time Date].include?(value.first.class.name) if is_an_array

      if is_a_time_class
        start_time = value.first
        end_time = value.last
      else
        start_time = Time.parse(value.first)
        end_time = Time.parse(value.last)
      end
      start_time = start_time.beginning_of_day 
      end_time = end_time.end_of_day

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

    def parse_search_param_keys(params)
      param_hash = {}
      search_params.each do |k, v|
        param_hash[v] = params[:text] unless params[:text].nil?
      end
      param_hash
    end

    def filter_params
      {}
    end

    def search_params
      {}
    end
  end
end
