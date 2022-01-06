# frozen_string_literal: true

module Likee
  class Resource
    def initialize(api:, resource: nil, parent: nil)
      @api = api
      @resource = resource
      @parent = parent
    end

    def inspect
      io = StringIO.new
      io << self.class.name
      if resource
        io << '{'
        io << "\n"
        resource.each_pair do |attribute_name, value|
          io << "  :#{attribute_name}"
          io << ' => '
          io << value.inspect
          io << "\n"
        end
        io << '}'
      elsif parent
        io << '[Parent: '
        io << parent.inspect
        io << ']'
      end
      io.string
    end

    def respond_to_missing?(name, *args)
      (!resource.nil? && resource.respond_to?(name)) || super
    end

    def method_missing(name, *args, &)
      if !resource.nil? && resource.respond_to?(name)
        resource.public_send(name)
      else
        super
      end
    end

    private

    attr_reader :api, :resource, :parent
  end
end
