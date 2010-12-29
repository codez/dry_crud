be = City.create!(:name => 'Bern', :country_code => 'CH')
ny = City.create!(:name => 'New York', :country_code => 'USA')
sf = City.create!(:name => 'San Francisco', :country_code => 'USA')
lon = City.create!(:name => 'London', :country_code => 'GB')
br = City.create!(:name => 'Berlin', :country_code => 'DE')

Person.create!(:name => 'Albert Einstein', 
			   :city => be, 
			   :children => 2, 
			   :rating => 9.8,  
			   :income => 84000,
			   :birthdate => '1904-10-18',
			   :remarks => "Great physician\n Good cyclist")
Person.create!(:name => 'Adolf Ogi', 
			   :city => be, 
			   :children => 3, 
			   :rating => 4.2,  
			   :income => 264000,
			   :birthdate => '1938-01-22',
			   :remarks => 'Freude herrscht!')
Person.create!(:name => 'Jay Z', 
			   :city => ny, 
			   :children => 0, 
			   :rating => 7.2,  
			   :income => 868345,
			   :birthdate => '1976-05-02',
			   :remarks => "If got 99 problems\nbut you *** ain't one\nTschie")
Person.create!(:name => 'Queen Elisabeth', 
			   :city => lon, 
			   :children => 1, 
			   :rating => 1.56,  
			   :income => 345622,
			   :birthdate => '1927-08-11',
			   :remarks => '')
Person.create!(:name => 'Schopenhauer', 
			   :city => br, 
			   :children => 7, 
			   :rating => 6.9,  
			   :income => 14000,
			   :birthdate => '1788-10-18',
			   :remarks => 'Neminem laede, immo omnes, quantum potes, iuva.')
Person.create!(:name => 'ZZ Top', 
			   :city => ny, 
			   :children => 185, 
			   :rating => 1.8,  
			   :income => 84000,
			   :birthdate => '1948-03-18',
			   :remarks => 'zzz..')
Person.create!(:name => 'Andy Warhol', 
			   :city => ny, 
			   :children => 0, 
			   :rating => 7.5,  
			   :income => 123000,
			   :birthdate => '1938-09-08',
			   :remarks => 'Tomato Soup')