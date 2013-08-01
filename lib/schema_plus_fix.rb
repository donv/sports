# FIXME(uwe):  Reported lomba/schema_plus as Issue #11
# Needed for schema_plus
module ::ArJdbc
  module PostgreSQL
    def schema_search_path
      @config[:schema_search_path] || select_rows('SHOW search_path')[0][0]
    end

    def query(*args)
      select(*args).map(&:values)
    end
  end
end

class ActiveRecord::ConnectionAdapters::PostgreSQLColumn
  def initialize(name, *args)
    super
  end
end

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def indexes(*args)
    super(*args) # Will be removed by the schema_plus gem
  end
  def exec_cache(*args) # Will be aliased by schema_plus
    super
  end
end

class ActiveRecord::ConnectionAdapters::JdbcColumn
  def initialize_with_nil_config(*args)
    initialize_without_nil_config(nil, *args)
  end
  alias_method_chain :initialize, :nil_config

  def self.extract_value_from_default(default)
    value = default_value(val)
    puts "datek extract_value_from_default value: #{value}"
    value
  end
end

module SchemaPlus
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter
        def indexes(table_name, name = nil) #:nodoc:
          schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
          result = query(<<-SQL, name)
           SELECT distinct i.relname, d.indisunique, d.indkey, m.amname, t.oid,
                    pg_get_expr(d.indpred, t.oid), pg_get_expr(d.indexprs, t.oid)
             FROM pg_class t, pg_class i, pg_index d, pg_am m
           WHERE i.relkind = 'i'
             AND i.relam = m.oid
             AND d.indexrelid = i.oid
             AND d.indisprimary = 'f'
             AND t.oid = d.indrelid
             AND t.relname = '#{table_name}'
             AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN (#{schemas}) )
          ORDER BY i.relname
          SQL

          result.map do |(index_name, is_unique, indkey, kind, oid, conditions, expression)|
            unique = (is_unique == 't')
            index_keys = indkey.split(" ").map(&:to_i)

            columns = Hash[query(<<-SQL, "Columns for index #{index_name} on #{table_name}")]
            SELECT a.attnum, a.attname
            FROM pg_attribute a
            WHERE a.attrelid = #{oid}
            AND a.attnum IN (#{index_keys.join(",")})
            SQL

            column_names = columns.values_at(*index_keys).compact
            if md = expression.try(:match, /^lower\(\(?([^)]+)\)?(::text)?\)$/i)
              column_names << md[1]
            end
            ::ActiveRecord::ConnectionAdapters::IndexDefinition.new(table_name, column_names,
                                                                    :name => index_name,
                                                                    :unique => unique,
                                                                    :conditions => conditions,
                                                                    :case_sensitive => !(expression =~ /lower/i),
                                                                    :kind => kind.downcase == "btree" ? nil : kind,
                                                                    :expression => expression)
          end
        end
      end
    end
  end
end
# EMXIF
