require 'test_helper'

module Resolvers
  class LinksSearchTest < ActiveSupport::TestCase
    def find(args)
      ::Resolvers::LinksSearch.new(filters: args.to_h, object: nil, context: nil).results
    end

    # those helpers should be handled with something like `factory_bot` gem
    def create_user
      User.create name: 'test', email: 'test@example.com', password: '123456'
    end

    def create_link(**attributes)
      Link.create! attributes.merge(user: create_user)
    end

    test 'skip option' do
      link1 = create_link description: 'test1', url: 'http://test1.com'
      link2 = create_link description: 'test2', url: 'http://test2.com'

      assert_equal find(skip: 1), [link1]
    end

    test 'first option' do
      link1 = create_link description: 'test1', url: 'http://test1.com'
      link2 = create_link description: 'test2', url: 'http://test2.com'

      assert_equal find(first: 1), [link2]
    end

    test 'filter option' do
      link1 = create_link description: 'test1', url: 'http://test1.com'
      link2 = create_link description: 'test2', url: 'http://test2.com'
      link3 = create_link description: 'test3', url: 'http://test3.com'
      link4 = create_link description: 'test4', url: 'http://test4.com'

      result = find(
        filter: {
          description_contains: 'test1',
          OR: [{
            url_contains: 'test2',
            OR: [{
              url_contains: 'test3'
            }]
          }, {
            description_contains: 'test2'
          }]
        }
      )

      assert_equal result.map(&:description).sort, [link1, link2, link3].map(&:description).sort
    end


    test 'order by createdAt_ASC' do
      new = create_link description: 'test1', url: 'http://test1.com', created_at: 1.week.ago
      old = create_link description: 'test2', url: 'http://test2.com', created_at: 1.month.ago

      assert_equal find(orderBy: 'createdAt_ASC'), [old, new]
    end

    test 'order by createdAt_DESC' do
      new = create_link description: 'test1', url: 'http://test1.com', created_at: 1.week.ago
      old = create_link description: 'test2', url: 'http://test2.com', created_at: 1.month.ago

      assert_equal find(orderBy: 'createdAt_DESC'), [new, old]
    end
  end
end
