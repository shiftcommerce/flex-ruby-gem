FactoryGirl.define do
  klass = Struct.new(:data, :included)
  factory :menu, class: klass do
        data {{
            "attributes": {
                "title": "Searching For Products",
                "position": 999,
                "item": {
                    "type": "Product",
                    "attributes": {
                        "id": 1,
                        "title": "Garys Product"
                    }
                },
                "links": {
                    "self": "/garytaylor/v1/products/garys-product.json"
                }
            },
            "type": "menus",
            "id": 1,
            "links": {
                "self": "/garytaylor/v1/menus/help.json"
            },
            "meta": {
                "type": "Menu"
            },
            "relationships": {
                "menu_items": {

                    "data": [
                        { "type": "menu_items", "id": 100 },
                        { "type": "menu_items", "id": 101 }
                    ]
                }

            }
        }}
        included {[
            {
                "type": "menu_items",
                "id": 100,
                "attributes": {
                    "title": "Menu With 1 Child",
                    "position": 999,
                    "item": {
                        "type": "Product",
                        "attributes": {
                            "id": 3,
                            "title": "rreererere"
                        }
                    }
                },
                "relationships": {
                    "menu_items": {
                        "links": {
                            "self": "http://test.example.com/menu_items/100/menu_items"
                        },
                        "data": [
                            { "type": "menu_items", "id": 102 }
                        ]
                    }
                },
                "links": {
                    "self": "/garytaylor/v1/products/rreererere.json"
                }

            },
            {
                "type": "menu_items",
                "id": 101,
                "attributes": {
                    "title": "Menu With no Children",
                    "position": 999,
                    "item": {
                        "type": "Product",
                        "attributes": {
                            "id": 3,
                            "title": "rreererere"
                        }
                    }
                }
            },
            {
                "type": "menu_items",
                "id": 102,
                "attributes": {
                    "title": "Child 1 of menu item 100",
                    "position": 999,
                    "item": {
                        "type": "Product",
                        "attributes": {
                            "id": 3,
                            "title": "rreererere"
                        }
                    }
                }
            }
        ]}
  end
  factory :menu_from_fixture, class: OpenStruct do
      obj = RecursiveOpenStruct.new(JSON.parse(File.read("spec/fixtures/menus/singular.json")))
      obj.each_pair do |key, _|
        send(key, obj.send(key))
      end
  end
end