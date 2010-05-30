module ActiveRecord
  module GroupableAttributes
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        class << self
          alias_method_chain :find, :collection_selection
        end
      end
    end

    # Useful for grouping together some of your model's attributes.
    # 
    #   class Comment < ActiveRecord::Base
    #     attribute_collection :restricted, [:name, :email]
    #   end
    #
    #   comment = Comment.new(:name => "Paul", :email => "paul@example.com", :content => "blub")
    #   comment.restricted  #=> { :name => "Paul", :email => "paul@example.com" }
    #
    # You can also select only a given collection using the find option :select_collection.
    # This is a wrapper for :select.
    #
    #   Comment.create(:name => "Paul", :email => "paul@example.com", :content => "blub")
    #   comment = Comment.first(:select_collection => :restricted)
    #   comment.attributes #=> { "name" => "Paul", "email" => "paul@example.com" }
    #
    # This will raise an exception if the collection doesn't exist.
    #
    module ClassMethods
      # Use this method to group together some of your model's attributes.
      # 
      # ==== Parameters
      # 
      # * +name+ - The collection's name.
      # * +attribute_name+ - The names of the attributes to be collected.
      #
      def attribute_collection(name, attribute_names)
        name = name.to_sym

        if respond_to?(name, true)
          logger.warn "Creating attribute collection :#{name}. " \
                      "Overwriting existing method #{self.name}.#{name}."
        end

        attribute_collections[name] = attribute_names

        define_method name do
          collection = {}
          attribute_names.each do |attribute_name|
            attribute_name = attribute_name.to_sym
            collection[attribute_name] = self[attribute_name]
          end
          collection
        end
      end

      def attribute_collections
        read_inheritable_attribute(:attribute_collections) || write_inheritable_attribute(:attribute_collections, {})
      end

      private
      def find_with_collection_selection(*args)
        options = args.extract_options!
        raise "No attribute collection named #{options[:select_collection]}" unless attribute_collections[options[:select_collection]]
        attribute_collections[options[:select_collection]].each do |attribute_name|
          unless options[:select]
            options[:select] = attribute_name.to_s
          else
            options[:select] += ", " + attribute_name.to_s
          end
        end
        options.delete(:select_collection)
        args << options

        find_without_collection_selection(*args)
      end

    end
  end
end