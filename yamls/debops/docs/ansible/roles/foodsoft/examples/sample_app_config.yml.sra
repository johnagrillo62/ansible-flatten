(playbook "debops/docs/ansible/roles/foodsoft/examples/sample_app_config.yml"
  (default 
    (multi_coop_install "false")
    (default_scope "f")
    (name "FC Test")
    (contact 
      (street "Grüne Straße 103")
      (zip_code "10997")
      (city "Berlin")
      (country "Deutschland")
      (email "foodsoft@foodcoop.test")
      (phone "030 323 23249"))
    (homepage "http://www.foodcoop.test")
    (help_url "https://github.com/foodcoops/foodsoft/wiki/Doku")
    (applepear_url "https://github.com/foodcoops/foodsoft/wiki/%C3%84pfel-u.-Birnen")
    (price_markup "2.0")
    (tax_default "7.0")
    (tolerance_is_costly "false")
    (use_nick "false")
    (email_sender "foodsoft@foodcoop.test")
    (notification 
      (error_recipients (list
          "admin@foodcoop.test"))
      (sender_address "\"Foodsoft Error\" <foodsoft@foodcoop.test>")
      (email_prefix "[Foodsoft]")))
  (development 
    (<< 
      (multi_coop_install "false")
      (default_scope "f")
      (name "FC Test")
      (contact 
        (street "Grüne Straße 103")
        (zip_code "10997")
        (city "Berlin")
        (country "Deutschland")
        (email "foodsoft@foodcoop.test")
        (phone "030 323 23249"))
      (homepage "http://www.foodcoop.test")
      (help_url "https://github.com/foodcoops/foodsoft/wiki/Doku")
      (applepear_url "https://github.com/foodcoops/foodsoft/wiki/%C3%84pfel-u.-Birnen")
      (price_markup "2.0")
      (tax_default "7.0")
      (tolerance_is_costly "false")
      (use_nick "false")
      (email_sender "foodsoft@foodcoop.test")
      (notification 
        (error_recipients (list
            "admin@foodcoop.test"))
        (sender_address "\"Foodsoft Error\" <foodsoft@foodcoop.test>")
        (email_prefix "[Foodsoft]"))))
  (test 
    (<< 
      (multi_coop_install "false")
      (default_scope "f")
      (name "FC Test")
      (contact 
        (street "Grüne Straße 103")
        (zip_code "10997")
        (city "Berlin")
        (country "Deutschland")
        (email "foodsoft@foodcoop.test")
        (phone "030 323 23249"))
      (homepage "http://www.foodcoop.test")
      (help_url "https://github.com/foodcoops/foodsoft/wiki/Doku")
      (applepear_url "https://github.com/foodcoops/foodsoft/wiki/%C3%84pfel-u.-Birnen")
      (price_markup "2.0")
      (tax_default "7.0")
      (tolerance_is_costly "false")
      (use_nick "false")
      (email_sender "foodsoft@foodcoop.test")
      (notification 
        (error_recipients (list
            "admin@foodcoop.test"))
        (sender_address "\"Foodsoft Error\" <foodsoft@foodcoop.test>")
        (email_prefix "[Foodsoft]"))))
  (production 
    (<< 
      (multi_coop_install "false")
      (default_scope "f")
      (name "FC Test")
      (contact 
        (street "Grüne Straße 103")
        (zip_code "10997")
        (city "Berlin")
        (country "Deutschland")
        (email "foodsoft@foodcoop.test")
        (phone "030 323 23249"))
      (homepage "http://www.foodcoop.test")
      (help_url "https://github.com/foodcoops/foodsoft/wiki/Doku")
      (applepear_url "https://github.com/foodcoops/foodsoft/wiki/%C3%84pfel-u.-Birnen")
      (price_markup "2.0")
      (tax_default "7.0")
      (tolerance_is_costly "false")
      (use_nick "false")
      (email_sender "foodsoft@foodcoop.test")
      (notification 
        (error_recipients (list
            "admin@foodcoop.test"))
        (sender_address "\"Foodsoft Error\" <foodsoft@foodcoop.test>")
        (email_prefix "[Foodsoft]")))))
