module ActiveRecord
  module GroupableAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Use this method to group together some of your model's attributes.
      # 
      # ==== Parameters
      # 
      # * +name+ - The collection's name.
      # * +attribute_name+ - The names of the attributes to be collected.
      #
      # ==== Examples
      # 
      #   class Comment < ActiveRecord::Base
      #     attribute_collection :restricted, [:name, :email]
      #   end
      #
      #   comment = Comment.new(:name => "Paul", :email => "paul@paul.com", :content => "blub")
      #   comment.restricted  #=> { :name => "Paul", :email => "paul@paul.com" }
      #
      def attribute_collection(name, attribute_names)
        name = name.to_sym

        if respond_to?(name, true)
          logger.warn "Creating attribute collection :#{name}. " \
                      "Overwriting existing method #{self.name}.#{name}."
        end

        define_method name do
          collection = {}
          attribute_names.each do |attribute_name|
            attribute_name = attribute_name.to_sym
            collection[attribute_name] = self[attribute_name]
          end
          collection
        end
      end

    end
  end
end